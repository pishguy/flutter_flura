import 'dart:async';

import 'package:test/test.dart';
import 'package:flura_core/flura_core.dart';

class TestService {
  final String id;
  TestService(this.id);
}

class TestProvider extends FluraServiceProvider {
  final List<String> log;

  TestProvider(this.log);

  @override
  void register(FluraContainer container) {
    log.add('register');
    container.instance<TestService>(TestService('provider'));
  }

  @override
  FutureOr<void> boot(FluraResolver resolver) {
    log.add('boot');
  }

  @override
  FutureOr<void> shutdown(FluraResolver resolver) {
    log.add('shutdown');
  }
}

class BootFailingProvider extends FluraServiceProvider {
  @override
  FutureOr<void> boot(FluraResolver resolver) {
    throw Exception('boot failure');
  }
}

void main() {
  group('FluraServiceProvider', () {
    test('register and boot are called in order', () async {
      final log = <String>[];
      final provider = TestProvider(log);
      final container = DefaultFluraContainer();

      provider.register(container);
      await provider.boot(container);

      expect(log, ['register', 'boot']);
    });

    test('shutdown is called', () async {
      final log = <String>[];
      final provider = TestProvider(log);
      final container = DefaultFluraContainer();

      provider.register(container);
      await provider.boot(container);
      await provider.shutdown(container);

      expect(log, ['register', 'boot', 'shutdown']);
    });

    test('services registered by provider are resolvable', () async {
      final provider = TestProvider([]);
      final container = DefaultFluraContainer();

      provider.register(container);
      final service = container.resolve<TestService>();
      expect(service.id, 'provider');
    });
  });
}
