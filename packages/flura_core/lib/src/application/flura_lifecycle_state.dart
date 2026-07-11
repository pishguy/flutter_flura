enum FluraLifecycleState {
  created,
  bootstrapping,
  bootstrapped,
  ready,
  shuttingDown,
  shutdown,
  failed;

  bool get isCreated => this == FluraLifecycleState.created;
  bool get isBootstrapping => this == FluraLifecycleState.bootstrapping;
  bool get isBootstrapped => this == FluraLifecycleState.bootstrapped;
  bool get isReady => this == FluraLifecycleState.ready;
  bool get isShuttingDown => this == FluraLifecycleState.shuttingDown;
  bool get isShutdown => this == FluraLifecycleState.shutdown;
  bool get isFailed => this == FluraLifecycleState.failed;
  bool get isAtLeastBootstrapped =>
      index >= FluraLifecycleState.bootstrapped.index;
}
