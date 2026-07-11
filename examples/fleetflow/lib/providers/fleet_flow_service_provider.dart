import 'dart:io';

import 'package:flura/flura.dart';

import '../core/database/fleet_database_manager.dart';
import '../core/services/clock.dart';
import '../core/services/id_generator.dart';

class FleetFlowServiceProvider extends FluraServiceProvider {
  @override
  void register(FluraContainer container) {
    container
      ..instance<Clock>(SystemClock())
      ..instance<IdGenerator>(UuidIdGenerator());
  }

  @override
  void boot(FluraResolver resolver) async {
    final config = FleetDatabaseConfig(
      rootPath: Directory.systemTemp.path,
      enableCompaction: true,
    );
    final manager = FleetDatabaseManager(config: config);
    await manager.registerModels();
    await manager.openCoreBoxes();
    await manager.runMigrations();
    (resolver as FluraContainer).instance<FleetDatabaseManager>(manager);
  }
}
