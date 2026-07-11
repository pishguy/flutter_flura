import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flura_core/flura_core.dart';

class FlutterBootstrap {
  FlutterBootstrap._();

  static void ensureInitialized() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static void installErrorHandlers(FluraApplication app) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      return true;
    };
  }
}
