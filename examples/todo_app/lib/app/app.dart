import 'package:flutter/material.dart';
import 'package:flura/flura.dart';
import '../config/app_config.dart';
import '../features/todo/business/todo_business.dart';
import '../features/todo/screen_model/todo_screen_model.dart';
import '../features/todo/view/todo_screen.dart';
import '../providers/todo_providers.dart';

class TodoApp extends StatefulWidget {
  final FluraApplication application;

  const TodoApp({super.key, required this.application});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late final Future<TodoScreenModel> _screenModelFuture = _init();

  Future<TodoScreenModel> _init() async {
    final app = widget.application;
    final business = app.resolve<TodoBusiness>();
    return TodoScreenModel(business);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TodoScreenModel>(
      future: _screenModelFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MaterialApp(
          title: 'Flura Todo',
          home: TodoScreen(model: snapshot.requireData),
        );
      },
    );
  }
}

Future<void> main() async {
  final app = FluraApplication(
    config: createAppConfig(),
    providers: [
      FluraFacadesServiceProvider(),
      TodoServiceProvider(),
    ],
  );

  FlutterBootstrap.ensureInitialized();
  await app.bootstrap();

  runApp(
    FluraAppWidget(
      application: app,
      child: TodoApp(application: app),
    ),
  );
}
