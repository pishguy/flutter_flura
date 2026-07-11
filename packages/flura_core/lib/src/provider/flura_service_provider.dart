import 'dart:async';

import '../../flura_core.dart';

abstract class FluraServiceProvider {
  String get name => runtimeType.toString();

  void register(FluraContainer container) {}

  FutureOr<void> boot(FluraResolver resolver) {}

  FutureOr<void> shutdown(FluraResolver resolver) {}
}
