import 'package:flura/flura.dart';

import '../core/models/enums.dart';
import '../core/repositories/order_repository.dart';
import '../core/services/order_state_machine.dart';

class OrderStatusTransitionService {
  final OrderRepository repository;
  final AppLogger logger;

  OrderStatusTransitionService({required this.repository, required this.logger});

  Future<void> transition({required String orderId, required OrderStatus next}) async {
    final order = await repository.findById(orderId);
    if (order == null) throw OrderNotFoundException(orderId);
    if (!OrderStateMachine.canTransition(from: order.status, to: next)) {
      throw InvalidOrderTransitionException(orderId: orderId, from: order.status, to: next);
    }

    final previous = order.status;
    order.status = next;
    order.version++;
    order.updatedAt = DateTime.now();
    await repository.save(order);
    logger.info('Order state changed', context: {'orderId': orderId, 'from': previous.name, 'to': next.name});
  }
}
