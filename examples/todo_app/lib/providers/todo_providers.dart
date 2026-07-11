import 'package:flura/flura.dart';
import '../features/todo/datasource/todo_datasource.dart';
import '../features/todo/repository/todo_repository.dart';
import '../features/todo/business/todo_business.dart';

class TodoServiceProvider extends FluraServiceProvider {
  @override
  void register(FluraContainer container) {
    container.singleton<TodoDatasource>((r) => TodoDatasource());
    container.singleton<TodoRepository>((r) => TodoRepository(r.resolve<TodoDatasource>()));
    container.singleton<TodoBusiness>((r) => TodoBusiness(r.resolve<TodoRepository>()));
  }
}
