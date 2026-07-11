import 'package:flutter_test/flutter_test.dart';
import 'package:flura_flutter/flura_flutter.dart';

void main() {
  group('FlutterBootstrap', () {
    testWidgets('ensureInitialized works', (tester) async {
      FlutterBootstrap.ensureInitialized();
      // Should not throw
    });

    testWidgets('installErrorHandlers does not throw', (tester) async {
      final app = FluraApplication(
        config: FluraConfig.test,
      );
      await app.bootstrap();

      FlutterBootstrap.installErrorHandlers(app);
      // Should not throw
    });
  });
}
