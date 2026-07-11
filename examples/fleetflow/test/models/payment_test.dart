import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/enums.dart';
import 'package:fleetflow/core/models/payment.dart';

void main() {
  group('Payment', () {
    test('fromMap / toMap roundtrip', () {
      final original = Payment(
        id: 'pay-001',
        tenantId: 'tenant-a',
        orderId: 'ord-001',
        amount: 15000,
        currency: 'IRR',
        status: PaymentStatus.paid,
        gatewayReference: 'gw-ref-abc',
        paidAt: DateTime.utc(2026, 7, 11, 12, 0),
      );

      final map = original.toMap();
      final restored = Payment.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.tenantId, original.tenantId);
      expect(restored.orderId, original.orderId);
      expect(restored.amount, original.amount);
      expect(restored.currency, original.currency);
      expect(restored.status, original.status);
      expect(restored.gatewayReference, original.gatewayReference);
      expect(restored.paidAt, original.paidAt);
    });

    test('gatewayReference and paidAt can be null for pending payment', () {
      final payment = Payment(
        id: 'pay-002',
        tenantId: 'tenant-a',
        orderId: 'ord-002',
        amount: 50000,
        currency: 'IRR',
        status: PaymentStatus.pending,
      );

      final map = payment.toMap();
      final restored = Payment.fromMap(map);

      expect(restored.gatewayReference, isNull);
      expect(restored.paidAt, isNull);
    });
  });
}
