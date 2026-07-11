import '../models/payment.dart';
import '../database/fleet_database_manager.dart';

abstract interface class PaymentRepository {
  Future<void> save(Payment payment);
  Future<Payment?> findPendingByOrder(String orderId);
}

class TenantPaymentRepository implements PaymentRepository {
  final String tenantId;
  final FleetDatabaseManager database;

  TenantPaymentRepository({required this.tenantId, required this.database});

  @override
  Future<void> save(Payment payment) async {
    await database.boxForTenant(tenantId).put(payment.id, payment.toMap());
  }

  @override
  Future<Payment?> findPendingByOrder(String orderId) async {
    final results = await database.boxForTenant(tenantId).query<Payment>().where((p) => (p as dynamic).orderId.eq(orderId)).find();
    if (results.isEmpty) return null;
    return results.first;
  }
}
