import 'package:test/test.dart';
import 'package:flura_core/flura_core.dart';
import 'package:flura_facades/flura_facades.dart';

void main() {
  group('FacadeResolverAdapter', () {
    test('resolves from FluraContainer', () {
      final container = DefaultFluraContainer();
      container.instance<String>('test-value');

      final adapter = FacadeResolverAdapter(container);
      expect(adapter.resolve<String>(), 'test-value');
    });

    test('works with FacadeRuntime', () {
      final container = DefaultFluraContainer();
      container.instance<String>('facade-value');

      final adapter = FacadeResolverAdapter(container);
      FacadeRuntime.setRootResolver(adapter);

      expect(app<String>(), 'facade-value');

      FacadeRuntime.reset();
    });
  });

  group('FluraFacadesServiceProvider', () {
    test('sets root resolver in boot', () async {
      final container = DefaultFluraContainer();
      final provider = FluraFacadesServiceProvider();

      provider.register(container);
      await provider.boot(container);

      expect(FacadeRuntime.hasRootResolver, true);

      FacadeRuntime.reset();
    });

    test('shutdown resets FacadeRuntime', () async {
      final container = DefaultFluraContainer();
      final provider = FluraFacadesServiceProvider();

      provider.register(container);
      await provider.boot(container);
      expect(FacadeRuntime.hasRootResolver, true);

      await provider.shutdown(container);
      expect(FacadeRuntime.hasRootResolver, false);

      FacadeRuntime.reset();
    });

    test('facades work through FluraApplication', () async {
      final container = DefaultFluraContainer();
      container.instance<CacheStore>(MemoryCacheStore());

      final provider = FluraFacadesServiceProvider();
      provider.register(container);
      await provider.boot(container);

      await Cache.put('key', 'value');
      final result = await Cache.get<String>('key');
      expect(result, 'value');

      FacadeRuntime.reset();
    });
  });
}
