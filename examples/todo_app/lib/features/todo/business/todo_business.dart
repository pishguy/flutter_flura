import '../model/todo_model.dart';
import '../repository/todo_repository.dart';

class TodoBusiness {
  final TodoRepository _repository;

  TodoBusiness(this._repository);

  Future<List<TodoModel>> loadTodos() => _repository.getAll();

  Future<TodoModel> addTodo(String title) async {
    final todo = TodoModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
    );
    await _repository.add(todo);
    return todo;
  }

  Future<void> toggleTodo(TodoModel todo) => _repository.toggle(todo);

  Future<void> deleteTodo(String id) => _repository.remove(id);

  Future<void> clearCompleted(List<TodoModel> todos) =>
      _repository.clearCompleted(todos);
}
