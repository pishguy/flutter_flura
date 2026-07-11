<table>
<tr>
<td width="50%"><img src="logo.png" width="300" alt="Flura"></td>
<td width="50%" valign="middle">

## Flura

Flura is an **application meta-framework** for Dart and Flutter that orchestrates reactive state management, embedded database, DI, and facade contracts into a single, coherent application architecture.

</td>
</tr>
</table>

<div align="center">
  <strong>English</strong> | <a href="README.fa.md">فارسی</a>
</div>

---

**Flura** doesn't reinvent the wheel — it integrates battle-tested libraries (Capsa, UmayDB, Flutter Facades) under a **unified lifecycle**, a **shared DI abstraction**, and an **ordered provider pipeline** with safe rollback on failure.

If you've ever had to wrangle three separate DI systems with incompatible lifecycles and no shared bootstrap, Flura is for you.

---

## The Problem Flura Solves

```
Without Flura:
  ┌──────────┐   ┌──────────┐   ┌──────────┐
  │  Capsa   │   │ UmayDB   │   │ Facades  │
  │ UltraDI  │   │ (none)   │   │ SimpleDI │
  │ mvvm     │   │ db boxes │   │ contracts│
  └────┬─────┘   └────┬─────┘   └────┬─────┘
       │              │              │
       │   No shared lifecycle       │
       │   No unified bootstrap      │
       │   No coordinated shutdown   │
       └──────────────┼──────────────┘
                      ▼
               Developer chaos

With Flura:
  ┌──────────────────────────────────────┐
  │          FluraApplication            │
  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌────┐ │
  │  │ Core │ │DB    │ │Facade│ │Capsa│ │
  │  │Prov. │ │Prov. │ │Prov. │ │Prov.│ │
  │  └──────┘ └──────┘ └──────┘ └────┘ │
  │  Shared lifecycle                   │
  │  Ordered bootstrap + shutdown       │
  │  Unified DI (FluraContainer)        │
  └──────────────────────────────────────┘
```

## Packages

Flura is a **monorepo** — seven packages under a single roof:

| Package | Type | Description |
|---------|------|-------------|
| **flura_core** | Pure Dart | Application kernel: lifecycle, DI container, service providers, config, exceptions — **zero dependencies** |
| **flura_flutter** | Flutter | WidgetsFlutterBinding init, `runApp` integration, `FluraAppWidget`, error handlers |
| **flura_facades** | Pure Dart | Bridges Flura DI → `FacadeRuntime` from `flutter_facades` |
| **flura_umay** | Pure Dart | Manages UmayDB box lifecycle (open/close/compact) within Flura bootstrap |
| **flura_capsa** | Flutter | Wires Capsa logger, enables `ScreenModel`/`Signal`/`ReactiveList` in Flura apps |
| **flura_testing** | Pure Dart | `FakeApplication`, `ContainerOverrides` — fast, isolated test helpers |
| **flura** | Flutter | Umbrella package — single import re-exports all of the above |

```
flura (umbrella — Flutter)
  ├── flura_core (Pure Dart)              ← zero dependencies
  ├── flura_flutter (Flutter)
  │     └── flura_core
  ├── flura_facades (Pure Dart)
  │     ├── flura_core
  │     └── flutter_facades [external]
  ├── flura_umay (Pure Dart)
  │     ├── flura_core
  │     └── umay_db [external]
  ├── flura_capsa (Flutter)
  │     ├── flura_core
  │     └── capsa [external]
  └── flura_testing (Pure Dart)
        ├── flura_core
        └── flutter_facades [external]
```

### External libraries (integrated, NOT part of Flura)

| Library | Version | Role |
|---------|---------|------|
| [capsa](https://github.com/pishguy/capsa) | 1.0.2 | Reactive engine (`Signal`, `Computed`, `Effect`), MVVM (`ScreenModel`), reactive widgets |
| [umay_db](https://github.com/pishguy/umay) | 1.2.0 | Embedded NoSQL database with Active Record ORM, indexes, relations, reactive queries |
| [flutter_facades](https://github.com/pishguy/flutter_facades) | 0.1.0 | Static facade contracts (`AppLogger`, `AppHttpClient`, `CacheStore`, `AuthManager`) |

---

## Features

- **Unified Lifecycle** — `created → bootstrapping → bootstrapped → ready → shuttingDown → shutdown` with safe rollback on failure
- **Ordered Service Providers** — `register()` (sync bindings) → `boot()` (async init) → `shutdown()` (reverse cleanup)
- **Three Binding Strategies** — `instance<T>()` (eager singleton), `singleton<T>()` (lazy singleton), `factory<T>()` (transient)
- **Scoped DI** — `createScope()` with parent-chain resolution, override, and disposal
- **Safe Bootstrap Rollback** — On failure, all attempted providers are shut down in reverse order; container is preserved for inspection
- **Two-stage Readiness** — `bootstrapped` (providers done) → `ready` (platform handlers installed), with explicit `markReady()`
- **Zero-Dependency Kernel** — `flura_core` has no runtime deps; can be used in pure Dart servers, CLI tools, or tests
- **Config Awareness** — `FluraConfig` with environment presets (`development`, `test`, `production`, `staging`) and type-safe accessors
- **Circular Dependency Detection** — Built into `DefaultFluraContainer` — throws `CircularDependencyException` with full resolution chain
- **Flutter Lifecycle Observation** — `FluraAppWidget` triggers `application.shutdown()` on `AppLifecycleState.detached`
- **Error Handling** — `FlutterError.onError` + `PlatformDispatcher.onError` wired during bootstrap
- **Idempotent Shutdown** — Providers shut down once; double-shutdown is safe
- **Duplicate Registration Protection** — `ServiceAlreadyRegisteredException` on double-bind
- **Test Helpers** — `FakeApplication` for fast bootstrapped tests, `ContainerOverrides` for DI overrides

---

## Getting Started

### Prerequisites

- Dart SDK ^3.10.0
- Flutter SDK (stable)
- [capsa](https://github.com/pishguy/capsa), [umay_db](https://github.com/pishguy/umay), [flutter_facades](https://github.com/pishguy/flutter_facades) (optional — only if using the corresponding integration packages)

### Add dependency

For the umbrella package (recommended):

```yaml
dependencies:
  flura:
    path: path/to/flura/packages/flura
```

Or pick individual packages:

```yaml
dependencies:
  flura_core: ^0.1.0
  flura_flutter: ^0.1.0
  flura_facades: ^0.1.0
  flura_umay: ^0.1.0
  flura_capsa: ^0.1.0
```

---

## Quick Start

### Minimal app (using `fluraRun`)

```dart
import 'package:flutter/material.dart';
import 'package:flura/flura.dart';

void main() => fluraRun(
  app: const MyApp(),
  providers: [
    FluraFacadesServiceProvider(),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Flura')),
      body: const Center(child: Text('Hello Flura!')),
    ),
  );
}
```

### Manual bootstrap (full control)

```dart
import 'package:flutter/material.dart';
import 'package:flura/flura.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final application = FluraApplication(
    config: FluraConfig.development,
    providers: [
      DatabaseServiceProvider(),
      FluraFacadesServiceProvider(),
    ],
  );

  await application.bootstrap();
  application.markReady();

  runApp(FluraAppWidget(
    application: application,
    child: MyApp(container: application.container),
  ));
}
```

---

## Service Providers

Each provider encapsulates a group of related services:

```dart
class DatabaseServiceProvider extends FluraServiceProvider {
  @override
  void register(FluraContainer container) {
    // Phase 1: Synchronous bindings only — no side effects
    container.singleton<Database>((r) => Database());
    container.factory<Repository>((r) => Repository(r.resolve<Database>()));
  }

  @override
  Future<void> boot(FluraResolver resolver) async {
    // Phase 2: Async initialization — databases, network, migrations
    final db = resolver.resolve<Database>();
    await db.open();
    await db.runMigrations();
  }

  @override
  Future<void> shutdown(FluraResolver resolver) async {
    // Phase 3: Cleanup — reverse order of boot
    await resolver.resolve<Database>().close();
  }
}
```

### Registration semantics

| Method | Creates new instance each `resolve`? | Singleton? | When created |
|--------|--------------------------------------|------------|-------------|
| `instance(value)` | No | Yes (eager) | Immediately on `register()` |
| `singleton(factory)` | No | Yes (lazy) | On first `resolve()` |
| `factory(factory)` | Yes | No | Every `resolve()` |

---

## DI Container

### Basic usage

```dart
final root = DefaultFluraContainer();

root.instance<Config>(Config());
root.singleton<Logger>((r) => ConsoleLogger());
root.factory<HttpClient>((r) => DioAdapter(r.resolve<Config>()));

final logger = root.resolve<Logger>();  // singleton — same instance every time
final client = root.resolve<HttpClient>(); // factory — new instance each time
```

### Scope chains (child → parent resolution)

```dart
final child = root.createScope();
child.instance<TenantContext>(tenantContext);
child.singleton<Repository>((r) => TenantRepository(
  tenant: r.resolve<TenantContext>(),     // ← resolved from child
  db: r.resolve<Database>(),              // ← resolved from parent (root)
));

final repo = child.resolve<Repository>(); // found in child
final db = child.resolve<Database>();     // not in child → walks up to parent

await (child as FluraScope).dispose();    // dispose owned bindings only
```

### Circular dependency detection

```dart
root.singleton<A>((r) => A(r.resolve<B>()));
root.singleton<B>((r) => B(r.resolve<A>()));

root.resolve<A>();  // throws CircularDependencyException([A, B, A])
```

### Scope lifecycle

```
root.createScope()
  ├── instance / singleton / factory — bind services
  ├── resolve — walks child → parent chain
  ├── dispose — cleans only owned bindings
  └── parent survives child disposal
```

---

## Lifecycle

### State machine

```
created ──→ bootstrapping ──→ bootstrapped ──→ ready ──→ shuttingDown ──→ shutdown
                │                   │
                ▼                   ▼
              failed              failed
```

### Bootstrap phases

```
bootstrap()
  ├── Phase 1: register()
  │     All providers register bindings (sync, ordered)
  │
  ├── Phase 2: boot()
  │     All providers initialize (async, ordered)
  │     └─ On failure → rollback (reverse shutdown of attempted providers)
  │                     ▸ Container preserved for inspection
  │                     ▸ State → failed
  │                     ▸ FluraBootstrapException thrown
  │
  ├── Phase 3: onBoot() callbacks
  │     Application-level lifecycle hooks
  │
  └── State → bootstrapped

markReady()
  └── State → ready (platform handlers installed)
```

### Shutdown

```dart
shutdown()
  ├── onShutdown() callbacks (reverse order)
  ├── provider shutdown (reverse order)
  ├── container dispose
  └── State → shutdown
```

### Bootstrap failure rollback

```dart
FluraBootstrapException(
  providerName: 'DatabaseServiceProvider',
  phase: FluraBootstrapPhase.boot,
  message: 'Failed to boot provider: Connection refused',
  cause: originalException,
  stackTrace: originalStack,
);
```

On failure:
1. All attempted providers are shut down in **reverse order** (including the failing provider)
2. The **container is NOT disposed** — you can inspect the failed state
3. State → `failed`
4. `FluraBootstrapException` is propagated
5. A second `shutdown()` call is safe — it skips already-rolled-back providers

---

## Flutter Integration

### fluraRun — one-call bootstrap

```dart
void main() => fluraRun(
  app: const MyApp(),
  config: FluraConfig.production,
  providers: [
    FluraFacadesServiceProvider(),
    DatabaseServiceProvider(),
  ],
);
```

### FluraAppWidget

`FluraAppWidget` observes the Flutter `AppLifecycleState` and calls `application.shutdown()` when the app reaches `detached` state:

```dart
FluraAppWidget(
  application: application,
  child: MaterialApp(...),
)
```

---

## Integration Packages

### flura_facades — Facade bridge

Wires Flura's `FluraResolver` to `FacadeRuntime`, making facade contracts (`AppLogger`, `AppHttpClient`, `CacheStore`) resolvable through the same container:

```dart
void main() => fluraRun(
  app: const MyApp(),
  providers: [
    FluraFacadesServiceProvider(),
    MyServiceProvider(),
  ],
);
```

```dart
class MyServiceProvider extends FluraServiceProvider {
  @override
  void boot(FluraResolver resolver) {
    final logger = resolver.resolve<AppLogger>();
    logger.info('App booted successfully');
  }
}
```

### flura_umay — Database lifecycle

Opens UmayDB boxes during `boot()` and closes them during `shutdown()`:

```dart
void main() => fluraRun(
  app: const MyApp(),
  providers: [
    UmayDatabaseServiceProvider(
      config: UmayDatabaseConfig(
        directory: '/data/db',
        boxes: ['users', 'orders'],
        autoOpen: true,
        autoCompact: true,
      ),
    ),
  ],
);

// Later: open additional boxes
final umayProv = container.resolve<UmayDatabaseServiceProvider>();
final box = await umayProv.openBox('analytics');
```

### flura_capsa — Capsa integration

Enables Capsa's logger and connects it to the Flura ecosystem:

```dart
void main() => fluraRun(
  app: const MyApp(),
  providers: [
    CapsaServiceProvider(
      forwarder: (event) {
        // Forward Capsa logs to your logging system
        print('[CAPSA][${event.level}] ${event.message}');
      },
    ),
  ],
);
```

---

## Configuration

```dart
final config = FluraConfig(
  name: 'my_app',
  environment: FluraEnvironment.production,
  debugLogging: false,
  custom: {'api_url': 'https://api.example.com'},
);

config.get<String>('api_url');       // "https://api.example.com"
config.get<int>('timeout', fallback: 30);  // 30
config.has('api_url');               // true

FluraConfig.development;             // Preset: dev defaults
FluraConfig.test;                    // Preset: test defaults
```

---

## Testing

```dart
// Fast bootstrapped test with FakeApplication
final app = await FakeApplication.create(
  providers: [MyServiceProvider()],
);

final service = app.resolve<MyService>();
expect(service, isA<MyService>());

await app.dispose();
```

```dart
// Override services in tests
final container = DefaultFluraContainer();
container.instance<Config>(Config.test());
container.instance<HttpClient>(MockHttpClient());

final service = Service(container.resolve<Config>(), container.resolve<HttpClient>());
```

---

## Exception Reference

| Exception | Thrown when |
|-----------|-------------|
| `FluraException` | Base exception (all others inherit) |
| `ServiceNotFoundException` | `resolve<T>()` finds no binding in scope chain |
| `ServiceAlreadyRegisteredException` | Duplicate `instance` / `singleton` / `factory` call |
| `FluraBootstrapException` | Any provider fails during `register()` or `boot()` — includes phase, provider name, cause |
| `BootstrapAlreadyAttemptedException` | `bootstrap()` called twice |
| `NotBootstrappedException` | Service accessed before bootstrap |
| `CircularDependencyException` | Circular resolution detected — includes the resolution chain |

---

## Architecture Decision Records

| ADR | Decision |
|-----|----------|
| D1 | Package boundaries — separation of concerns |
| D2 | DI abstraction with adapters — not a single implementation |
| D3 | Lifecycle states and flow |
| D4 | Naming conventions across packages |
| D6 | Capsa-UmayDB bridge is a separate package |
| D7 | Separate loggers (CapsaLogger + AppLogger) — no forced bridge |
| D13 | flura_core has ZERO runtime dependencies |
| D14 | DefaultFluraContainer lives in flura_core (essential, not optional) |
| D15 | flura_umay is pure Dart |
| D22 | FacadeRuntime configured by flura_facades |
| D23 | Bootstrap failure triggers safe rollback |
| D30 | Two-stage readiness: bootstrapped → ready |
| D31 | Single-bootstrap application |
| D33 | Rollback does NOT dispose container |
| D36 | Duplicate registration throws (strict mode) |
| D37 | Scope semantics: child → parent resolution, override, dispose |

Full ADRs: [`docs/architecture/`](docs/architecture/)

---

## Example

The [FleetFlow example](examples/fleetflow/) demonstrates a complete multi-tenant service management platform using all Flura packages:

- Multi-tenant DI scopes with `FluraContainer.createScope()`
- Ordered providers for database, dispatch, payment, and notifications
- Capsa `ScreenModel` + UmayDB reactive queries
- Three Flutter UI pages with `UltraBuilder`
- 18 passing tests with fake repositories

```bash
cd examples/fleetflow
flutter pub get
flutter test
```

---

## License

MIT — see [LICENSE](LICENSE)
