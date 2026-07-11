import 'dart:async';

import 'package:flura_core/flura_core.dart';
import 'package:flutter_facades/flutter_facades.dart';

import 'facade_resolver_adapter.dart';

class FluraFacadesServiceProvider extends FluraServiceProvider {
  FluraFacadesServiceProvider();

  @override
  void register(FluraContainer container) {
    // No side effects in register — only type bindings
  }

  @override
  FutureOr<void> boot(FluraResolver resolver) {
    final facadeResolver = FacadeResolverAdapter(resolver);
    FacadeRuntime.setRootResolver(facadeResolver);

    if (resolver.has<AppLogger>()) {
      resolver.resolve<AppLogger>().info('FluraFacadesServiceProvider booted');
    }
  }

  @override
  FutureOr<void> shutdown(FluraResolver resolver) {
    FacadeRuntime.reset();
  }
}
