import 'package:flura/flura.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/enums.dart';
import 'package:fleetflow/core/models/service_order.dart';
import 'package:fleetflow/core/repositories/order_repository.dart';
import 'package:fleetflow/domain/order_status_transition_service.dart';

class FakeOrderRepo2 implements OrderRepository {
  final Map<String, ServiceOrder> _store = {};

  @override
  Future<ServiceOrder?> findById(String id) async => _store[id];
  @override
  Future<List<ServiceOrder>> findOpenOrders() async => _store.values.toList();
  @override
  Stream<List<ServiceOrder>> watchDispatchBoard() => Stream.value([]);
  @override
  Future<void> save(ServiceOrder order) async => _store[order.id] = order;
  @override
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final o = _store[orderId];
    if (o != null) {
      o.status = status;
      o.version++;
      o.updatedAt = DateTime.now();
    }
  }
}

class FakeLogger2 implements AppLogger {
  @override
  void debug(String msg, {Map<String, dynamic>? context}) {}
  @override
  Future<void> info(String msg, {Map<String, dynamic>? context}) async {}
  @override
  Future<void> error(String msg, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {}
  @override
  Future<void> warning(String msg, {Map<String, dynamic>? context}) async {}
}

void main() {
  group('OrderStatusTransitionService', () {
    test('valid transition succeeds', () async {
      final repo = FakeOrderRepo2();
      final logger = FakeLogger2();
      final service = OrderStatusTransitionService(repository: repo, logger: logger);

      await repo.save(ServiceOrder(
        id: 'ord-001',
        tenantId: 't',
        customerId: 'c',
        serviceId: 's',
        status: OrderStatus.draft,
        paymentStatus: PaymentStatus.pending,
        serviceAddress: 'addr',
        scheduledAt: DateTime.now(),
        estimatedPrice: 100,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await service.transition(orderId: 'ord-001', next: OrderStatus.submitted);

      final updated = await repo.findById('ord-001');
      expect(updated!.status, OrderStatus.submitted);
      expect(updated.version, 2);
    });

    test('invalid transition throws', () async {
      final repo = FakeOrderRepo2();
      final logger = FakeLogger2();
      final service = OrderStatusTransitionService(repository: repo, logger: logger);

      await repo.save(ServiceOrder(
        id: 'ord-002',
        tenantId: 't',
        customerId: 'c',
        serviceId: 's',
        status: OrderStatus.draft,
        paymentStatus: PaymentStatus.pending,
        serviceAddress: 'addr',
        scheduledAt: DateTime.now(),
        estimatedPrice: 100,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      expect(
        () => service.transition(orderId: 'ord-002', next: OrderStatus.completed),
        throwsA(isA<InvalidOrderTransitionException>()),
      );
    });

    test('missing order throws', () async {
      final repo = FakeOrderRepo2();
      final logger = FakeLogger2();
      final service = OrderStatusTransitionService(repository: repo, logger: logger);

      expect(
        () => service.transition(orderId: 'ord-nonexistent', next: OrderStatus.submitted),
        throwsA(isA<OrderNotFoundException>()),
      );
    });
  });
}
