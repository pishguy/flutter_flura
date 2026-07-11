import '../datasource/todo_datasource.dart';
import '../model/todo_model.dart';

class TodoRepository {
  final TodoDatasource _datasource;

  TodoRepository(this._datasource);

  Future<List<TodoModel>> getAll() => _datasource.getAll();

  Future<void> add(TodoModel todo) => _datasource.insert(todo);

  Future<void> toggle(TodoModel todo) async {
    todo.completed = !todo.completed;
    await _datasource.update(todo);
  }

  Future<void> remove(String id) => _datasource.delete(id);

  Future<void> clearCompleted(List<TodoModel> todos) async {
    for (final t in todos.where((t) => t.completed)) {
      await _datasource.delete(t.id);
    }
  }
}
