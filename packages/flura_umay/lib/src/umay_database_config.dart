import 'dart:io';

import 'package:flura_core/flura_core.dart';

class UmayDatabaseConfig {
  final String directory;
  final List<String> boxes;
  final bool autoOpen;
  final bool autoCompact;

  const UmayDatabaseConfig({
    required this.directory,
    this.boxes = const [],
    this.autoOpen = true,
    this.autoCompact = true,
  });

  static UmayDatabaseConfig fromFluraConfig(FluraConfig config) {
    final dir = config.databaseDirectory ??
        '${Directory.current.path}/${config.name}_data';
    return UmayDatabaseConfig(
      directory: dir,
      boxes: [],
      autoOpen: true,
      autoCompact: !config.environment.isTest,
    );
  }

  static UmayDatabaseConfig get temporary {
    final dir = Directory.systemTemp.createTempSync('flura_umay_');
    return UmayDatabaseConfig(
      directory: dir.path,
      autoCompact: false,
    );
  }
}
