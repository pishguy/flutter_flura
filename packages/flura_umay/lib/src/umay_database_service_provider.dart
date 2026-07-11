import 'dart:async';

import 'package:flura_core/flura_core.dart';
import 'package:umay_db/umay_db.dart';

import 'umay_database_config.dart';

class UmayDatabaseServiceProvider extends FluraServiceProvider {
  final List<UmayBox> _boxes = [];

  UmayDatabaseConfig? _config;

  UmayDatabaseServiceProvider({UmayDatabaseConfig? config}) : _config = config;

  @override
  void register(FluraContainer container) {
    // No side effects in register — only type bindings
  }

  @override
  FutureOr<void> boot(FluraResolver resolver) async {
    if (_config == null && resolver.has<FluraConfig>()) {
      final fluraConfig = resolver.resolve<FluraConfig>();
      _config = UmayDatabaseConfig.fromFluraConfig(fluraConfig);
    }

    final config = _config ?? UmayDatabaseConfig.temporary;

    if (config.autoOpen) {
      for (final boxName in config.boxes) {
        final box = await UmayBox.open(boxName, directory: config.directory);
        _boxes.add(box);
      }
    }
  }

  @override
  FutureOr<void> shutdown(FluraResolver resolver) async {
    for (final box in _boxes.reversed) {
      await box.close();
    }
    _boxes.clear();
  }

  Future<UmayBox> openBox(String name) async {
    final config = _config ?? UmayDatabaseConfig.temporary;
    final box = await UmayBox.open(name, directory: config.directory);
    _boxes.add(box);
    return box;
  }

  List<UmayBox> get openBoxes => List.unmodifiable(_boxes);
}
