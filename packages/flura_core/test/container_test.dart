import 'package:test/test.dart';
import 'package:flura_core/flura_core.dart';

class TestService {
  final String id;
  TestService(this.id);
}

class DisposableService extends FluraDisposable {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  group('DefaultFluraContainer', () {
    late DefaultFluraContainer container;

    setUp(() {
      container = DefaultFluraContainer();
    });

    test('instance binding', () {
      final service = TestService('test');
      container.instance<TestService>(service);
      expect(container.resolve<TestService>(), same(service));
    });

    test('factory binding returns new instance each time', () {
      container.factory<TestService>((_) => TestService('factory'));
      final a = container.resolve<TestService>();
      final b = container.resolve<TestService>();
      expect(a, isNot(same(b)));
    });

    test('singleton binding returns same instance', () {
      container.singleton<TestService>((_) => TestService('singleton'));
      final a = container.resolve<TestService>();
      final b = container.resolve<TestService>();
      expect(a, same(b));
    });

    test('singleton binding returns same instance (lazy)', () {
      container.singleton<TestService>((_) => TestService('lazy'));
      final a = container.resolve<TestService>();
      final b = container.resolve<TestService>();
      expect(a, same(b));
      expect(a.id, 'lazy');
    });

    test('has returns true for registered services', () {
      expect(container.has<TestService>(), false);
      container.instance<TestService>(TestService('a'));
      expect(container.has<TestService>(), true);
    });

    test('resolve throws ServiceNotFoundException for unregistered service', () {
      expect(
        () => container.resolve<TestService>(),
        throwsA(isA<ServiceNotFoundException>()),
      );
    });

    test('throws ServiceAlreadyRegisteredException on duplicate registration', () {
      container.instance<TestService>(TestService('a'));
      expect(
        () => container.instance<TestService>(TestService('b')),
        throwsA(isA<ServiceAlreadyRegisteredException>()),
      );
    });

    test('scope delegates to parent', () {
      container.instance<TestService>(TestService('root'));
      final scope = container.createScope();
      expect(scope.resolve<TestService>().id, 'root');
    });

    test('scope overrides parent', () {
      container.instance<TestService>(TestService('root'));
      final scope = container.createScope();
      scope.instance<TestService>(TestService('scoped'));
      expect(scope.resolve<TestService>().id, 'scoped');
      expect(container.resolve<TestService>().id, 'root');
    });

    test('dispose cleans up singleton instances', () {
      final disposable = DisposableService();
      container.instance<DisposableService>(disposable);
      container.dispose();
      expect(disposable.disposed, true);
    });

    test('detects circular dependencies', () {
      container.factory<TestService>((r) => TestService(r.resolve<TestService>().id));
      expect(
        () => container.resolve<TestService>(),
        throwsA(isA<CircularDependencyException>()),
      );
    });
  });
}
