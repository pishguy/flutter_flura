import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/enums.dart';
import 'package:fleetflow/core/models/service_order.dart';

void main() {
  group('ServiceOrder', () {
    test('fromMap / toMap roundtrip', () {
      final original = ServiceOrder(
        id: 'ord-001',
        tenantId: 'tenant-a',
        customerId: 'cust-001',
        technicianId: 'tech-001',
        serviceId: 'svc-001',
        status: OrderStatus.assigned,
        paymentStatus: PaymentStatus.paid,
        serviceAddress: '123 Main St',
        scheduledAt: DateTime.utc(2026, 7, 11, 10, 0),
        estimatedPrice: 150.0,
        finalPrice: 145.0,
        version: 2,
        createdAt: DateTime.utc(2026, 7, 10, 8, 0),
        updatedAt: DateTime.utc(2026, 7, 11, 9, 0),
      );

      final map = original.toMap();
      final restored = ServiceOrder.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.tenantId, original.tenantId);
      expect(restored.customerId, original.customerId);
      expect(restored.technicianId, original.technicianId);
      expect(restored.serviceId, original.serviceId);
      expect(restored.status, original.status);
      expect(restored.paymentStatus, original.paymentStatus);
      expect(restored.serviceAddress, original.serviceAddress);
      expect(restored.scheduledAt, original.scheduledAt);
      expect(restored.estimatedPrice, original.estimatedPrice);
      expect(restored.finalPrice, original.finalPrice);
      expect(restored.version, original.version);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('technicianId and finalPrice can be null', () {
      final order = ServiceOrder(
        id: 'ord-002',
        tenantId: 'tenant-a',
        customerId: 'cust-002',
        serviceId: 'svc-002',
        status: OrderStatus.draft,
        paymentStatus: PaymentStatus.pending,
        serviceAddress: '456 Oak Ave',
        scheduledAt: DateTime.utc(2026, 7, 12),
        estimatedPrice: 200.0,
        version: 1,
        createdAt: DateTime.utc(2026, 7, 11),
        updatedAt: DateTime.utc(2026, 7, 11),
      );

      final map = order.toMap();
      final restored = ServiceOrder.fromMap(map);

      expect(restored.technicianId, isNull);
      expect(restored.finalPrice, isNull);
    });
  });
}
