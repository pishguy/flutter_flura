import '../models/technician_location.dart';
import '../database/fleet_database_manager.dart';

abstract interface class TechnicianRepository {
  Future<List<dynamic>> findAvailableNear({required String address, required DateTime at});
  Stream<List<TechnicianLocation>> watchActiveTechnicians();
}

class TenantTechnicianRepository implements TechnicianRepository {
  final String tenantId;
  final FleetDatabaseManager database;

  TenantTechnicianRepository({required this.tenantId, required this.database});

  @override
  Future<List<dynamic>> findAvailableNear({required String address, required DateTime at}) async {
    return [];
  }

  @override
  Stream<List<TechnicianLocation>> watchActiveTechnicians() {
    return database.boxForTenant(tenantId).query<TechnicianLocation>().watch().map((items) => items.cast<TechnicianLocation>());
  }
}
