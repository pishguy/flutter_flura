import 'package:test/test.dart';
import 'package:flura_core/flura_core.dart';
import 'package:flura_testing/flura_testing.dart';

class TestService {
  final String id;
  TestService(this.id);
}

class TestProvider extends FluraServiceProvider {
  @override
  void register(FluraContainer container) {
    container.instance<TestService>(TestService('test'));
  }
}

void main() {
  group('FakeApplication', () {
    test('creates and bootstraps', () async {
      final fake = await FakeApplication.create(providers: [TestProvider()]);
      expect(fake.application.isBootstrapped, true);
      expect(fake.resolve<TestService>().id, 'test');
      await fake.dispose();
    });

    test('uses test config by default', () async {
      final fake = await FakeApplication.create();
      expect(fake.application.config.environment, FluraEnvironment.test);
      await fake.dispose();
    });

    test('shutdown disposes cleanly', () async {
      final fake = await FakeApplication.create();
      await fake.dispose();
      expect(fake.application.isShutdown, true);
    });
  });
}
