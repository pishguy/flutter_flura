<table>
<tr>
<td width="50%"><img src="logo.png" width="300" alt="FleetFlow"></td>
<td width="50%" valign="middle">

## FleetFlow

FleetFlow is a multi-tenant service management platform built on the Flura framework — demonstrating real-world patterns for dispatch, real-time tracking, payments, and support ticketing.

</td>
</tr>
</table>

<div align="center">
  <strong>English</strong> | <a href="README.fa.md">فارسی</a>
</div>

---

FleetFlow is a reference example that validates the Flura architecture under a complex, real-world scenario. It combines patterns from Uber-for-Business, technician dispatch, payment processing, real-time GPS tracking, operator dashboards, and multi-tenant isolation — all within a single Flura application.

## Features

- **Multi-tenant Isolation** — Tenant-scoped DI containers via `FluraContainer.createScope()`, each with its own repositories, services, and database boxes
- **Dispatch Board** — Live feed of open service orders with auto-assignment to available technicians
- **Order State Machine** — 14-state workflow (`draft` → `completed`/`cancelled`/`refunded`) with guard-based transitions
- **Real-time Tracking** — Capsa `ScreenModel` + `ReactiveList<TechnicianLocation>` wired to UmayDB reactive streams
- **Payment Processing** — Idempotent payment flow with gateway integration through `AppHttpClient`
- **Operator Dashboard** — Three Flutter UI pages (`DispatchBoardPage`, `OrderDetailsPage`, `DispatchMapPage`) using Capsa `UltraBuilder`
- **Boot Lifecycle** — `FluraApplication.bootstrap()` with `FluraBootstrapException` rollback protection and `attempted-provider` tracking
- **Capsa + Flura Bridge** — ScreenModels resolved from `FluraContainer` factories; `Signal<T>` / `ReactiveList<T>` for reactive UI
- **Three Apps in Workspace** — `fleetflow_customer`, `fleetflow_technician`, `fleetflow_dispatcher` sharing a single codebase

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     FleetFlow App                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │               FluraApplication                        │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │         Root FluraContainer                      │  │  │
│  │  │  ┌──────────┐  ┌───────────┐  ┌────────────┐  │  │  │
│  │  │  │  Clock   │  │IdGenerator│  │FleetDB Mgmt│  │  │  │
│  │  │  └──────────┘  └───────────┘  └────────────┘  │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  │                         │                             │  │
│  │  ┌──────────────────────▼──────────────────────────┐ │  │
│  │  │           Tenant Child Scope                      │ │  │
│  │  │  ┌──────────┐ ┌──────────────┐ ┌──────────────┐ │ │  │
│  │  │  │ TenantCtx │ │ Repositories │ │Domain Srvcs  │ │ │  │
│  │  │  └──────────┘ └──────────────┘ └──────────────┘ │ │  │
│  │  │  ┌──────────────────────────────────────────────┐│ │  │
│  │  │  │         ScreenModels (Capsa)                  ││ │  │
│  │  │  └──────────────────────────────────────────────┘│ │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │                         │                               │  │
│  │  ┌──────────────────────▼────────────────────────────┐ │  │
│  │  │              Flutter UI (MaterialApp)              │ │  │
│  │  │  ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │ │  │
│  │  │  │ DispatchBoard│ │OrderDetails  │ │DispatchMap │ │ │  │
│  │  │  └──────────────┘ └──────────────┘ └────────────┘ │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Boot flow

```
main()
  └─ FluraApplication(providers: [FleetFlowServiceProvider])
       ├─ FleetFlowServiceProvider.register()
       │    ├─ instance<Clock>(SystemClock)
       │    └─ instance<IdGenerator>(UuidIdGenerator)
       └─ FleetFlowServiceProvider.boot()
            ├─ FleetDatabaseManager.registerModels()
            ├─ FleetDatabaseManager.openCoreBoxes()
            └─ instance<FleetDatabaseManager>(manager)

FluraAppWidget → AppContainer (InheritedWidget) → FleetFlowApp
  └─ FleetFlowApp._boot()
       ├─ AppContainer.of(context) → root container
       ├─ TenantScopeService.createTenantScope(tenantContext)
       │    ├─ child.instance<TenantContext>(...)
       │    ├─ child.singleton<OrderRepository>(...)
       │    ├─ child.singleton<TechnicianRepository>(...)
       │    ├─ child.singleton<PaymentRepository>(...)
       │    ├─ child.factory<OrderStatusTransitionService>(...)
       │    ├─ child.singleton<DispatchService>(...)
       │    └─ child.singleton<PaymentService>(...)
       ├─ _registerScreenModels(scope)
       │    ├─ scope.factory<DispatchBoardScreenModel>(...)
       │    └─ scope.factory<DispatchMapScreenModel>(...)
       └─ AppContainer(container: _tenantScope) → MaterialApp
```

---

## Project Structure

```
lib/
├── main.dart                                    # Boot, AppContainer, FleetFlowApp shell
├── core/
│   ├── database/
│   │   └── fleet_database_manager.dart           # Multi-tenant box management, model registration
│   ├── models/
│   │   ├── enums.dart                            # OrderStatus, PaymentStatus, UserRole
│   │   ├── service_order.dart                    # UmayModel with 14 statuses
│   │   ├── payment.dart                          # UmayModel with PaymentStatus
│   │   ├── user.dart                             # UmayModel with UserRole set
│   │   ├── technician_location.dart              # UmayModel for GPS coordinates
│   │   ├── tenant.dart                           # UmayModel with TenantStatus
│   │   └── support_message.dart                  # UmayModel for chat messages
│   ├── repositories/
│   │   ├── order_repository.dart                 # OrderRepository + TenantOrderRepository
│   │   ├── technician_repository.dart             # TechnicianRepository + impl
│   │   └── payment_repository.dart                # PaymentRepository + impl
│   └── services/
│       ├── clock.dart                            # Clock abstraction + SystemClock
│       ├── id_generator.dart                     # IdGenerator + UuidIdGenerator
│       ├── order_state_machine.dart               # 14-state transition rules
│       └── tenant_context.dart                    # TenantContext + UserPermission guard
├── domain/
│   ├── dispatch_service.dart                     # Auto-assign logic + AssignmentResult
│   ├── payment_service.dart                      # Idempotent payment flow + PaymentResult
│   └── order_status_transition_service.dart        # Guarded state transitions
├── providers/
│   └── fleet_flow_service_provider.dart           # FluraServiceProvider — root DI bindings
├── services/
│   ├── tenant_scope_service.dart                  # Creates tenant-scoped child containers
│   └── technician_tracking_service.dart           # Periodic GPS polling timer
└── ui/
    ├── screen_models/
    │   ├── dispatch_board_screen_model.dart       # Capsa ScreenModel for order list
    │   ├── order_details_screen_model.dart         # Capsa ScreenModel for order detail
    │   └── dispatch_map_screen_model.dart          # Capsa ScreenModel for live map
    └── pages/
        ├── dispatch_board_page.dart               # Open orders list + assign button
        ├── order_details_page.dart                 # Status transitions UI
        └── dispatch_map_page.dart                  # Technician positions list
```

---

## Getting Started

### Prerequisites

- Dart SDK ^3.11.0
- Flutter SDK (stable)
- [UmayDB](https://github.com/pishguy/umay) — embedded NoSQL database
- [Flutter Facades](https://github.com/pishguy/flutter_facades) — facade contracts
- [Flura](https://opencode.ai) — DI + application framework

### Add dependency

```yaml
dependencies:
  flura:
    path: ../../packages/flura
  umay_db:
    path: /path/to/umay_db
  flutter_facades:
    path: /path/to/flutter_facades
```

### Run the dispatcher app

```bash
cd examples/fleetflow
flutter pub get
flutter run
```

### Run tests

```bash
flutter test
```

---

## Models

### ServiceOrder — Full lifecycle

```dart
class ServiceOrder extends UmayModel {
  @override
  dynamic id;
  String tenantId;
  String customerId;
  String? technicianId;
  String serviceId;
  OrderStatus status;
  PaymentStatus paymentStatus;
  String serviceAddress;
  DateTime scheduledAt;
  double estimatedPrice;
  double? finalPrice;
  int version;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Order Status Lifecycle

```
draft ──→ submitted ──→ awaitingPayment ──→ paid
                                              │
                                              ▼
                                         dispatching
                                              │
                                              ▼
                                         assigned
                                              │
                                              ▼
                                     technicianEnRoute
                                              │
                                              ▼
                                          arrived
                                              │
                                              ▼
                                        inProgress
                                              │
                                              ▼
                              awaitingCustomerConfirmation
                                              │
                                   ┌──────────┴──────────┐
                                   ▼                     ▼
                              completed               failed
                              cancelled  ←──── available from most states
                              refunded   ←──── available from paid
```

### State machine guards

```dart
OrderStateMachine.canTransition(from: OrderStatus.draft, to: OrderStatus.submitted); // true
OrderStateMachine.canTransition(from: OrderStatus.draft, to: OrderStatus.completed); // false
OrderStateMachine.canTransition(from: OrderStatus.paid, to: OrderStatus.refunded);   // true
```

---

## Domain Services

### DispatchService

```dart
final result = await dispatchService.autoAssign('ord-001');

switch (result) {
  case AssignmentResult(:final technicianId!):
    print('Assigned to $technicianId');
  case AssignmentResult.noCandidate():
    print('No technicians available');
}
```

The auto-assign flow:
1. Load order, verify `status == dispatching`
2. Query available technicians near the service address
3. Select first candidate, update `status → assigned`, save
4. Return `AssignmentResult`

### PaymentService

```dart
final result = await paymentService.payOrder('ord-001');

switch (result) {
  case PaymentResult.alreadyPaid():   // idempotent — already completed
  case PaymentResult.resume(:final payment):  // resume pending payment
  case PaymentResult.success(:final payment): // new payment completed
}
```

The payment flow:
1. Load order, verify `paymentStatus != paid`
2. Check for existing pending payment (idempotency)
3. Create new `Payment` record
4. POST to payment gateway via `AppHttpClient`
5. Update `Payment.status → paid`, `Order.status → dispatching`
6. Return `PaymentResult`

---

## Multi-tenant Scoping

Each tenant gets its own `FluraContainer` child scope with isolated bindings:

```dart
final scopeService = TenantScopeService(root: root);

final tenantContext = TenantContext(
  tenantId: 'tenant-001',
  userId: 'dispatcher-001',
  roles: {UserRole.dispatcher},
);

final childScope = scopeService.createTenantScope(tenantContext);
```

The child scope binds:
- `TenantContext` — constant instance for permission checks
- `OrderRepository` — scoped to `tenantId` via `TenantOrderRepository`
- `TechnicianRepository` — scoped to `tenantId`
- `PaymentRepository` — scoped to `tenantId`
- `DispatchService` — wired to tenant-scoped repositories
- `PaymentService` — wired to tenant-scoped repository + http + logger
- `OrderStatusTransitionService` — created fresh per request via `factory`

Repositories read/write from tenant-specific UmayDB boxes:

```dart
class TenantOrderRepository implements OrderRepository {
  final String tenantId;
  final FleetDatabaseManager database;

  UmayBox get box => database.boxForTenant(tenantId);
}
```

---

## Capsa ScreenModels

### DispatchBoardScreenModel

```dart
class DispatchBoardScreenModel extends ScreenModel {
  final orders = ReactiveList<ServiceOrder>();
  final isLoading = Signal<bool>(true);
  final error = Signal<String?>(null);

  @override
  void onInit() => loadOrders();

  Future<void> assignTechnician(String orderId) async { ... }
}
```

### OrderDetailsScreenModel

```dart
class OrderDetailsScreenModel extends ScreenModel {
  final order = Signal<ServiceOrder?>(null);
  final actionInProgress = Signal<bool>(false);

  @override
  void onInit() => loadOrder();

  Future<void> advanceStatus(OrderStatus next) async { ... }
}
```

### DispatchMapScreenModel

```dart
class DispatchMapScreenModel extends ScreenModel {
  final technicians = ReactiveList<TechnicianLocation>();

  @override
  void onInit() {
    _subscription = technicianRepository.watchActiveTechnicians().listen(
      (locations) => technicians..clear()..addAll(locations),
    );
  }

  @override
  void onDispose() => _subscription?.cancel();
}
```

---

## Flutter UI Pages

### DispatchBoardPage

Uses `UltraBuilder` to reactively render the list of open orders:

```dart
UltraBuilder(builder: (context) {
  if (_model.isLoading()) return const CircularProgressIndicator();
  if (_model.orders.isEmpty) return const Text('No open orders');
  return ListView.builder(
    itemCount: _model.orders.length,
    itemBuilder: (context, index) {
      final order = _model.orders[index];
      return ListTile(
        title: Text('Order ${order.id}'),
        trailing: ElevatedButton(
          onPressed: () => _model.assignTechnician(order.id),
          child: const Text('Assign'),
        ),
        onTap: () => Navigator.push(..., OrderDetailsPage(orderId: order.id)),
      );
    },
  );
})
```

### OrderDetailsPage

Status transition buttons are generated dynamically from the state machine:

```dart
List<Widget> _statusActions(ServiceOrder order) {
  return _nextStatuses(order.status).map((status) =>
    ElevatedButton(
      onPressed: () => _model.advanceStatus(status),
      child: Text('Move to ${status.name}'),
    ),
  ).toList();
}
```

### DispatchMapPage

Reactive list of technician positions, updated in real-time via `watch()` stream:

```dart
ReactiveBuilder(builder: (context) {
  return ListView.builder(
    itemCount: _model.technicians.length,
    itemBuilder: (context, index) {
      final tech = _model.technicians[index];
      return ListTile(
        title: Text('Technician ${tech.technicianId}'),
        subtitle: Text('${tech.latitude}, ${tech.longitude}'),
      );
    },
  );
})
```

---

## Error Handling & Rollback

During boot, if any provider fails, FluraApplication performs a safe rollback:

1. Attempted providers are tracked in an ordered list
2. On error, `FluraBootstrapException` is thrown with `phase` and `providerName`
3. All attempted providers are shut down in reverse order
4. The container is preserved for inspection
5. The `onError` callback in `main()` receives the exception and stack trace

```dart
// Example: FluraBootstrapException
FluraBootstrapException(
  providerName: 'DatabaseProvider',
  phase: FluraBootstrapPhase.boot,
  message: 'Failed to boot provider: ...',
  cause: originalException,
  stackTrace: originalStack,
);
```

---

## Reactive Bridge (UmayDB → Capsa)

UmayDB reactive queries pipe directly into Capsa `Signal`/`ReactiveList` via the `watch()` method:

```dart
Stream<List<ServiceOrder>> watchDispatchBoard() {
  return box.query<ServiceOrder>()
    .where((o) => (o as dynamic).status.notEqual(OrderStatus.completed.index))
    .watch()
    .map((items) => items.cast<ServiceOrder>());
}
```

```dart
// In ScreenModel:
_subscription = orderRepository.watchDispatchBoard().listen(
  (orders) => this.orders..clear()..addAll(orders),
);
```

---

## Testing

### Test structure

```
test/
├── models/
│   ├── service_order_test.dart              # fromMap/toMap roundtrip, null fields
│   ├── payment_test.dart                    # fromMap/toMap roundtrip, null refs
│   ├── tenant_test.dart                     # fromMap/toMap roundtrip
│   ├── user_test.dart                       # fromMap/toMap roundtrip
│   ├── technician_location_test.dart        # fromMap/toMap roundtrip
│   └── support_message_test.dart            # fromMap/toMap roundtrip
├── domain/
│   ├── dispatch_service_test.dart           # Fake repos, auto-assign logic
│   ├── order_status_transition_service_test.dart  # Valid/invalid transitions
│   └── order_state_machine_test.dart        # All transition rules
```

### Test patterns

```dart
// Fake repositories implement the abstract interface
class FakeOrderRepo implements OrderRepository {
  final Map<String, ServiceOrder> _store = {};

  @override
  Future<ServiceOrder?> findById(String id) async => _store[id];

  @override
  Future<void> save(ServiceOrder order) async => _store[order.id] = order;
  // ...
}

// Fake logger for AppLogger
class FakeLogger implements AppLogger {
  @override
  void debug(String msg, {Map<String, dynamic>? context}) {}
  @override
  Future<void> info(String msg, {Map<String, dynamic>? context}) async {}
}
```

### Running tests

```bash
cd examples/fleetflow
flutter test
# 18/18 tests pass
```

---

## Three-App Workspace

FleetFlow is designed as a three-app workspace sharing a single codebase:

| App | Main File | User Role |
|-----|-----------|-----------|
| **Dispatcher** | `lib/main.dart` | `UserRole.dispatcher` — views open orders, assigns technicians |
| **Customer** | `lib/main_customer.dart` | `UserRole.customer` — creates orders, tracks status, chats with support |
| **Technician** | `lib/main_technician.dart` | `UserRole.technician` — receives assignments, updates location, changes status |

Each app entry point:
1. Boots the same `FluraApplication` with `FleetFlowServiceProvider`
2. Creates a tenant scope with the appropriate `TenantContext`
3. Registers role-specific screen models
4. Renders the role-specific `MaterialApp`

---

## Dependency Graph

```
flura (meta-package)
├─ flura_core         — FluraContainer, FluraApplication, FluraServiceProvider
├─ flura_flutter      — fluraRun(), FluraAppWidget, FlutterBootstrap
├─ flura_facades      — FluraFacadesServiceProvider → AppLogger, AppHttpClient
├─ flura_umay         — UmayDatabaseServiceProvider
└─ flura_capsa        — CapsaServiceProvider → ScreenModel, Signal, ReactiveList, UltraBuilder

umay_db               — UmayBox, UmayModel, LinqQueryBuilder, reactive streams
flutter_facades       — AppLogger, AppHttpClient (abstract contracts)
capsa                 — ScreenModel, Signal<T>, ReactiveList<T>, UltraBuilder
```

---

## License

MIT — see [Flura LICENSE](../../LICENSE)
