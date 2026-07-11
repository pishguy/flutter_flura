import 'dart:io';

import 'package:test/test.dart';
import 'package:flura_core/flura_core.dart';
import 'package:flura_umay/flura_umay.dart';
import 'package:umay_db/umay_db.dart';

void main() {
  setUpAll(() {
    TypeRegistry.registerAdapter(MapAdapter());
  });

  group('UmayDatabaseServiceProvider', () {
    test('registers with FluraApplication', () async {
      final app = FluraApplication(
        config: const FluraConfig(
          name: 'TestApp',
          environment: FluraEnvironment.test,
          databaseDirectory: '.',
        ),
        providers: [
          UmayDatabaseServiceProvider(
            config: const UmayDatabaseConfig(
              directory: '.',
              boxes: ['test_box'],
              autoOpen: false,
            ),
          ),
        ],
      );

      await app.bootstrap();
      await app.shutdown();
    });

    test('opens boxes on boot', () async {
      final provider = UmayDatabaseServiceProvider(
        config: const UmayDatabaseConfig(
          directory: '.',
          boxes: [],
          autoOpen: false,
        ),
      );

      final box = await provider.openBox('test_box_${DateTime.now().millisecondsSinceEpoch}');
      expect(box, isA<UmayBox>());
      await box.close();
    });

    test('shutdown closes all boxes', () async {
      final dir = Directory.systemTemp.createTempSync('umay_test_');
      final provider = UmayDatabaseServiceProvider(
        config: UmayDatabaseConfig(
          directory: dir.path,
          boxes: ['box_a', 'box_b'],
          autoOpen: true,
        ),
      );

      final container = DefaultFluraContainer();
      provider.register(container);
      await provider.boot(container);
      expect(provider.openBoxes.length, 2);

      await provider.shutdown(container);
      expect(provider.openBoxes.length, 0);
    });
  });
}
