import 'dart:async';

import '../../flura_core.dart';

typedef FluraApplicationCallback = FutureOr<void> Function(FluraApplication app);

class FluraApplication {
  final FluraConfig config;
  final List<FluraServiceProvider> _providers;

  late final FluraContainer container;

  FluraLifecycleState _state = FluraLifecycleState.created;

  final List<FluraApplicationCallback> _bootCallbacks = [];
  final List<FluraApplicationCallback> _shutdownCallbacks = [];

  final Set<FluraServiceProvider> _shutdownProviders = {};

  FluraApplication({
    FluraConfig? config,
    List<FluraServiceProvider> providers = const [],
    FluraContainer? container,
  })  : config = config ?? FluraConfig.development,
        _providers = List.unmodifiable(providers) {
    this.container = container ?? DefaultFluraContainer();
  }

  FluraLifecycleState get state => _state;

  bool get isBootstrapped =>
      _state.isBootstrapped || _state.isReady;
  bool get isShutdown => _state.isShutdown;
  bool get isReady => _state.isReady;

  void onBoot(FluraApplicationCallback callback) {
    _bootCallbacks.add(callback);
  }

  void onShutdown(FluraApplicationCallback callback) {
    _shutdownCallbacks.add(callback);
  }

  Future<void> bootstrap() async {
    if (_state != FluraLifecycleState.created) {
      throw BootstrapAlreadyAttemptedException();
    }

    _state = FluraLifecycleState.bootstrapping;
    final resolver = container as FluraResolver;
    final List<FluraServiceProvider> attempted = [];

    try {
      // Phase 1: Register all providers (synchronous — bindings only, no side effects)
      for (final provider in _providers) {
        try {
          provider.register(container);
        } catch (e, stack) {
          throw FluraBootstrapException(
            providerName: provider.name,
            phase: FluraBootstrapPhase.register,
            message: 'Failed to register provider: $e',
            cause: e,
            stackTrace: stack,
          );
        }
      }

      // Phase 2: Boot all providers (async — side effects: open boxes, run migrations)
      for (final provider in _providers) {
        attempted.add(provider);
        try {
          await provider.boot(resolver);
        } catch (e, stack) {
          throw FluraBootstrapException(
            providerName: provider.name,
            phase: FluraBootstrapPhase.boot,
            message: 'Failed to boot provider: $e',
            cause: e,
            stackTrace: stack,
          );
        }
      }

      // Phase 3: Run boot callbacks
      for (final callback in _bootCallbacks) {
        await callback(this);
      }

      // Phase 4: Mark bootstrapped — platform integrations (e.g. Flutter error handlers)
      // are installed by the specific integration packages (e.g. flura_flutter)
      // before calling markReady().
      _state = FluraLifecycleState.bootstrapped;
    } catch (e) {
      // Rollback: shutdown all attempted providers in reverse order.
      // This includes the provider that failed during boot (partial cleanup)
      // plus all previously-booted providers.
      // Container is NOT disposed during rollback so the caller can inspect state.
      for (final provider in attempted.reversed) {
        if (_shutdownProviders.contains(provider)) continue;
        try {
          await provider.shutdown(resolver);
          _shutdownProviders.add(provider);
        } catch (_) {}
      }
      _state = FluraLifecycleState.failed;
      rethrow;
    }
  }

  void markReady() {
    if (_state != FluraLifecycleState.bootstrapped) {
      throw FluraException(
        'Cannot mark ready: application is in state $_state. '
        'Expected bootstrapped.',
      );
    }
    _state = FluraLifecycleState.ready;
  }

  void fail() {
    if (_state.isFailed) return;
    if (_state.isCreated || _state.isBootstrapping || _state.isShuttingDown || _state.isShutdown) {
      throw FluraException(
        'Cannot fail: application is in state $_state. '
        'Expected bootstrapped or ready.',
      );
    }
    _state = FluraLifecycleState.failed;
  }

  Future<void> shutdown() async {
    if (_state.isShutdown) return;
    if (_state.isBootstrapping) {
      throw FluraException('Cannot shutdown while bootstrapping.');
    }

    _state = FluraLifecycleState.shuttingDown;

    // Phase 1: Run shutdown callbacks (in reverse order)
    for (final callback in _shutdownCallbacks.reversed) {
      await callback(this);
    }

    // Phase 2: Shutdown providers (reverse order), skip already-rolled-back
    for (final provider in _providers.reversed) {
      if (_shutdownProviders.contains(provider)) continue;
      try {
        await provider.shutdown(container);
        _shutdownProviders.add(provider);
      } catch (e) {
        // Log but don't rethrow — all providers should get a chance to shutdown
      }
    }

    // Phase 3: Dispose container
    if (container is FluraScope) {
      await (container as FluraScope).dispose();
    }

    _state = FluraLifecycleState.shutdown;
  }

  T resolve<T>() => container.resolve<T>();

  bool has<T>() => container.has<T>();
}
