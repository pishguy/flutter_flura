import 'dart:async';

import 'package:flura/flura.dart';

import '../core/models/technician_location.dart';
import '../core/database/fleet_database_manager.dart';

class TechnicianTrackingService {
  final FleetDatabaseManager database;
  final AppLogger logger;
  Timer? _timer;

  TechnicianTrackingService({required this.database, required this.logger});

  void startTracking(String tenantId, String technicianId) {
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) => _poll(tenantId, technicianId));
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll(String tenantId, String technicianId) async {
    try {
      final box = database.boxForTenant(tenantId);
      await box.query<TechnicianLocation>().where((l) => (l as dynamic).technicianId.eq(technicianId)).limit(1).find();
    } catch (error) {
      logger.error('Tracking poll failed', error: error);
    }
  }
}
