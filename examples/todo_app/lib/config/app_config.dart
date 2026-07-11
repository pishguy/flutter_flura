import 'package:flura/flura.dart';

FluraConfig createAppConfig() {
  return FluraConfig(
    name: 'TodoApp',
    environment: FluraEnvironment.development,
    debugLogging: true,
    custom: {
      'database.directory': './todo_data',
      'app.version': '1.0.0',
    },
  );
}
