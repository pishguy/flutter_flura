import 'package:flutter/material.dart';
import 'package:flura_core/flura_core.dart';

class FluraAppWidget extends StatefulWidget {
  final FluraApplication application;
  final Widget child;

  const FluraAppWidget({
    super.key,
    required this.application,
    required this.child,
  });

  @override
  State<FluraAppWidget> createState() => _FluraAppWidgetState();
}

class _FluraAppWidgetState extends State<FluraAppWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      widget.application.shutdown();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
