import 'dart:async';

import '../../flura_core.dart';

class DefaultFluraContainer implements FluraScope, FluraOverridableContainer {
  final DefaultFluraContainer? _parent;

  final Map<Type, dynamic> _instances = {};
  final Map<Type, FluraFactory> _lazySingletons = {};
  final Map<Type, dynamic> _singletonInstances = {};
  final Map<Type, FluraFactory> _factories = {};
  final Set<Type> _resolving = {};

  DefaultFluraContainer({DefaultFluraContainer? parent}) : _parent = parent;

  @override
  void instance<T>(T value) {
    final type = T;
    _checkNotRegistered(type);
    _instances[type] = value;
  }

  @override
  void singleton<T>(FluraFactory<T> factory) {
    final type = T;
    _checkNotRegistered(type);
    _lazySingletons[type] = factory;
  }

  @override
  void factory<T>(FluraFactory<T> factory) {
    final type = T;
    _checkNotRegistered(type);
    _factories[type] = factory;
  }

  void _checkNotRegistered(Type type) {
    if (_instances.containsKey(type) ||
        _lazySingletons.containsKey(type) ||
        _factories.containsKey(type)) {
      throw ServiceAlreadyRegisteredException(type);
    }
  }

  @override
  T resolve<T>() {
    final type = T;

    if (_resolving.contains(type)) {
      throw CircularDependencyException(_resolving.toList());
    }

    _resolving.add(type);
    try {
      return _resolveInternal<T>(type);
    } finally {
      _resolving.remove(type);
    }
  }

  T _resolveInternal<T>(Type type) {
    if (_instances.containsKey(type)) {
      return _instances[type] as T;
    }

    if (_singletonInstances.containsKey(type)) {
      return _singletonInstances[type] as T;
    }

    final lazyFactory = _lazySingletons[type];
    if (lazyFactory != null) {
      final instance = lazyFactory(this) as T;
      _singletonInstances[type] = instance;
      return instance;
    }

    final factory = _factories[type];
    if (factory != null) {
      return factory(this) as T;
    }

    if (_parent != null) {
      return _parent.resolve<T>();
    }

    throw ServiceNotFoundException(type);
  }

  @override
  bool has<T>() {
    final type = T;
    if (_instances.containsKey(type)) return true;
    if (_singletonInstances.containsKey(type)) return true;
    if (_lazySingletons.containsKey(type)) return true;
    if (_factories.containsKey(type)) return true;
    if (_parent != null) return _parent.has<T>();
    return false;
  }

  @override
  FluraScope createScope() {
    return DefaultFluraContainer(parent: this);
  }

  @override
  FutureOr<void> dispose() {
    for (final entry in _singletonInstances.entries) {
      _maybeDispose(entry.value);
    }
    for (final entry in _instances.entries) {
      _maybeDispose(entry.value);
    }
    _instances.clear();
    _lazySingletons.clear();
    _singletonInstances.clear();
    _factories.clear();
  }

  void _maybeDispose(dynamic obj) {
    if (obj is FluraDisposable) {
      obj.dispose();
    }
  }

  void remove<T>() {
    final type = T;
    final instance = _singletonInstances.remove(type);
    if (instance != null) {
      _maybeDispose(instance);
    }
    _instances.remove(type);
    _lazySingletons.remove(type);
    _factories.remove(type);
  }

  @override
  void replace<T>(FluraFactory<T> factory) {
    final type = T;
    if (!has<T>()) {
      throw ServiceNotFoundException(type);
    }
    remove<T>();
    _lazySingletons[type] = factory;
  }

  @override
  void replaceInstance<T>(T value) {
    final type = T;
    if (!has<T>()) {
      throw ServiceNotFoundException(type);
    }
    remove<T>();
    _instances[type] = value;
  }
}
