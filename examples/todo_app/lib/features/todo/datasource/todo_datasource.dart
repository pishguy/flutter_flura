import '../model/todo_model.dart';

class TodoDatasource {
  final List<TodoModel> _items = [];

  Future<List<TodoModel>> getAll() async => List.unmodifiable(_items);

  Future<void> insert(TodoModel todo) async {
    _items.add(todo);
  }

  Future<void> update(TodoModel todo) async {
    final index = _items.indexWhere((t) => t.id == todo.id);
    if (index != -1) _items[index] = todo;
  }

  Future<void> delete(String id) async {
    _items.removeWhere((t) => t.id == id);
  }
}
