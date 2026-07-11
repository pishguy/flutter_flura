class FluraException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const FluraException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => 'FluraException: $message';
}

class ServiceNotFoundException extends FluraException {
  final Type type;

  ServiceNotFoundException(this.type)
      : super('No service registered for $type');

  @override
  String toString() => 'ServiceNotFoundException($type): $message';
}

class ServiceAlreadyRegisteredException extends FluraException {
  final Type type;

  ServiceAlreadyRegisteredException(this.type)
      : super('Service already registered for $type');

  @override
  String toString() => 'ServiceAlreadyRegisteredException($type): $message';
}

enum FluraBootstrapPhase { register, boot, bootCallback }

class FluraBootstrapException extends FluraException {
  final FluraBootstrapPhase phase;
  final String providerName;

  FluraBootstrapException({
    required this.phase,
    required this.providerName,
    required String message,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);

  @override
  String toString() =>
      'FluraBootstrapException(phase=$phase, provider=$providerName): $message';
}

class BootstrapAlreadyAttemptedException extends FluraException {
  BootstrapAlreadyAttemptedException()
      : super('Application has already attempted bootstrap. '
            'A FluraApplication permits only one bootstrap attempt. '
            'Create a new application instance to retry.');
}

class NotBootstrappedException extends FluraException {
  NotBootstrappedException()
      : super('Application has not been bootstrapped yet. '
            'Call bootstrap() before accessing services.');
}

class CircularDependencyException extends FluraException {
  final List<Type> chain;

  CircularDependencyException(this.chain)
      : super('Circular dependency detected: ${chain.join(" -> ")}');
}
