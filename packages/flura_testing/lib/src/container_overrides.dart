import 'package:flutter_facades/flutter_facades.dart';

class ContainerOverrides {
  final SimpleContainer _container;

  ContainerOverrides(this._container);

  void overrideWith<T>(T instance) {
    _container.instance<T>(instance);
  }

  void resetOverrides() {
    _container.resetAll();
  }
}
