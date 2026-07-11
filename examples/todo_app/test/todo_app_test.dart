import 'package:flutter_test/flutter_test.dart';
import 'package:flura/flura.dart';
import 'package:todo_app/features/todo/datasource/todo_datasource.dart';
import 'package:todo_app/features/todo/repository/todo_repository.dart';
import 'package:todo_app/features/todo/business/todo_business.dart';
import 'package:todo_app/features/todo/model/todo_model.dart';
import 'package:todo_app/features/todo/screen_model/todo_screen_model.dart';

void main() {
  group('TodoModel', () {
    test('toMap and fromMap round-trip', () {
      final todo = TodoModel(id: '1', title: 'Test', completed: false);
      final map = todo.toMap();
      final restored = TodoModel.fromMap(map);
      expect(restored.id, '1');
      expect(restored.title, 'Test');
      expect(restored.completed, false);
    });
  });

  group('TodoScreenModel', () {
    test('addTodo updates signal', () async {
      final datasource = TodoDatasource();
      final repository = TodoRepository(datasource);
      final business = TodoBusiness(repository);
      final model = TodoScreenModel(business);

      model.attach();
      expect(model.todos(), isEmpty);

      await model.addTodo('Buy milk');
      expect(model.todos().length, 1);
      expect(model.todos().first.title, 'Buy milk');

      await model.toggleTodo(model.todos().first);
      expect(model.todos().first.completed, true);
    });

    test('deleteTodo removes from signal', () async {
      final datasource = TodoDatasource();
      final repository = TodoRepository(datasource);
      final business = TodoBusiness(repository);
      final model = TodoScreenModel(business);

      model.attach();
      await model.addTodo('Task 1');
      await model.addTodo('Task 2');
      expect(model.todos().length, 2);

      await model.deleteTodo(model.todos().first.id);
      expect(model.todos().length, 1);
    });
  });

  group('Flura container integration', () {
    test('services can be resolved through container', () {
      final container = DefaultFluraContainer();
      container.singleton<TodoDatasource>((r) => TodoDatasource());
      container.singleton<TodoRepository>(
        (r) => TodoRepository(r.resolve<TodoDatasource>()),
      );
      container.singleton<TodoBusiness>(
        (r) => TodoBusiness(r.resolve<TodoRepository>()),
      );

      final business = container.resolve<TodoBusiness>();
      expect(business, isA<TodoBusiness>());
    });
  });
}
