import 'dart:async';

import 'flura_resolver.dart';

typedef FluraFactory<T> = T Function(FluraResolver resolver);

abstract interface class FluraContainer implements FluraResolver {
  void instance<T>(T value);

  void singleton<T>(FluraFactory<T> factory);

  void factory<T>(FluraFactory<T> factory);

  FluraContainer createScope();
}

abstract interface class FluraScope extends FluraContainer {
  @override
  FluraScope createScope();

  FutureOr<void> dispose();
}

abstract interface class FluraOverridableContainer
    implements FluraContainer {
  void replace<T>(FluraFactory<T> factory);
  void replaceInstance<T>(T value);
}
