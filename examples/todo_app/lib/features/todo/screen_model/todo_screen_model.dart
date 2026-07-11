import 'package:capsa/capsa.dart';
import '../business/todo_business.dart';
import '../model/todo_model.dart';

class TodoScreenModel extends ScreenModel {
  final TodoBusiness _business;

  final todos = Signal<List<TodoModel>>([]);
  final isLoading = Signal(true);

  TodoScreenModel(this._business);

  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  Future<void> loadTodos() async {
    isLoading.value = true;
    try {
      final items = await _business.loadTodos();
      todos.value = items;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) return;
    final todo = await _business.addTodo(title.trim());
    todos.value = [...todos(), todo];
  }

  Future<void> toggleTodo(TodoModel todo) async {
    await _business.toggleTodo(todo);
    todos.value = todos().map((t) {
      if (t.id == todo.id) return todo;
      return t;
    }).toList();
  }

  Future<void> deleteTodo(String id) async {
    await _business.deleteTodo(id);
    todos.value = todos().where((t) => t.id != id).toList();
  }

  Future<void> clearCompleted() async {
    await _business.clearCompleted(todos());
    todos.value = todos().where((t) => !t.completed).toList();
  }
}
