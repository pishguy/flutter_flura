import 'package:flura_core/flura_core.dart';
import 'package:flutter_facades/flutter_facades.dart';

class FacadeResolverAdapter implements ServiceResolver {
  final FluraResolver _resolver;

  FacadeResolverAdapter(this._resolver);

  @override
  T resolve<T>() => _resolver.resolve<T>();
}
