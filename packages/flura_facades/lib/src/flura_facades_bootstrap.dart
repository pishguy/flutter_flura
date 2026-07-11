import 'package:flutter_facades/flutter_facades.dart';

class FluraFacadesBootstrap {
  FluraFacadesBootstrap._();

  static void registerDefaults(SimpleContainer container) {
    final provider = DefaultFacadeServiceProvider();
    provider.register(container);
  }
}
