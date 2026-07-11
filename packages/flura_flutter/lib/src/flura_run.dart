import 'package:flutter/material.dart';
import 'package:flura_core/flura_core.dart';

import 'flutter_bootstrap.dart';
import 'flura_app_widget.dart';

Future<void> fluraRun({
  required Widget app,
  FluraConfig? config,
  List<FluraServiceProvider> providers = const [],
  FluraContainer? container,
}) async {
  FlutterBootstrap.ensureInitialized();

  final application = FluraApplication(
    config: config,
    providers: providers,
    container: container,
  );

  FlutterBootstrap.installErrorHandlers(application);

  await application.bootstrap();

  runApp(
    FluraAppWidget(
      application: application,
      child: app,
    ),
  );
}
