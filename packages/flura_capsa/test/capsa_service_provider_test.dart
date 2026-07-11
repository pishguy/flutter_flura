import 'package:flutter_test/flutter_test.dart';
import 'package:flura_core/flura_core.dart';
import 'package:flura_capsa/flura_capsa.dart';

void main() {
  group('CapsaServiceProvider', () {
    testWidgets('register enables CapsaLogger', (tester) async {
      final container = DefaultFluraContainer();
      final provider = CapsaServiceProvider();

      provider.register(container);

      expect(CapsaLogger.enabled, true);

      await provider.shutdown(container);
    });

    testWidgets('shutdown disables CapsaLogger', (tester) async {
      final container = DefaultFluraContainer();
      final provider = CapsaServiceProvider();

      provider.register(container);
      expect(CapsaLogger.enabled, true);

      await provider.shutdown(container);
      expect(CapsaLogger.enabled, false);
    });

    testWidgets('works with FluraApplication', (tester) async {
      final app = FluraApplication(
        config: FluraConfig.test,
        providers: [
          CapsaServiceProvider(),
        ],
      );

      await app.bootstrap();
      expect(app.isBootstrapped, true);
      await app.shutdown();
    });
  });
}
