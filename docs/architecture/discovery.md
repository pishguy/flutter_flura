# Discovery Report — Flura Framework

> Generated: 2026-07-11
> Status: v2 — Codebase analysis + architecture decisions D1–D38. Ready for Phase 1.

---

## 1. Repository Overview

### 1.1 Capsa

| Property | Value |
|----------|-------|
| **Package name** | `capsa` |
| **Version** | `1.0.2` |
| **SDK** | `^3.10.7` |
| **Platform** | Flutter |
| **Location** | `/Users/mahdipishguy/Desktop/projects/flutter/capsa` |
| **Runtime deps** | `flutter`, `flutter_rearch ^1.7.3`, `rearch ^1.16.1` |
| **Build deps** | `build ^4.0.6`, `source_gen ^4.2.3` |
| **Dev deps** | `flutter_test`, `flutter_lints ^6.0.0` |
| **Tests** | ❌ No test directory found |
| **CLI** | `bin/capsa.dart` — feature scaffold generator |
| **Git** | `https://github.com/pishguy/capsa` |

### 1.2 UmayDB

| Property | Value |
|----------|-------|
| **Package name** | `umay_db` |
| **Version** | `1.2.0` |
| **SDK** | `^3.11.0` |
| **Platform** | Pure Dart |
| **Location** | `/Users/mahdipishguy/Desktop/projects/flutter/umay_db` |
| **Runtime deps** | **None** — zero external dependencies |
| **Dev deps** | `lints ^5.0.0`, `test ^1.25.0` |
| **Tests** | 1 test file: `test/umay_box_test.dart` |
| **Git** | `https://github.com/pishguy/umay` |

### 1.3 Flutter Facades

| Property | Value |
|----------|-------|
| **Package name** | `flutter_facades` |
| **Version** | `0.1.0` |
| **SDK** | `>=3.0.0 <4.0.0` |
| **Platform** | Pure Dart |
| **Location** | `/Users/mahdipishguy/Desktop/projects/flutter/flutter_facades` |
| **Runtime deps** | **None** — zero external dependencies |
| **Dev deps** | `test ^1.25.0`, `lints ^4.0.0` |
| **Tests** | 6 test files |
| **Git** | `https://github.com/pishguy/flutter_facades` |

---

## 2. Dependency Graph

```
capsa (Flutter)
  ├── flutter (SDK)
  ├── flutter_rearch ^1.7.3
  │   └── rearch ^1.16.1
  ├── build ^4.0.6
  └── source_gen ^4.2.3

umay_db (Pure Dart)
  └── NO RUNTIME DEPENDENCIES

flutter_facades (Pure Dart)
  └── NO RUNTIME DEPENDENCIES
```

No existing dependencies between Capsa, UmayDB, and Flutter Facades.

### Flura Integration Package Dependencies

```
flura (Flutter umbrella)
  ├── flura_core (Pure Dart)            ← zero runtime deps
  ├── flura_flutter (Flutter)
  │   └── flura_core
  ├── flura_facades (Pure Dart)
  │   ├── flura_core
  │   └── flutter_facades
  ├── flura_umay (Pure Dart)
  │   ├── flura_core
  │   └── umay_db
  ├── flura_capsa (Flutter)
  │   ├── flura_core
  │   └── capsa
  ├── flura_capsa_umay (Flutter)
  │   ├── flura_capsa
  │   └── flura_umay
  │
  ├── flura_testing (Pure Dart)         ← NOT exported by flura umbrella
  │   └── flura_core
  └── flura_cli (Dart exe)             ← NOT exported by flura umbrella
      └── flura_core
```

---

## 3. Public API Surface

### 3.1 Capsa — Public Exports (`capsa.dart`)

```dart
export 'package:flutter_rearch/flutter_rearch.dart' show RearchConsumer, WidgetHandle;
export 'package:rearch/rearch.dart' show capsule, CapsuleHandle;
export 'src/annotations/capsa.dart';          // @Capsa(path:) annotation
export 'src/capsa/capsa.dart';                // ScreenModel, Business, Repository, Datasource
export 'src/core/reactive_core.dart';          // Signal, Computed, Effect, ReactiveScheduler, etc.
export 'src/core/capsa_logger.dart';           // CapsaLogger
export 'src/core/reactive_scope.dart';         // ReactiveScope
export 'src/widgets/x_widgets.dart';           // X.text, X.show, X.opacity, X.container, X.button
export 'src/widgets/x_suspense.dart';          // XSuspense widget
export 'src/widgets/x_for.dart';               // UltraFor widget
export 'src/widgets/x_reactive.dart';          // XReactive, UltraBuilder, UltraObserver
export 'src/widgets/x_transition.dart';        // XTransition widget
export 'src/collections/reactive_list.dart';   // ReactiveList
export 'src/async/resource.dart';              // CapsaResource (hides ResourceStatus)
export 'src/core/ultra_observer.dart';        // UltraObserver
```

**Core classes:**
- `Signal<T>` — reactive value with read/write tracking
- `Computed<T>` — derived lazy memoized value
- `Effect` — auto-running side effect with dependency tracking
- `ReactiveScheduler` — batching, priority queues, microtask flushing
- `ReactiveScope` — disposer collection, keeps Effects alive
- `ScreenModel extends ReactiveScope` — MVVM orchestrator with `onInit()`, `onDispose()`
- `Business`, `Repository`, `Datasource` — abstract base classes (currently empty)
- `ReactiveList<T>` — observable list backed by a version Signal
- `CapsaResource<T>` — async state with loading/ready/error signals
- `CapsaLogger` — category-based ring-buffer logger

**Widgets:**
- `XReactive`, `UltraBuilder`, `UltraObserver` — reactive rebuild on signal changes
- `UltraFor<T>` — reactive list builder (sliver-based)
- `XSuspense<T>` — loading/ready/error for CapsaResource
- `XTransition` — signal-driven animation
- `X.text`, `X.show`, `X.opacity`, `X.container`, `X.button` — shorthand reactive widgets
- `UltraGrid`, `UltraWrap`, `UltraCollection`, `UltraReactiveListView`, `ReactiveText` etc.

### 3.2 UmayDB — Public Exports (`umay_db.dart`)

```dart
export 'src/core/umay_box.dart';
export 'src/orm/umay_model.dart';
export 'src/orm/indexable.dart';
export 'src/orm/soft_delete.dart';
export 'src/orm/soft_deletes.dart';
export 'src/orm/model.dart';
export 'src/orm/resource.dart';
export 'src/serialization/serializer.dart';
export 'src/serialization/type_registry.dart';
export 'src/serialization/type_adapter.dart';
export 'src/serialization/map_adapter.dart';
export 'src/index/index_manager.dart';
export 'src/index/fuzzy_index.dart';
export 'src/index/compound_index.dart';
export 'src/index/unique_index.dart';
export 'src/index/range_index.dart';
export 'src/query/linq_query_builder.dart';
export 'src/query/proxy_builder.dart';
export 'src/query/filter.dart';
export 'src/query/query_result.dart';
export 'src/query/engine/query_engine.dart';
export 'src/relations/belongs_to.dart';
export 'src/relations/has_many.dart';
export 'src/relations/has_one.dart';
export 'src/relations/many_to_many.dart';
export 'src/relations/pivot_table.dart';
export 'src/reactive/change_bus.dart';
export 'src/reactive/change_event.dart';
```

**Core classes:**
- `UmayBox` — persistent key-value store with append-only log, auto-compaction, reactive streams
- `UmayModel` — Active Record ORM base class
- `IndexableModel` — mixin that declares indexed/fuzzyIndexed fields
- `SoftDeletes` — mixin for soft delete support
- `LinqQueryBuilder<T>` — fluent query builder with `where()`, `orderBy()`, `limit()`, `watch()`
- `ProxyBuilder<T>` — generates dynamic proxy objects for type-safe query expressions
- `QueryEngine` — executes queries using index optimization
- `ChangeBus` — broadcast stream of `ChangeEvent`
- `SmartQueryWatcher<T>` — reactive query result watcher
- `IndexManager` — manages secondary, unique, fuzzy, and compound indexes
- Relations: `HasMany`, `BelongsTo`, `HasOne`, `ManyToMany`, `MorphMany`, `MorphTo`
- `MigrationEngine` — basic schema diff detection
- `Transaction`, `TransactionManager`, `MVCCStorage` — snapshot isolation

**Key API patterns:**
```dart
UmayBox.open('users');
box.put(key, value);         // async
box.get(key);                // async, returns dynamic
box.delete(key);             // async
box.query<T>().where((u) => (u as dynamic).field.eq(val)).find();
box.query<T>().watch();      // returns Stream<List<T>>
UmayModel.register<T>(() => T(), box: box);
UmayModel.find<T>(id);       // static async find
UmayModel.create<T>(data);   // static async create
```

### 3.3 Flutter Facades — Public Exports (`flutter_facades.dart`)

```dart
export 'src/core/exceptions.dart';
export 'src/core/facade_runtime.dart';
export 'src/core/service_provider.dart';
export 'src/core/service_resolver.dart';
export 'src/core/simple_container.dart';
export 'src/contracts/app_config.dart';
export 'src/contracts/app_http_client.dart';
export 'src/contracts/app_logger.dart';
export 'src/contracts/app_user.dart';
export 'src/contracts/auth_manager.dart';
export 'src/contracts/cache_store.dart';
export 'src/facades/auth.dart';
export 'src/facades/cache.dart';
export 'src/facades/config.dart';
export 'src/facades/http.dart';
export 'src/facades/log.dart';
export 'src/helpers/helpers.dart';
export 'src/implementations/console_logger.dart';
export 'src/implementations/map_config.dart';
export 'src/implementations/memory_cache_store.dart';
export 'src/implementations/null_auth_manager.dart';
export 'src/implementations/throwing_http_client.dart';
export 'src/providers/default_facade_service_provider.dart';
export 'src/adapters/rearch/rearch_facade_resolver.dart';
export 'src/adapters/rearch/rearch_facade_bootstrap.dart';
```

**Core classes:**
- `SimpleContainer implements ServiceResolver` — DI container with `bind()`, `singleton()`, `instance()`, `scope()`
- `FacadeRuntime` — static zone-aware resolver with `setRootResolver()`, `currentResolver`, `resolve<T>()`
- `ServiceProvider` — abstract with `register(container)` and `boot(container)`
- `ServiceResolver` — interface with single `resolve<T>()` method
- 5 Facades: `Config`, `Log`, `Cache`, `Auth`, `Http` (static APIs)
- 5 Contracts: `AppConfig`, `AppLogger`, `CacheStore`, `AuthManager`, `AppHttpClient`
- 5 Default implementations: `MapConfig`, `ConsoleLogger`, `MemoryCacheStore`, `NullAuthManager`, `ThrowingHttpClient`
- Helper functions: `app<T>()`, `config()`, `logger()`, `cache()`, `auth()`, `http()`
- `DefaultFacadeServiceProvider` — registers all defaults at once
- `RearchFacadeResolver` — adapter for Rearch capsule integration
- `RearchFacadeBootstrap` — helper to set up Rearch-backed facade resolver

---

## 4. DI Systems Analysis

### 4.1 System Comparison

| Feature | UltraDI (Capsa) | SimpleContainer (Facades) | Rearch Capsules |
|---------|-----------------|---------------------------|-----------------|
| **Singleton** | `registerSingleton<T>(instance)` | `instance<T>(value)` | Via `capsule()` + caching |
| **Lazy Singleton** | `registerLazySingleton<T>(factory)` | `singleton<T>(factory)` | Native (capsule caches) |
| **Factory (transient)** | `registerFactory<T>(factory)` | `bind<T>(factory)` | Via `capsule()` without cache |
| **Async Singleton** | `registerAsyncSingleton<T>(factory)` | ❌ Not supported | ❌ Not natively |
| **Scopes** | `pushScope()` / `popScope()` | `container.scope()` (parent-child) | Via rearch widget tree |
| **Parent delegation** | Linear scope stack | Parent container | Via capsule wrapping |
| **Circular dep detection** | ✅ `DIGraph` with stack trace | ❌ Not implemented | ❌ Not implemented |
| **Auto disposal** | ✅ Checks `ReactiveScope` / `Disposable` | ❌ Not implemented | Via scope disposal |
| **Zone-aware** | ❌ | ✅ `FacadeRuntime` zones | ❌ |
| **Static access** | `di.get<T>()` | `FacadeRuntime.resolve<T>()` | `use(capsule)` |
| **Code gen** | `@Capsa` → `.capsa.dart` capsules | ❌ | `capsule()` is manual |
| **Thread safety** | Not addressed | Not addressed | Not applicable |
| **Test override** | Re-register / reset() | `reset()` + re-register | Via capsule composition |

### 4.2 Registration Overlap

Services that could be registered in **both** UltraDI and SimpleContainer:
- HTTP clients
- Logger instances
- Config stores
- Cache backends
- Auth managers
- Any domain service

This is a **direct overlap** — if both systems are used in the same app, services must be registered twice.

### 4.3 Key Difference: UltraDI Entry Model

```dart
// DIEntry supports: singleton, lazySingleton, factory, asyncSingleton
// With automatic disposal of ReactiveScope/Disposable instances
class DIEntry<T> {
  void dispose() {
    if (obj is ReactiveScope) obj.dispose();
    if (obj is Disposable) obj.dispose();
  }
}
```

SimpleContainer has **no disposal integration**.

---

## 5. Lifecycle Systems

### 5.1 Capsa Lifecycle

- `ScreenModel.onInit()` — called once via `attach()`
- `ScreenModel.onDispose()` — called before `ReactiveScope.dispose()`
- `ReactiveScope.keepAlive(disposer)` — auto-dispose on scope disposal
- `Effect` auto-registers with `ReactiveScope` for disposal
- No application-level bootstrap lifecycle

### 5.2 UmayDB Lifecycle

- `UmayBox.open(name)` — opens/creates box, recovers index, starts background compaction
- `UmayBox.close()` — saves snapshot, cancels timer, closes files, closes ChangeBus
- Background compaction via `Timer.periodic(60s)`
- No application-level lifecycle

### 5.3 Flutter Facades Lifecycle

- `ServiceProvider.register(container)` — synchronously register bindings
- `ServiceProvider.boot(container)` — async initialization after registration
- `FacadeRuntime.setRootResolver(resolver)` — set root resolver
- `FacadeRuntime.reset()` — clear root resolver
- No shutdown/dispose lifecycle

### 5.4 Missing Lifecycle Features (in existing packages, before Flura)

| Feature | Capsa | UmayDB | Facades |
|---------|-------|--------|---------|
| Application bootstrap | ❌ | ❌ | ❌ |
| Ordered provider registration | ❌ | ❌ | ✅ (register then boot) |
| Async initialization | ❌ | ✅ (UmayBox.open) | ✅ (ServiceProvider.boot) |
| Reverse-order shutdown | ❌ | ❌ | ❌ |
| Two-stage readiness (bootstrapped → ready) | ❌ | ❌ | ❌ |
| Failure state with rollback | ❌ | ❌ | ❌ |
| Rollback with provider tracking (avoid double-shutdown) | ❌ | ❌ | ❌ |
| Shutdown after failure (remaining cleanup) | ❌ | ❌ | ❌ |
| Config loading phase | ❌ | ❌ | ❌ |
| Error boundary during bootstrap | ❌ | ❌ | ❌ |
| Database lifecycle hooks | ❌ | ❌ | ❌ |
| Health checks | ❌ | ❌ | ❌ |

---

## 6. Logging Systems

### 6.1 CapsaLogger (Capsa internal)

- Category-based: `signal`, `computed`, `effect`, `scheduler`, `di`, `mvvm`, `widget`
- Levels: `verbose`, `debug`, `info`, `warn`, `error`, `none`
- Ring buffer history (configurable max, default 1000)
- Custom sink support
- Disabled by default (production-safe)
- Designed for **internal reactive engine debugging**

### 6.2 AppLogger (Facades contract)

- Interface with `debug`, `info`, `warning`, `error`
- Context map support per-method
- Designed for **application-level logging**
- Default implementation: `ConsoleLogger` (simple print-based)

### 6.3 UmayDB Logger

- Simple `print`-based debug logging in `umay_box.dart`
- No abstraction, no levels, not exported
- Not a real logging system

---

## 7. Reactive Systems

### 7.1 Capsa Reactive Engine

```
Signal<T>  ──►  Computed<T>  ──►  Effect
  │                 │
  └── Callback subscribers (UltraReactiveRenderMixin)
  
ReactiveScheduler:
  - Batching: batch()
  - Priority queues: computed → render → effect → low
  - Microtask-based flush
  - Glitch-free via computed priority
  - Circular dependency detection
```

### 7.2 UmayDB Reactive

```
UmayBox.put/delete
  │
  ▼
ChangeBus.emit(ChangeEvent)
  │
  ▼
Stream<ChangeEvent>  ──►  SmartQueryWatcher maintains in-memory sorted set
  │                       (filters, sorts, emits Stream<List<T>>)
  ▼
LinqQueryBuilder.watch() returns Stream<List<T>>
```

### 7.3 Integration Gap

UmayDB produces `Stream<List<T>>`. Capsa consumes `Signal<T>` / `ReactiveList<T>`.

There is **no existing bridge** between the two. A developer using both must manually:
```dart
StreamSubscription sub = box.query<User>().watch().listen((users) {
  mySignal.value = users;
});
```

And must manually cancel the subscription on dispose, handle errors, manage loading states, etc.

---

## 8. Code Generation & CLI

### 8.1 Capsa Generator

- `@Capsa(path:)` annotation on a feature class
- `build_runner` generates `.capsa.dart` with capsule wiring (Datasource → Repository → Business)
- Declaration in `build.yaml` as `capsa|feature_builder`

### 8.2 Capsa CLI

- `bin/capsa.dart` — Dart executable
- `dart run capsa <feature-name> <path>` — scaffolds full feature folder
- Creates: view/, screen_model/, business/, repository/, datasource/, state/, model/
- Template files with minimal implementations

### 8.3 UmayDB Annotations

- `@UmayModelAnnotation()` — marker
- `@UmayCollection('box_name')` — collection binding
- `@UmayField(index:, unique:, fuzzy:)` — field-level index declarations
- `@RelHasMany`, `@RelBelongsTo`, etc. — relation annotations
- **No build_runner generator yet** — annotations exist but no published builder

---

## 9. Architectural Risks & Overlaps

### Risk 1: Three DI Systems
- UltraDI (Capsa), SimpleContainer (Facades), Rearch capsules
- Users forced to pick or bridge manually
- No shared abstraction for resolution

### Risk 2: No Application Kernel
- No unified bootstrap
- No ordered lifecycle
- No config management
- No database lifecycle integration

### Risk 3: Capsa Depends on Flutter
- Capsa imports `package:flutter/material.dart` and `package:flutter/scheduler.dart`
- The reactive engine (`reactive_core.dart`) has Flutter dependencies via `SchedulerBinding`
- This means Capsa cannot be used in pure Dart isolates or server-side

### Risk 4: UmayDB Query API Uses `dynamic` Extensively
- `LinqQueryBuilder.where((u) => (u as dynamic).field.eq(val))`
- Proxy builder generates `dynamic` proxies
- No compile-time type safety for query expressions
- README mentions type-safe queries but implementation uses dynamic proxy

### Risk 5: UmayDB Model Events vs Application Events
- `UmayModel.events` dispatches model lifecycle events
- No concept of domain/application events
- Risk of coupling if model events are used for domain logic

### Risk 6: CapsaLogger vs AppLogger Overlap
- Both log, with different APIs and purposes
- Risk of confusion if both are used in the same app
- Need clear separation: CapsaLogger for engine, AppLogger for application

### Risk 7: UmayDB MigrationEngine is Minimal
- Only detects schema diffs, doesn't execute migrations
- No migration version tracking
- No rollback support

### Risk 8: No Test Coverage in Capsa
- Capsa has zero test files
- This makes refactoring risky without writing tests first

### Risk 9: Naming Conflicts
- `Config`, `Log`, `Auth`, `Cache`, `Http` as facade class names could conflict with other packages
- `AppLogger` vs `CapsaLogger` — different contracts
- `ServiceProvider` (Facades) vs potential Flura `ServiceProvider`

---

## 10. Package Boundaries — Proposed Structure

After analysis, the following package boundaries are recommended:

```
flura/ (workspace root)
│
├── packages/
│   │
│   ├── capsa/                          ← EXISTING, minimally modified
│   │   ├── Reactive engine (Signal, Computed, Effect, Scheduler)
│   │   ├── Reactive widgets (XReactive, UltraFor, XSuspense, etc.)
│   │   ├── MVVM (ScreenModel, Business, Repository, Datasource)
│   │   ├── ReactiveList, CapsaResource
│   │   ├── CapsaLogger
│   │   ├── UltraDI
│   │   ├── Code generator & CLI
│   │   └── Router integration
│   │
│   ├── umay_db/                        ← EXISTING, minimally modified
│   │   ├── UmayBox (append-only log storage)
│   │   ├── UmayModel (Active Record ORM)
│   │   ├── Query builder & engine
│   │   ├── Indexes (B+Tree, HashMap, Trigram)
│   │   ├── Relations (HasMany, BelongsTo, etc.)
│   │   ├── Reactive (ChangeBus, QueryWatcher)
│   │   ├── MVCC transactions
│   │   ├── Soft deletes
│   │   ├── Compaction
│   │   ├── Model events
│   │   └── Annotations (no builder yet)
│   │
│   ├── flutter_facades/               ← EXISTING, minimally modified
│   │   ├── ServiceResolver interface
│   │   ├── SimpleContainer
│   │   ├── FacadeRuntime (zone-aware)
│   │   ├── 5 Facades (Config, Log, Cache, Auth, Http)
│   │   ├── 5 Contracts
│   │   ├── 5 Default implementations
│   │   ├── DefaultFacadeServiceProvider
│   │   └── Rearch adapter
│   │
│   ├── flura_core/                     ← NEW — Pure Dart
│   │   ├── FluraApplication
│   │   ├── FluraConfig
│   │   ├── FluraEnvironment
│   │   ├── FluraServiceProvider (abstract)
│   │   ├── FluraContainer / FluraResolver abstractions
│   │   ├── FluraScope
│   │   ├── FluraDisposable
│   │   ├── Bootstrap pipeline
│   │   ├── Application lifecycle
│   │   └── FluraException
│   │
│   ├── flura_flutter/                  ← NEW — Flutter
│   │   ├── FlutterBootstrap
│   │   ├── WidgetsFlutterBinding init
│   │   ├── runApp integration
│   │   ├── FlutterErrorHandler
│   │   ├── Platform error handler
│   │   ├── Lifecycle observer
│   │   └── Route integration
│   │
│   ├── flura_facades/                  ← NEW — Pure Dart
│   │   ├── FacadeResolverAdapter (FluraResolver → FacadeRuntime bridge)
│   │   ├── FluraApplication binding
│   │   ├── ContainerAdapter (SimpleContainer ↔ FluraContainer)
│   │   ├── Config bridge
│   │   ├── Cache bridge
│   │   ├── HTTP bridge
│   │   └── Auth bridge
│   │                                                     
│   │   (CapsaLogger ↔ AppLogger bridge: future package or user code)
│   │   (see D7, D32 — flura_capsa stays decoupled from AppLogger)
│   │
│   ├── flura_umay/                     ← NEW — Pure Dart
│   │   ├── DatabaseServiceProvider
│   │   ├── DatabaseConfig
│   │   ├── Box lifecycle (open/close on app lifecycle)
│   │   ├── Model registration hooks
│   │   ├── Migration lifecycle
│   │   ├── Seeder lifecycle
│   │   ├── UmayCacheBackend (Pure Dart cache — no CacheStore dependency)
│   │   └── Database health checks
│   │
│   ├── flura_capsa/                    ← NEW — Flutter
│   │   ├── CapsaServiceProvider (lifecycle — register CapsaLogger, forward logs)
│   │   ├── FluraCapsaLogEvent (Flura-owned log event type)
│   │   ├── CapsaLogForwarder callback (void Function(FluraCapsaLogEvent))
│   │   ├── UltraDiContainerAdapter (UltraDI → FluraContainer adapter)
│   │   ├── Error bridge
│   │   ├── Reactive resource bridge
│   │   └── Feature integration helpers
│   │                                                     
│   │   (RearchResolver → FluraResolver adapter is separate — Capsa follows
│   │    functional/widget-tree DI via Rearch capsules, not UltraDI containers)
│   │
│   ├── flura_capsa_umay/              ← NEW — Flutter (bridge package)
│   │   ├── LinqQueryBuilder.watch() → Signal adapter (NOT UmayBox.watch())
│   │   ├── ChangeBus.stream → Capsa-reactive bridge
│   │   ├── Resource watcher with loading/error/retry
│   │   ├── Subscription lifecycle management
│   │   ├── Batching (Umay change → Capsa batch)
│   │   └── ScreenModel integration
│   │
│   ├── flura_testing/                  ← NEW — Pure Dart (MVP scope: core only)
│   │   ├── FakeApplication
│   │   ├── FakeFluraContainer
│   │   ├── ContainerOverrides
│   │   ├── FakeServiceProvider
│   │   └── TestLifecycle
│   │                                                     
│   │   (Not in MVP — deferred):
│   │   ├── TempUmayDatabase        → requires flura_umay
│   │   ├── FacadeOverrides         → requires flura_facades
│   │   └── Reactive test helpers   → requires Capsa (separate Flutter package)
│   │
│   ├── flura_cli/                      ← NEW — Dart executable (MVP: project & code gen only)
│   │   ├── flura new <project>
│   │   ├── flura make:model
│   │   ├── flura make:feature
│   │   ├── flura make:provider
│   │   └── flura doctor
│   │                                                     
│   │   (Future phase — requires flura_umay + umay_db):
│   │   ├── db:migrate / db:rollback / db:seed / db:compact
│   │
│   └── flura/                          ← NEW — Flutter umbrella package
│       ├── Re-exports flura_core, flura_flutter, flura_facades, flura_umay, flura_capsa, flura_capsa_umay
│       └── Does NOT export flura_testing (dev/test) or flura_cli (executable)
```

---

## 11. DI Strategy — Open Questions

After analyzing all three DI systems, two viable strategies emerge:

### Option A: Shared Abstraction in flura_core

Create `FluraContainer` / `FluraResolver` interfaces in `flura_core`, then:
- `UltraDI` gets an adapter wrapper implementing `FluraContainer`
- `SimpleContainer` gets an adapter wrapper implementing `FluraContainer`
- `FacadeRuntime` uses `FluraResolver` as its backing resolver
- Rearch capsules continue to work independently

**Pros:** Unified API, existing systems work, clean integration
**Cons:** Dual maintenance of adapters, complexity in edge cases (scopes, disposal)

### Option B: Select UltraDI as Primary Container

- UltraDI is more feature-rich (lazy singleton, async singleton, circular dep detection, disposal)
- Create an adapter so `SimpleContainer`-based code can use UltraDI
- Deprecate `SimpleContainer` in future major version
- Rearch capsules remain independent (they are a different pattern — functional DI)

**Pros:** Fewer adapters, UltraDI is already part of Capsa ecosystem
**Cons:** Breaking change for flutter_facades users, UltraDI is global singleton (not isolated)

### Recommendation

**Option A** — Create shared abstractions because:
1. UltraDI is a global singleton — not suitable as the only container for test isolation
2. FacadeRuntime's zone-aware resolution is valuable and must be preserved
3. SimpleContainer's parent-child scoping is simpler and sufficient for many cases
4. The cost of adapters is low (both systems have <20 public methods)

---

## 12. Lifecycle — Final Flow (D3, D23, D24, D30, D31, D35)

```
States: created → bootstrapping → bootstrapped → ready → shuttingDown → shutdown
               ↘ failed        ↘ failed

Flow:
1. create FluraApplication                                     → state: created
2. load config (FluraConfig, synchronous, from constructor)
3. create root container (FluraContainer or DefaultFluraContainer)
4. bootstrap():
   a. state → bootstrapping
   b. register all providers (synchronous — bindings only, no resolution)
   c. boot all providers (async — open boxes, run migrations)
   d. run boot callbacks
   e. state → bootstrapped                                     → state: bootstrapped
5. install Flutter runtime error handlers (in flura_flutter)
6. markReady()                                                  → state: ready
7. runApp(wrap(MyApp))
8. ... application runs ...
9. shutdown() (manual, idempotent):
   a. state → shuttingDown
   b. run shutdown callbacks (reverse order)
   c. shutdown providers (reverse order, skip already-rolled-back)
   d. dispose FluraScope (container-owned resources)
   e. state → shutdown                                          → state: shutdown

On bootstrap failure:
   a. register failure: no rollback needed (register has no side effects)
   b. boot failure: shutdown all attempted providers (reverse order),
      including the failing provider (partial resource cleanup)
   c. track all shutdown providers in _shutdownProviders set
   d. state → failed                                            → state: failed
   e. rethrow FluraBootstrapException(phase, providerName, cause, stackTrace)
   f. caller can call shutdown() to clean up remaining resources
      (dispose container, run shutdown callbacks) — skips already-rolled-back

On unrecoverable error during runtime:
   a. fail() transitions from bootstrapped or ready → failed
   b. caller can then call shutdown() for cleanup

Key rules:
- Single bootstrap: calling bootstrap() twice throws BootstrapAlreadyAttemptedException
- register() is synchronous: bindings only, no side effects, no service resolution
- boot() is async: may resolve services, open databases
- shutdown() is idempotent: repeated calls return immediately
- shutdown() after failure: performs remaining cleanup (dispose container) but skips already-rolled-back providers
- Rollback does NOT auto-dispose container — caller can inspect state
- Provider ordering is explicit — providers are registered/booted in constructor order, shut down in reverse
- Duplicate registration throws ServiceAlreadyRegisteredException (no silent overwrites)
- replace<T>() allows explicit override for test/migration scenarios
- Child scopes resolve child→parent, override parent bindings, and dispose only their own resources
- fail() is a public method for external error handling
```

---

## 13. Future Research Questions — Not Blocking Phase 1

1. **Should UmayDB model events be bridged to an application event bus?** The model events (creating/created/updating/updated/deleting/deleted) are UmayDB-internal. Flura should not couple them to application events unless there's a clear adapter.

2. **Should Capsa's reactive engine be extractable to pure Dart?** Currently it depends on `flutter/scheduler.dart` (SchedulerBinding). Could the scheduler use `scheduleMicrotask` instead? This would reduce coupling but is not required for v1.

3. **Should the Capsa `Business`/`Repository`/`Datasource` base classes remain empty?** Currently they are abstract empty classes. Flura could make them more useful with lifecycle methods.

4. **How should the UmayDB code generation annotations be handled?** Annotations exist (`@UmayCollection`, `@UmayField`, `@RelHasMany`) but no builder exists. Flura could either complete the existing generator or build a new one in `flura_cli`.

5. **(Resolved — see D6, D16, D34) `flura_capsa_umay` is separate from `flura_umay`.** The bridge between UmayDB reactive streams and Capsa signals needs a Flutter-based package (because Capsa is Flutter-dependent). Keeping it separate avoids making `flura_umay` Flutter-dependent. Uses only verified UmayDB public APIs: `LinqQueryBuilder.watch()` and `ChangeBus.stream` (not `UmayBox.watch()`).

---

## 14. Test Coverage Summary

| Package | Tests | Coverage |
|---------|-------|----------|
| **capsa** | 0 files | ❌ None |
| **umay_db** | 1 file | Minimal (basic box CRUD) |
| **flutter_facades** | 6 files | Good (container, runtime, cache, helpers, rearch adapter) |

All existing tests pass (verified by examining test files).

---

## 15. Breaking Change Assessment

| Change | Risk | Mitigation |
|--------|------|------------|
| (Not happening — D29) No existing packages are renamed | N/A | Flura integration is additive; existing packages keep their names |
| Change `UltraDI` API | Medium | Add FluraContainer adapter, keep old API working |
| Change `SimpleContainer` API | Low | Add FluraContainer adapter, keep old API working |
| Modify `ReactiveScope` disposal | Medium | Extend, don't change existing behavior |
| Add `FluraApplication` | None | New code, no existing users affected |
| Merge logger systems | Low | Bridge, not merge; keep both interfaces |
| Add Flutter dependency to UmayDB | **HIGH** | Must NOT happen — UmayDB stays pure Dart |

---

## 16. Recommendations for Phase 1

1. **Keep all existing packages as-is** — do not modify Capsa/UmayDB/Facades source code
2. **Create `flura_core` first** — the foundation for everything else
3. **Use Option A for DI** — shared `FluraResolver` / `FluraContainer` abstractions
4. **Build adapters, not rewrites** — bridge existing systems via adapters
5. **Test `flura_core` thoroughly in Phase 1** — Capsa baseline tests can be added before Phase 5 (Capsa integration)
6. **Keep UmayDB pure Dart** — critical architectural constraint
7. **Document every decision** in `docs/architecture/decisions.md`
8. **38 architecture decisions recorded** (D1–D38) covering packages, DI strategy, lifecycle, logger boundary, rollback, testing, CLI, reactive bridges, FluraContainer contract, FluraScope/FluraOverridableContainer, duplicate registration, scope semantics, partial boot cleanup, transient disposal policy, FluraBootstrapException, and FluraServiceProvider contract

---

*End of discovery report v2. Ready for Phase 1: flura_core implementation.*
