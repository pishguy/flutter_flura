import 'dart:async';

import 'package:umay_db/umay_db.dart';

import '../models/enums.dart';
import '../models/service_order.dart';
import '../database/fleet_database_manager.dart';

abstract interface class OrderRepository {
  Future<ServiceOrder?> findById(String id);
  Future<List<ServiceOrder>> findOpenOrders();
  Stream<List<ServiceOrder>> watchDispatchBoard();
  Future<void> save(ServiceOrder order);
  Future<void> updateStatus(String orderId, OrderStatus status);
}

class TenantOrderRepository implements OrderRepository {
  final String tenantId;
  final FleetDatabaseManager database;

  TenantOrderRepository({required this.tenantId, required this.database});

  UmayBox get box => database.boxForTenant(tenantId);

  @override
  Future<ServiceOrder?> findById(String id) async {
    final result = await box.get(id);
    if (result == null) return null;
    return ServiceOrder.fromMap(Map<String, dynamic>.from(result as Map));
  }

  @override
  Future<List<ServiceOrder>> findOpenOrders() async {
    final results = await box.query<ServiceOrder>().where((o) => (o as dynamic).status.inValues([
          OrderStatus.paid.index,
          OrderStatus.dispatching.index,
          OrderStatus.assigned.index,
          OrderStatus.inProgress.index,
        ])).find();
    return results.cast<ServiceOrder>();
  }

  @override
  Stream<List<ServiceOrder>> watchDispatchBoard() {
    return box.query<ServiceOrder>().where((o) => (o as dynamic).status.notEqual(OrderStatus.completed.index)).watch().map((items) => items.cast<ServiceOrder>());
  }

  @override
  Future<void> save(ServiceOrder order) async {
    await box.put(order.id, order.toMap());
  }

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final order = await findById(orderId);
    if (order == null) throw OrderNotFoundException(orderId);
    order.status = status;
    order.version++;
    order.updatedAt = DateTime.now();
    await save(order);
  }
}

class OrderNotFoundException implements Exception {
  final String orderId;
  OrderNotFoundException(this.orderId);
  @override
  String toString() => 'Order not found: $orderId';
}

class InvalidOrderTransitionException implements Exception {
  final String orderId;
  final OrderStatus from;
  final OrderStatus to;

  InvalidOrderTransitionException({required this.orderId, required this.from, required this.to});

  @override
  String toString() => 'Invalid transition $from → $to for order $orderId';
}

class InvalidOrderStateException implements Exception {
  final String orderId;
  final OrderStatus expected;
  final OrderStatus actual;

  InvalidOrderStateException({required this.orderId, required this.expected, required this.actual});

  @override
  String toString() => 'Order $orderId expected $expected but was $actual';
}
