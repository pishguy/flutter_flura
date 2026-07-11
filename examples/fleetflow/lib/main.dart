import 'package:flutter/material.dart';
import 'package:flura/flura.dart';

import 'core/models/enums.dart';
import 'core/services/tenant_context.dart';
import 'core/repositories/order_repository.dart';
import 'core/repositories/technician_repository.dart';
import 'domain/dispatch_service.dart';
import 'providers/fleet_flow_service_provider.dart';
import 'services/tenant_scope_service.dart';
import 'ui/screen_models/dispatch_board_screen_model.dart';
import 'ui/screen_models/dispatch_map_screen_model.dart';
import 'ui/pages/dispatch_board_page.dart';

final class AppContainer extends InheritedWidget {
  final FluraContainer container;

  const AppContainer({
    super.key,
    required this.container,
    required super.child,
  });

  static FluraContainer of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppContainer>();
    assert(widget != null, 'No AppContainer found in context');
    return widget!.container;
  }

  @override
  bool updateShouldNotify(AppContainer oldWidget) => container != oldWidget.container;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final application = FluraApplication(
    providers: [FleetFlowServiceProvider()],
  );
  await application.bootstrap();
  application.markReady();

  runApp(FluraAppWidget(
    application: application,
    child: AppContainer(
      container: application.container,
      child: const FleetFlowApp(),
    ),
  ));
}

class FleetFlowApp extends StatefulWidget {
  const FleetFlowApp({super.key});

  @override
  State<FleetFlowApp> createState() => _FleetFlowAppState();
}

class _FleetFlowAppState extends State<FleetFlowApp> {
  late final FluraContainer _tenantScope;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final root = AppContainer.of(context);
    final scopeService = TenantScopeService(root: root);

    final tenantContext = TenantContext(
      tenantId: 'tenant-001',
      userId: 'dispatcher-001',
      roles: {UserRole.dispatcher},
    );
    _tenantScope = scopeService.createTenantScope(tenantContext);
    _registerScreenModels(_tenantScope);
    setState(() => _ready = true);
  }

  void _registerScreenModels(FluraContainer scope) {
    scope
      ..factory<DispatchBoardScreenModel>((c) => DispatchBoardScreenModel(
            orderRepository: c.resolve<OrderRepository>(),
            dispatchService: c.resolve<DispatchService>(),
            logger: c.resolve<AppLogger>(),
          ))
      ..factory<DispatchMapScreenModel>((c) => DispatchMapScreenModel(
            technicianRepository: c.resolve<TechnicianRepository>(),
            logger: c.resolve<AppLogger>(),
          ));
  }

  @override
  void dispose() {
    (_tenantScope as FluraScope).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AppContainer(
      container: _tenantScope,
      child: MaterialApp(
        title: 'FleetFlow Dispatcher',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const DispatchBoardPage(),
      ),
    );
  }
}
