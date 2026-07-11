import 'dart:async';

import 'package:test/test.dart';
import 'package:flura_core/flura_core.dart';

class TestService {
  final String id;
  TestService(this.id);
}

class SimpleProvider extends FluraServiceProvider {
  @override
  void register(FluraContainer container) {
    container.instance<TestService>(TestService('simple'));
  }
}

class BootOrderProvider extends FluraServiceProvider {
  final List<String> log;

  BootOrderProvider(this.log);

  @override
  FutureOr<void> boot(FluraResolver resolver) {
    log.add(name);
  }
}

class ShutdownOrderProvider extends FluraServiceProvider {
  final List<String> log;
  final String label;

  ShutdownOrderProvider(this.log, {required this.label});

  @override
  String get name => label;

  @override
  FutureOr<void> shutdown(FluraResolver resolver) {
    log.add(label);
  }
}

class FailingBootProvider extends FluraServiceProvider {
  @override
  FutureOr<void> boot(FluraResolver resolver) {
    throw Exception('boot failure');
  }
}

void main() {
  group('FluraApplication', () {
    test('creates with default config', () {
      final app = FluraApplication();
      expect(app.config.name, 'DevApp');
      expect(app.isBootstrapped, false);
    });

    test('creates with custom config', () {
      final app = FluraApplication(
        config: const FluraConfig(name: 'MyApp', environment: FluraEnvironment.production),
      );
      expect(app.config.name, 'MyApp');
      expect(app.config.environment, FluraEnvironment.production);
    });

    test('bootstrap registers and boots providers', () async {
      final app = FluraApplication(providers: [SimpleProvider()]);
      await app.bootstrap();
      expect(app.isBootstrapped, true);
      expect(app.resolve<TestService>().id, 'simple');
    });

    test('duplicate bootstrap throws', () async {
      final app = FluraApplication(providers: [SimpleProvider()]);
      await app.bootstrap();
      await expectLater(
        () => app.bootstrap(),
        throwsA(isA<BootstrapAlreadyAttemptedException>()),
      );
    });

    test('provider boot failure throws FluraBootstrapException with context', () async {
      final app = FluraApplication(providers: [
        SimpleProvider(),
        FailingBootProvider(),
      ]);
      await expectLater(
        () => app.bootstrap(),
        throwsA(isA<FluraBootstrapException>().having(
          (e) => e.phase,
          'phase',
          FluraBootstrapPhase.boot,
        )),
      );
    });

    test('onBoot callback is called after bootstrap', () async {
      final app = FluraApplication(providers: [SimpleProvider()]);
      var called = false;
      app.onBoot((_) async => called = true);
      await app.bootstrap();
      expect(called, true);
    });

    test('shutdown calls providers in reverse order', () async {
      final log = <String>[];
      final app = FluraApplication(providers: [
        ShutdownOrderProvider(log, label: 'ProviderA'),
        ShutdownOrderProvider(log, label: 'ProviderB'),
      ]);
      await app.bootstrap();
      await app.shutdown();
      expect(log, ['ProviderB', 'ProviderA']);
    });

    test('onShutdown callback is called', () async {
      final app = FluraApplication(providers: [SimpleProvider()]);
      var called = false;
      app.onShutdown((_) async => called = true);
      await app.bootstrap();
      await app.shutdown();
      expect(called, true);
    });

    test('config environment helpers', () {
      expect(FluraEnvironment.development.isDevelopment, true);
      expect(FluraEnvironment.production.isProduction, true);
      expect(FluraEnvironment.test.isTest, true);
      expect(FluraEnvironment.staging.isStaging, true);
    });

    test('config custom values', () {
      final config = const FluraConfig(custom: {'key': 'value', 'num': 42});
      expect(config.get<String>('key'), 'value');
      expect(config.get<int>('num'), 42);
      expect(config.getOrNull<String>('missing'), null);
      expect(config.has('key'), true);
      expect(config.has('missing'), false);
    });

    test('test config preset', () {
      final config = FluraConfig.test;
      expect(config.environment, FluraEnvironment.test);
      expect(config.debugLogging, false);
    });
  });
}
