import 'package:flura_core/flura_core.dart';

class FakeApplication {
  late final FluraApplication application;
  late final DefaultFluraContainer container;

  FakeApplication({
    FluraConfig? config,
    List<FluraServiceProvider> providers = const [],
  }) {
    container = DefaultFluraContainer();
    application = FluraApplication(
      config: config ?? FluraConfig.test,
      providers: providers,
      container: container,
    );
  }

  static Future<FakeApplication> create({
    FluraConfig? config,
    List<FluraServiceProvider> providers = const [],
  }) async {
    final fake = FakeApplication(config: config, providers: providers);
    await fake.application.bootstrap();
    return fake;
  }

  T resolve<T>() => application.resolve<T>();

  Future<void> dispose() => application.shutdown();
}
