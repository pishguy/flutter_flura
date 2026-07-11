import 'package:test/test.dart';
import 'package:flura_core/flura_core.dart';

void main() {
  group('FluraScope', () {
    test('createScope returns a child container', () {
      final root = DefaultFluraContainer();
      final scope = root.createScope();
      expect(scope, isA<FluraScope>());
    });

    test('scope inherits from parent', () {
      final root = DefaultFluraContainer();
      root.instance<String>('root-value');
      final scope = root.createScope();
      expect(scope.resolve<String>(), 'root-value');
    });

    test('scope can override parent bindings', () {
      final root = DefaultFluraContainer();
      root.instance<String>('root-value');
      final scope = root.createScope();
      scope.instance<String>('scope-value');
      expect(scope.resolve<String>(), 'scope-value');
      expect(root.resolve<String>(), 'root-value');
    });

    test('dispose cleans scope registrations only', () {
      final root = DefaultFluraContainer();
      root.instance<String>('root');

      final scope = root.createScope();
      scope.instance<int>(42);

      scope.dispose();
      expect(() => scope.resolve<int>(), throwsA(isA<ServiceNotFoundException>()));
      expect(scope.resolve<String>(), 'root');
    });

    test('nested scopes resolve in correct order', () {
      final root = DefaultFluraContainer();
      root.instance<String>('root');

      final scope1 = root.createScope();
      scope1.instance<String>('scope1');

      final scope2 = scope1.createScope();

      expect(scope2.resolve<String>(), 'scope1');
    });
  });
}
