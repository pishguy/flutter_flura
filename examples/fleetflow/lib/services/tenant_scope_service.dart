import 'package:flura/flura.dart';

import '../core/database/fleet_database_manager.dart';
import '../core/repositories/order_repository.dart';
import '../core/repositories/payment_repository.dart';
import '../core/repositories/technician_repository.dart';
import '../core/services/tenant_context.dart';
import '../domain/dispatch_service.dart';
import '../domain/payment_service.dart';
import '../domain/order_status_transition_service.dart';
import '../core/services/id_generator.dart';
import '../core/services/clock.dart';

class TenantScopeService {
  final FluraContainer root;

  TenantScopeService({required this.root});

  FluraContainer createTenantScope(TenantContext context) {
    final child = root.createScope();
    child.instance<TenantContext>(context);

    child.singleton<OrderRepository>((c) => TenantOrderRepository(
          tenantId: context.tenantId,
          database: c.resolve<FleetDatabaseManager>(),
        ));
    child.singleton<TechnicianRepository>((c) => TenantTechnicianRepository(
          tenantId: context.tenantId,
          database: c.resolve<FleetDatabaseManager>(),
        ));
    child.singleton<PaymentRepository>((c) => TenantPaymentRepository(
          tenantId: context.tenantId,
          database: c.resolve<FleetDatabaseManager>(),
        ));

    child.factory<OrderStatusTransitionService>((c) => OrderStatusTransitionService(
          repository: c.resolve<OrderRepository>(),
          logger: c.resolve<AppLogger>(),
        ));

    child.singleton<DispatchService>((c) => DispatchService(
          orders: c.resolve<OrderRepository>(),
          technicians: c.resolve<TechnicianRepository>(),
          logger: c.resolve<AppLogger>(),
          clock: c.resolve<Clock>(),
        ));

    child.singleton<PaymentService>((c) => PaymentService(
          payments: c.resolve<PaymentRepository>(),
          orders: c.resolve<OrderRepository>(),
          http: c.resolve<AppHttpClient>(),
          logger: c.resolve<AppLogger>(),
          ids: c.resolve<IdGenerator>(),
        ));

    return child;
  }
}
