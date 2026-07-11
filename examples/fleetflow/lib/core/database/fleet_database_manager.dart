import 'package:umay_db/umay_db.dart';

import '../models/enums.dart';
import '../models/service_order.dart';
import '../models/technician_location.dart';
import '../models/payment.dart';

class FleetDatabaseManager {
  final FleetDatabaseConfig config;

  final Map<String, UmayBox> _tenantBoxes = {};
  late final UmayBox _defaultBox;

  FleetDatabaseManager({required this.config});

  Future<void> openCoreBoxes() async {
    _defaultBox = await UmayBox.open('fleetflow_core');
  }

  Future<void> openTenant(String tenantId) async {
    if (_tenantBoxes.containsKey(tenantId)) return;
    final box = await UmayBox.open('tenant_${tenantId}_main');
    _tenantBoxes[tenantId] = box;
  }

  UmayBox boxForTenant(String tenantId) {
    final box = _tenantBoxes[tenantId];
    if (box == null) throw StateError('Tenant database not open: $tenantId');
    return box;
  }

  Future<void> close() async {
    for (final box in _tenantBoxes.values) {
      await box.close();
    }
    _tenantBoxes.clear();
    await _defaultBox.close();
  }

  Future<void> runMigrations() async {}

  Future<void> registerModels() async {
    await openCoreBoxes();
    UmayModel.register<ServiceOrder>(() => ServiceOrder(
          id: '',
          tenantId: '',
          customerId: '',
          serviceId: '',
          status: OrderStatus.draft,
          paymentStatus: PaymentStatus.pending,
          serviceAddress: '',
          scheduledAt: DateTime.now(),
          estimatedPrice: 0,
          version: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ), box: _defaultBox);
    UmayModel.register<TechnicianLocation>(() => TechnicianLocation(
          id: '',
          tenantId: '',
          technicianId: '',
          latitude: 0,
          longitude: 0,
          accuracy: 0,
          recordedAt: DateTime.now(),
        ), box: _defaultBox);
    UmayModel.register<Payment>(() => Payment(
          id: '',
          tenantId: '',
          orderId: '',
          amount: 0,
          currency: '',
          status: PaymentStatus.pending,
        ), box: _defaultBox);
  }
}

class FleetDatabaseConfig {
  final String rootPath;
  final bool enableCompaction;
  final Duration compactionInterval;

  const FleetDatabaseConfig({
    required this.rootPath,
    this.enableCompaction = true,
    this.compactionInterval = const Duration(minutes: 1),
  });
}
