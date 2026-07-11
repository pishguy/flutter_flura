import 'package:flura/flura.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/enums.dart';
import 'package:fleetflow/core/models/service_order.dart';
import 'package:fleetflow/core/models/technician_location.dart';
import 'package:fleetflow/core/repositories/order_repository.dart';
import 'package:fleetflow/core/repositories/technician_repository.dart';
import 'package:fleetflow/core/services/clock.dart';
import 'package:fleetflow/domain/dispatch_service.dart';

class FakeOrderRepo implements OrderRepository {
  final Map<String, ServiceOrder> _store = {};

  @override
  Future<ServiceOrder?> findById(String id) async => _store[id];

  @override
  Future<List<ServiceOrder>> findOpenOrders() async => _store.values.toList();

  @override
  Stream<List<ServiceOrder>> watchDispatchBoard() => Stream.value(_store.values.toList());

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

class FakeTechnicianRepo implements TechnicianRepository {
  final List<dynamic> _available = [];

  void add(String id) => _available.add(id);

  @override
  Future<List<dynamic>> findAvailableNear({required String address, required DateTime at}) async => _available;

  @override
  Stream<List<TechnicianLocation>> watchActiveTechnicians() => Stream.value([]);
}

class FakeLogger implements AppLogger {
  @override
  void debug(String msg, {Map<String, dynamic>? context}) {}
  @override
  Future<void> info(String msg, {Map<String, dynamic>? context}) async {}
  @override
  Future<void> warning(String msg, {Map<String, dynamic>? context}) async {}
  @override
  Future<void> error(String msg, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {}
}

class FakeClock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 7, 11, 12, 0);
}

void main() {
  group('DispatchService', () {
    late FakeOrderRepo orders;
    late FakeTechnicianRepo technicians;
    late FakeLogger logger;
    late FakeClock clock;
    late DispatchService service;

    setUp(() {
      orders = FakeOrderRepo();
      technicians = FakeTechnicianRepo();
      logger = FakeLogger();
      clock = FakeClock();
      service = DispatchService(orders: orders, technicians: technicians, logger: logger, clock: clock);
    });

    test('autoAssign assigns first available technician', () async {
      final order = ServiceOrder(
        id: 'ord-001',
        tenantId: 'tenant-a',
        customerId: 'cust-001',
        serviceId: 'svc-001',
        status: OrderStatus.dispatching,
        paymentStatus: PaymentStatus.paid,
        serviceAddress: '123 Main St',
        scheduledAt: DateTime.utc(2026, 7, 11, 14, 0),
        estimatedPrice: 100.0,
        version: 1,
        createdAt: DateTime.utc(2026, 7, 10),
        updatedAt: DateTime.utc(2026, 7, 10),
      );
      await orders.save(order);
      technicians.add('tech-001');
      technicians.add('tech-002');

      final result = await service.autoAssign('ord-001');

      expect(result.success, isTrue);
      expect(result.technicianId, 'tech-001');

      final updated = await orders.findById('ord-001');
      expect(updated!.technicianId, 'tech-001');
      expect(updated.status, OrderStatus.assigned);
    });

    test('autoAssign returns no candidate when none available', () async {
      final order = ServiceOrder(
        id: 'ord-002',
        tenantId: 'tenant-a',
        customerId: 'cust-002',
        serviceId: 'svc-002',
        status: OrderStatus.dispatching,
        paymentStatus: PaymentStatus.paid,
        serviceAddress: '456 Oak Ave',
        scheduledAt: DateTime.utc(2026, 7, 11, 15, 0),
        estimatedPrice: 200.0,
        version: 1,
        createdAt: DateTime.utc(2026, 7, 10),
        updatedAt: DateTime.utc(2026, 7, 10),
      );
      await orders.save(order);

      final result = await service.autoAssign('ord-002');

      expect(result.success, isFalse);
      expect(result.technicianId, isNull);
    });

    test('autoAssign throws on non-dispatching order', () async {
      final order = ServiceOrder(
        id: 'ord-003',
        tenantId: 'tenant-a',
        customerId: 'cust-003',
        serviceId: 'svc-003',
        status: OrderStatus.draft,
        paymentStatus: PaymentStatus.pending,
        serviceAddress: '789 Elm St',
        scheduledAt: DateTime.utc(2026, 7, 11, 16, 0),
        estimatedPrice: 300.0,
        version: 1,
        createdAt: DateTime.utc(2026, 7, 10),
        updatedAt: DateTime.utc(2026, 7, 10),
      );
      await orders.save(order);

      expect(
        () => service.autoAssign('ord-003'),
        throwsA(isA<InvalidOrderStateException>()),
      );
    });
  });
}
