import 'package:flura/flura.dart';

import '../core/models/enums.dart';
import '../core/models/payment.dart';
import '../core/repositories/order_repository.dart';
import '../core/repositories/payment_repository.dart';
import '../core/services/id_generator.dart';

class PaymentResult {
  final bool success;
  final Payment? payment;

  PaymentResult._({required this.success, this.payment});

  factory PaymentResult.alreadyPaid() => PaymentResult._(success: true);
  factory PaymentResult.resume(Payment payment) => PaymentResult._(success: false, payment: payment);
  factory PaymentResult.success(Payment payment) => PaymentResult._(success: true, payment: payment);
}

class PaymentService {
  final PaymentRepository payments;
  final OrderRepository orders;
  final AppHttpClient http;
  final AppLogger logger;
  final IdGenerator ids;

  PaymentService({
    required this.payments,
    required this.orders,
    required this.http,
    required this.logger,
    required this.ids,
  });

  Future<PaymentResult> payOrder(String orderId) async {
    final order = await orders.findById(orderId);
    if (order == null) throw OrderNotFoundException(orderId);
    if (order.paymentStatus == PaymentStatus.paid) return PaymentResult.alreadyPaid();

    final existing = await payments.findPendingByOrder(orderId);
    if (existing != null) return PaymentResult.resume(existing);

    final payment = Payment(
      id: ids.generate(),
      tenantId: order.tenantId,
      orderId: order.id,
      amount: order.estimatedPrice.toInt(),
      currency: 'IRR',
      status: PaymentStatus.pending,
    );
    await payments.save(payment);

    try {
      final response = await http.post('/payments', data: {
        'paymentId': payment.id,
        'orderId': order.id,
        'amount': payment.amount,
        'idempotencyKey': payment.id,
      });

      payment.status = PaymentStatus.paid;
      payment.gatewayReference = response['reference'] as String?;
      payment.paidAt = DateTime.now();

      order.paymentStatus = PaymentStatus.paid;
      order.status = OrderStatus.dispatching;

      await payments.save(payment);
      await orders.save(order);

      return PaymentResult.success(payment);
    } catch (error, stack) {
      payment.status = PaymentStatus.failed;
      await payments.save(payment);

      logger.error('Payment failed', error: error, stackTrace: stack, context: {'orderId': orderId});
      rethrow;
    }
  }
}
