# Architecture Decisions — Flura Framework

> Based on the Discovery Report (docs/architecture/discovery.md)

---

## Decision 1: Package Boundaries

**Decision:** Keep Capsa, UmayDB, and Flutter Facades as separate, independently published packages. Create new "flura_*" integration packages.

**Rationale:**
- Capsa depends on Flutter (via `flutter_rearch`), UmayDB is pure Dart — merging them would break UmayDB's zero-dependency constraint
- Flutter Facades is pure Dart with `>=3.0.0 <4.0.0` SDK range — wider compatibility than Capsa
- Existing users of each library should not be forced onto the Flura stack
- Integration packages provide clear boundaries and testable seams

**Resulting packages:**

| Package | Type | Dependencies | Purpose |
|---------|------|-------------|---------|
| `capsa` | Flutter | flutter, rearch, flutter_rearch | Existing — unchanged |
| `umay_db` | Pure Dart | none | Existing — unchanged |
| `flutter_facades` | Pure Dart | none | Existing — unchanged |
| `flura_core` | Pure Dart | none | NEW: Application kernel |
| `flura_flutter` | Flutter | flura_core, flutter | NEW: Flutter bootstrap |
| `flura_facades` | Pure Dart | flura_core, flutter_facades | NEW: Facade bridge |
| `flura_umay` | Pure Dart | flura_core, umay_db | NEW: Database integration |
| `flura_capsa` | Flutter | flura_core, capsa | NEW: Capsa integration |
| `flura_capsa_umay` | Flutter | flura_capsa, flura_umay | NEW: Capsa–Umay reactive bridge |
| `flura_testing` | Pure Dart | flura_core | NEW: Core test utilities |
| `flura_cli` | Dart exe | flura_core | NEW: Project/code generation CLI |
| `flura` | Flutter | flura_core, flura_flutter, flura_facades, flura_umay, flura_capsa, flura_capsa_umay | NEW: Umbrella re-exports |

**Excluded from umbrella:**
- `flura_testing` — dev/test only, not runtime
- `flura_cli` — executable tool, not a library
- `capsa`, `umay_db`, `flutter_facades` — existing packages, not renamed or re-exported

---

## Decision 2: DI Strategy — Shared Abstraction (Option A)

**Decision:** Create `FluraContainer` and `FluraResolver` interfaces in `flura_core`. Provide adapters for both UltraDI and SimpleContainer.

**Rationale:**
- UltraDI is a global singleton — not suitable as the only runtime container (breaks test isolation)
- SimpleContainer lacks disposal, circular detection, and async singleton support
- FacadeRuntime's zone-aware resolution must be preserved
- A shared abstraction lets users bring their own container while Flura orchestrates lifecycle

**Adapter design:**
```dart
// UltraDI → FluraContainer adapter
class UltraDiContainer implements FluraContainer {
  final UltraDI _di = UltraDI();
  // ... delegate all methods
}

// SimpleContainer → FluraContainer adapter
class FacadesContainer implements FluraContainer {
  final SimpleContainer _container;
  // ... delegate all methods
}
```

**Flura core default:** Use `DefaultFluraContainer` built into `flura_core`. No external container dependency required.

**Adapter placement (not in flura_core):**
- The abstractions live in `flura_core`
- The UltraDI adapter lives in `flura_capsa`
- The SimpleContainer adapter lives in `flura_facades`
- Neither adapter is imported by `flura_core`

---

## Decision 3: Lifecycle Strategy

**Decision:** Define a clear application lifecycle with ordered phases, distinguishing between **bootstrapped** and **ready** states.

```
1. create FluraApplication                                        → state: created
2. load FluraConfig (synchronous, from constructor)
3. install explicit bootstrap try/catch boundary
4. create root FluraContainer
5. register providers (synchronous — bindings only)                → state: bootstrapping
6. boot providers (async — side effects)
7. run boot callbacks
8. mark bootstrapped                                               → state: bootstrapped
9. platform integrations install runtime handlers (e.g. Flutter
   error handlers in flura_flutter)
10. mark ready                                                     → state: ready
11. runApp / entry point
12. shutdown:                                                      → state: shuttingDown → shutdown
    a. run shutdown callbacks (reverse order)
    b. shutdown providers (reverse registration order)
    c. dispose FluraScope (container-owned resources)
    d. reset external runtimes (e.g. FacadeRuntime.reset())
```

**Key rules:**
- `register()` is for binding only — no side effects, no async, no service resolution
- `boot()` is for initialization — can resolve services, run async operations
- `shutdown()` is idempotent — repeated calls do not repeat disposal
- A FluraApplication permits only one bootstrap attempt — after success or failure, `bootstrap()` cannot be called again
- Provider errors during bootstrap trigger rollback: all successfully-booted providers are shut down in reverse order; the failing provider (which may have partially booted) is also shut down; the container is NOT automatically disposed so the caller can inspect state

**Lifecycle states:**
```
created → bootstrapping → bootstrapped → ready → shuttingDown → shutdown
               ↘ failed        ↘ failed
```

---

## Decision 4: Naming Strategy

**Decision:** Namespacing by package, not by prefix.

- Core abstractions use `Flura` prefix: `FluraApplication`, `FluraContainer`, `FluraResolver`, `FluraServiceProvider`
- Integration adapters use descriptive names: `DatabaseServiceProvider`, `FacadeResolverAdapter`
- Existing package APIs remain unchanged: `Signal`, `UmayBox`, `Cache.get()`, etc.
- The `flura` umbrella package re-exports common symbols without renaming
- No existing package is renamed — Flura integration is additive

---

## Decision 5: Backward Compatibility

**Decision:** All existing APIs remain unchanged in v1. Breaking changes go into major version bumps.

- Capsa 1.x API is frozen — new features in Capsa 2.x
- UmayDB 1.x API is frozen — new features in UmayDB 2.x
- Flutter Facades 0.x is alpha — minor version deprecations acceptable
- Flura packages start at v0.x until stable

---

## Decision 6: Capsa–UmayDB Integration

**Decision:** The Capsa–UmayDB reactive bridge is implemented exclusively in `flura_capsa_umay`. It is not part of `flura_capsa`.

Key integration points:
- `LinqQueryBuilder.watch()` → `Signal` / `ReactiveList` via an adapter
- `ChangeBus.stream` → reactive bridge events (model CRUD)
- `LinqQueryBuilder.watch()` → `CapsaResource`-like wrapper with loading/error/retry
- Subscription lifecycle tied to `ScreenModel` / `ReactiveScope`
- Batch UmayDB changes through `ReactiveScheduler.batch()`

**Constraint:** UmayDB must never depend on Capsa. The bridge lives in `flura_capsa_umay` only.

---

## Decision 7: Logger Strategy

**Decision:** Keep both loggers distinct. The optional bridge between them is NOT implemented in `flura_capsa` directly.

- `CapsaLogger` — internal reactive engine logging (categories: signal, computed, effect, scheduler, di, etc.)
- `AppLogger` — application-level logging (debug, info, warning, error with context) — lives in `flutter_facades`
- `flura_capsa` provides a `CapsaLogForwarder` callback type so users can forward logs without a dependency on `AppLogger`
- The actual `CapsaLogger → AppLogger` adapter belongs to a future package (e.g. `flura_capsa_facades`) or user code that depends on both integration layers
- Default: both work independently

---

## Decision 8: Event System

**Decision:** Keep UmayDB model events and application events separate.

- `UmayModel.events` dispatches `creating`, `created`, `updating`, `updated`, `deleting`, `deleted`
- Application domain events are a future concern (not in MVP)
- No automatic bridging — users can bridge manually if needed

---

## Decision 9: Testing Strategy

**Decision:** Test utilities in `flura_testing` initially cover only core and Pure Dart packages. Capsa-specific helpers are deferred to a separate package or later phase.

- `FakeApplication` — boots a FluraApplication without IO/network
- `FakeFluraContainer` — minimal container for test injection
- `FluraContainerOverrides` — override any service in container for test scope
- `FakeServiceProvider` — configurable mock provider
- `TestLifecycle` — lifecycle state assertions

**Not in flura_testing (MVP):**
- `TempUmayDatabase` — requires `flura_umay` dependency; add when needed
- `FacadeOverrides` — requires `flura_facades` dependency; add when needed
- `ReactiveTestHelpers` — requires Capsa (Flutter); separate package

---

## Decision 10: Versioning Strategy

| Package | Current | Flura v1 Target |
|---------|---------|-----------------|
| capsa | 1.0.2 | 1.x (unchanged) |
| umay_db | 1.2.0 | 1.x (unchanged) |
| flutter_facades | 0.1.0 | 0.x (unchanged) |
| flura_core | — | 0.1.0 |
| flura_flutter | — | 0.1.0 |
| flura_facades | — | 0.1.0 |
| flura_umay | — | 0.1.0 |
| flura_capsa | — | 0.1.0 |
| flura_capsa_umay | — | 0.1.0 |
| flura_testing | — | 0.1.0 |
| flura_cli | — | 0.1.0 |
| flura (umbrella) | — | 0.1.0 |

---

## Decision 11: Monorepo Tooling

**Decision:** Use Melos for workspace management.

- Single `melos.yaml` at workspace root
- All packages under `packages/`
- `melos bootstrap`, `melos analyze`, `melos test`, `melos format:check`
- Shared `analysis_options.yaml` for common lint rules

---

## Decision 12: Implementation Order

```
Phase 1:  flura_core (Pure Dart)
Phase 2:  flura_facades (Pure Dart) — early validation of adapter pattern
Phase 3:  flura_umay (Pure Dart) — database lifecycle
Phase 4:  flura_flutter (Flutter) — Flutter bootstrap
Phase 5:  flura_capsa (Flutter) — Capsa integration
Phase 6:  flura_capsa_umay (Flutter) — Capsa–Umay reactive bridge
Phase 7:  flura_testing (Pure Dart) — core test utilities
Phase 8:  flura_cli (Dart exe) — CLI tool
Phase 9:  flura umbrella — re-exports
Phase 10: Examples, docs, migration guides
```

Each phase = implementation + tests.

---

## Decision 13: flura_core Does Not Depend On Existing Containers

**Decision:** `flura_core` has zero runtime dependencies on Capsa, UmayDB, or Flutter Facades. It contains only abstractions (`FluraResolver`, `FluraContainer`) and a self-contained `DefaultFluraContainer` implementation.

**Rationale:**
- UltraDI lives inside Capsa (Flutter package), SimpleContainer lives inside Flutter Facades — depending on either would break pure-Dart constraint
- Would create a dependency cycle: `flura_core → flutter_facades → flura_core`
- Keeps the core independently testable and publishable

**Adapter placement (not in flura_core):**
- UltraDI adapter → `flura_capsa` (depends on Capsa)
- SimpleContainer adapter → `flura_facades` (depends on Flutter Facades)
- `FakeFluraContainer` → `flura_testing` (test-only)

---

## Decision 14: DefaultFluraContainer Lives In flura_core

**Decision:** `DefaultFluraContainer` is the built-in implementation shipping inside `flura_core`. SimpleContainer and UltraDI adapters are optional extras.

**Rationale:**
- Users get a working container without installing any other package
- Supports: `instance`, `singleton`, `factory`, `createScope`, `dispose`, circular dependency detection
- External containers can be swapped in via adapters when additional capabilities (zone-awareness, global singletons) are needed

---

## Decision 15: flura_umay Remains Pure Dart, Contains No Capsa Bridge

**Decision:** `flura_umay` depends only on `flura_core` and `umay_db`. No Capsa `Signal`, `ReactiveList`, or `ScreenModel` enters this package.

**Rationale:**
- UmayDB is pure Dart with zero dependencies — this purity must extend to its Flura integration
- Capsa depends on Flutter (via `flutter_rearch`)
- Any Capsa ↔ UmayDB bridging goes in `flura_capsa_umay`

**In scope for flura_umay:**
- `UmayDatabaseServiceProvider` (lifecycle)
- `UmayCacheBackend` (Pure Dart cache backend — does not implement `CacheStore`)
- `UmayDatabaseConfig` (config mapping)
- Query helpers, migration hooks

**Not in scope for flura_umay:**
- `CacheStore` adapter — lives in `flura_facades` or user code
- `Signal` / `ReactiveList` bridges
- Capsa `Resource` wrappers

---

## Decision 16: flura_capsa_umay Is A Separate Integration Package

**Decision:** Create `flura_capsa_umay` as an independent package bridging Capsa reactive primitives with UmayDB queries.

**Rationale:**
- `flura_capsa` should not depend on UmayDB
- `flura_umay` should not depend on Capsa
- Only a dedicated bridge package needs both dependencies

**Bridges (future):**
- `LinqQueryBuilder.watch()` stream → `Signal`
- `LinqQueryBuilder.watch()` → `ReactiveList`
- Subscription lifecycle tied to `ScreenModel`
- Batch UmayDB changes through `ReactiveScheduler.batch()`

**Dependency graph:**
```
flura_capsa_umay
    depends on: flura_capsa, flura_umay
```

(Transitive deps: capsa via flura_capsa, umay_db via flura_umay)

---

## Decision 17: Database Opening Happens In boot(), Never register()

**Decision:** `register()` is synchronous and contains only type bindings. All async initialization (open boxes, run migrations, acquire connections) happens in `boot()`.

**Rationale:**
- `register()` is called sequentially — async here blocks the entire bootstrap sequence
- Error handling is clearer when initialization is in `boot()` — errors can be caught with provider context
- `boot()` receives `FluraResolver` (read-only) — prevents registering new bindings after the registration phase
- `register()` receives `FluraContainer` (read-write) — needed for binding registration

**FluraServiceProvider contract (abstract class with default no-op):**
```dart
abstract class FluraServiceProvider {
  String get name => runtimeType.toString();
  void register(FluraContainer container) {}
  FutureOr<void> boot(FluraResolver resolver) {}
  FutureOr<void> shutdown(FluraResolver resolver) {}
}
```
- `register()` receives `FluraContainer` — write access to register bindings
- `boot()` receives `FluraResolver` — read-only; prevents new bindings after registration phase
- `shutdown()` receives `FluraResolver` — read-only; cleanup should not register new services
- All methods default to no-op — providers implement only what they need
- `shutdown()` should be idempotent — it may be called during rollback even if the provider's `boot()` failed partway through

**Correct pattern:**
```dart
class DatabaseServiceProvider extends FluraServiceProvider {
  @override
  void register(FluraContainer container) {
    container.singleton<DatabaseConfig>((r) => DatabaseConfig());
    container.singleton<DatabaseManager>((r) => DatabaseManager());
  }

  @override
  Future<void> boot(FluraResolver resolver) async {
    final manager = resolver.resolve<DatabaseManager>();
    await manager.open();
  }

  @override
  Future<void> shutdown(FluraResolver resolver) async {
    final manager = resolver.resolve<DatabaseManager>();
    await manager.close();
  }
}
```

---

## Decision 18: flura Umbrella Package Is A Flutter Package

**Decision:** The top-level `flura` package is a Flutter package because it re-exports `flura_flutter` and `flura_capsa`, both of which depend on Flutter.

**Rationale:**
- Users who write `import 'package:flura/flura.dart'` expect to use Flutter APIs like `FlutterBootstrap`, `FluraAppWidget`
- A pure-Dart umbrella cannot re-export symbols from Flutter-dependent packages
- Users who need pure Dart only can import `package:flura_core/flura_core.dart` directly

**Exports of flura:**
```text
flura_core, flura_flutter, flura_facades, flura_umay, flura_capsa, flura_capsa_umay
```

NOT exported: `flura_testing` (dev/test), `flura_cli` (executable).

---

## Decision 19: Bootstrap Errors And Flutter Runtime Errors Have Separate Handlers

**Decision:** Two error boundaries exist at different phases:

1. **Bootstrap Error Boundary** — explicit try/catch wrapping the bootstrap pipeline in `flura_core`. This is NOT a global Dart error handler. It catches errors from register/boot/bootCallbacks, attaches provider/phase context (`FluraBootstrapException` with `FluraBootstrapPhase` enum), triggers rollback (all attempted providers in reverse order), and rethrows `FluraBootstrapException` with preserved `cause` and `stackTrace`.
2. **Flutter Runtime Error Handler** — installed after boot completes, before `runApp()` in `flura_flutter`; wraps `FlutterError.onError` and `PlatformDispatcher.instance.onError`.

**FluraBootstrapException contract:**
```dart
class FluraBootstrapException implements Exception {
  final String providerName;
  final FluraBootstrapPhase phase;
  final Object cause;
  final StackTrace stackTrace;
  // The original error is preserved as cause and original stack trace
}
```

**Bootstrap Error Boundary scope:**
```dart
try {
  register providers (sync)
  boot providers (async)
  run boot callbacks
} catch (error, stackTrace) {
  rollback (shutdown all attempted providers in reverse order)
  // Container is NOT disposed during rollback — caller may inspect state
  mark application as failed
  throw FluraBootstrapException(
    providerName: providerName,
    phase: phase,
    message: message,
    cause: originalError,
    stackTrace: originalStack,
  )
}
```

**Register failure rule:**
- If `register()` fails, no provider shutdown is attempted (no side effects have occurred)
- The application enters `failed` state
- The container remains available for inspection
- `shutdown()` may later dispose the container

---

## Decision 20: Flutter Shutdown Is Best-Effort, Not Guaranteed

**Decision:** `FluraApplication.shutdown()` is a manual, explicit call. On mobile, OS-level kill provides no lifecycle callback guarantee. Document that:
- `shutdown()` should be called when the app gracefully transitions away (e.g., `AppLifecycleState.detached`)
- UmayDB handles its own write safety and startup recovery
- Providers implement `shutdown()` as a best-effort cleanup, not a critical path

---

## Decision 21: Advanced DI Features Are Optional Capabilities

**Decision:** The `FluraContainer` interface stays minimal (instance, singleton, factory, scope). Advanced features (async resolve, disposal, circular dependency detection, zone awareness) are documented as optional capabilities provided by specific implementations.

| Capability | DefaultFluraContainer | SimpleContainer | UltraDI |
|-----------|----------------------|-----------------|---------|
| instance / singleton / factory | ✅ | ✅ | ✅ |
| Parent scope chain | ✅ | ✅ | ❌ (global) |
| Circular dependency detection | ✅ | ❌ | ✅ |
| Dispose (`FutureOr<void>`) | ✅ (implements FluraScope) | ❌ | ✅ (implementation-dependent) |
| Zone-aware resolution | ❌ | ✅ | ❌ |
| Async singleton | ❌ | ❌ | ✅ |

**Interface design:**
- `FluraContainer` exposes `instance`, `singleton`, `factory`, `createScope() → FluraContainer` — does NOT require `dispose`; `createScope()` returns `FluraContainer` so adapters without disposal can still create scopes
- `FluraScope extends FluraContainer` adds `dispose()` — implemented only by containers that support it
- `DefaultFluraContainer implements FluraScope` — has full disposal
- Adapters for UltraDI / SimpleContainer implement `FluraContainer` only; `dispose` is checked at runtime via `is FluraScope`
- `has<T>()` returns `true` if a binding for `T` exists in the current scope or any ancestor scope; it does NOT instantiate the service and does NOT validate the factory

**Design principle:** Do not add interface methods for capabilities that not all implementations can satisfy. Prefer runtime type checks (`is FluraScope`) over forcing disposal onto every container.

---

## Decision 22: FacadeRuntime Is Configured By flura_facades

**Decision:** The `flura_facades` package owns the bridge between Flura's DI and the FacadeRuntime. It provides a `FluraFacadeResolver` (implements `ServiceResolver`) that delegates to the application's `FluraResolver`.

**Behavior rules:**
- `FacadeRuntime.setRootResolver()` is called during `FluraFacadesServiceProvider.boot()`
- `FacadeRuntime.reset()` is called during `FluraFacadesServiceProvider.shutdown()`
- Calling any facade before bootstrap throws the existing `FacadeRuntime` exception (unchanged — Flura does not replace it)
- Zone-level resolvers still take precedence over the root resolver (FacadeRuntime behavior unchanged)
- Re-configuring the root resolver (second call) overwrites silently

---

## Decision 23: Bootstrap Failure Rollback

**Decision:** If `bootstrap()` fails at any phase (register, boot, bootCallback), the application shuts down all attempted providers in reverse order before rethrowing `FluraBootstrapException`.

**Behavior:**
```dart
final List<FluraServiceProvider> attempted = [];
try {
  // Phase 1: Register all providers
  for (final provider in _providers) {
    provider.register(container);  // throws → no rollback needed (no side effects)
  }

  // Phase 2: Boot all providers
  for (final provider in _providers) {
    attempted.add(provider);  // track BEFORE boot
    await provider.boot(resolver);
  }
} catch (e) {
  // Shutdown ALL attempted providers in reverse order.
  // This includes the provider that failed DURING boot (partial cleanup)
  // plus all previously-booted providers.
  for (final provider in attempted.reversed) {
    await provider.shutdown(resolver);  // best-effort
  }
  // Container is NOT disposed during rollback — caller may inspect state
  throw FluraBootstrapException(
    providerName: providerName,
    phase: phase,
    message: message,
    cause: originalError,
    stackTrace: originalStack,
  )
}
```

**Rules:**
- ALL providers that entered the `boot()` loop are tracked in `attempted` list, including the provider that failed partway through its own `boot()`
- Rollback shuts down all attempted providers in reverse order (safer than only tracking successfully-booted providers)
- If `register()` fails: no provider shutdown is attempted (register has no side effects)
- Rollback is silent (shutdown errors are swallowed)
- The original exception is preserved as `FluraBootstrapException` with `cause`, `stackTrace`, `FluraBootstrapPhase`, and `providerName`
- After a failed bootstrap, the application enters `failed` state
- The container is NOT disposed during rollback — caller can inspect state
- A second `bootstrap()` call after either success or failure throws `BootstrapAlreadyAttemptedException` (FluraApplication is single-bootstrap)
- To retry, the caller must create a new `FluraApplication` instance

---

## Decision 24: Idempotent Shutdown

**Decision:** `FluraApplication.shutdown()` is idempotent.

- Calling `shutdown()` on a bootstrapped or ready application executes once
- Calling `shutdown()` again returns immediately without repeating disposal
- Calling `shutdown()` before `bootstrap()` or in `created` state is a no-op
- Calling `shutdown()` after a failed bootstrap performs remaining cleanup (disposes container, runs shutdown callbacks) but skips already-rolled-back providers
- Calling `shutdown()` during `bootstrap()` is prohibited (caller must wait)
- `shutdown()` after failure does NOT execute additional `provider.shutdown()` on already-rolled-back providers — tracked via `_shutdownProviders` set

---

## Decision 25: Explicit Container Semantics

**Decision:** `DefaultFluraContainer` has the following semantics:

| Method | Meaning | Creates new instance each resolve? | Singleton? |
|--------|---------|-----------------------------------|------------|
| `instance(value)` | Eager singleton — value provided upfront | No | Yes |
| `singleton(factory)` | Lazy singleton — factory called once on first resolve | No | Yes |
| `factory(factory)` | Transient — factory called on every resolve | Yes | No |

- There is no separate `lazySingleton` method — `singleton(factory)` IS the lazy singleton API
- The container interface exposes `instance`, `singleton`, and `factory` only
- `createScope()` creates a child container that delegates unresolvable types to the parent

---

## Decision 26: Cache Adapter Boundary

**Decision:** `UmayCacheBackend` in `flura_umay` provides a Pure Dart cache with TTL support, but does NOT implement `CacheStore` from `flutter_facades`. If `CacheStore` integration is required, an adapter is built in `flura_facades` (or user code) that wraps `UmayCacheBackend`.

**Rationale:**
- `flura_umay` stays pure Dart with only `flura_core` and `umay_db` dependencies
- `CacheStore` lives in `flutter_facades` — depending on it would add an unwanted dependency
- Separation keeps `flura_umay` usable in pure-Dart contexts without facades

**Future adapter pattern (in flura_facades):**
```dart
class UmayCacheStoreAdapter implements CacheStore {
  final UmayCacheBackend backend;
  // delegate all CacheStore methods to backend
}
```

---

## Decision 27: Testing Package Scope

**Decision:** `flura_testing` initially covers only `flura_core` and pure-Dart test utilities.

**In scope (MVP):**
- `FakeApplication` — boots a FluraApplication without IO/network
- `FakeFluraContainer` — configurable container for test injection
- `FluraContainerOverrides` — override services in a test scope
- `FakeServiceProvider` — mock provider with configurable lifecycle
- `TestLifecycle` — assertions on application state

**Not in scope (MVP) — added later as needed:**
- `TempUmayDatabase` — requires `flura_umay`
- `FacadeOverrides` — requires `flura_facades`
- `ReactiveTestHelpers` — requires Capsa (separate Flutter package)

---

## Decision 28: CLI Dependency Scope

**Decision:** `flura_cli` initially focuses on project scaffolding and code generation commands. Database commands (migrate, rollback, seed, compact) are added only after `flura_umay` integration in a subsequent phase.

**MVP commands:**
- `flura new <project>` — scaffold new Flura project
- `flura make:feature` — generate feature folder structure
- `flura make:model` — generate data model
- `flura make:provider` — generate service provider
- `flura doctor` — check project configuration

**Dependencies (MVP):** `flura_core` only

**Later phase:** `flura umay:migrate` etc. — depends on `flura_umay` + `umay_db`

---

## Decision 29: No Existing Package Rename

**Decision:** `capsa`, `umay_db`, and `flutter_facades` keep their existing package names. Flura integration is additive — it does not rename, replace, or modify existing packages.

**Rationale:**
- Existing users of each library should not experience breaking changes
- The Flura ecosystem grows around existing packages without forcing migration
- Integration packages follow the `flura_*` naming convention to distinguish them from originals

---

## Decision 30: Two-Stage Readiness (Bootstrapped vs Ready)

**Decision:** `FluraApplication` distinguishes between `bootstrapped` and `ready` states.

- **bootstrapped** means core providers have been registered, booted, and boot callbacks have run. The application can resolve services.
- **ready** means all platform-specific runtime handlers have been installed (e.g., Flutter error handlers in `flura_flutter`).

**State machine:**
```
created → bootstrapping → bootstrapped → ready → shuttingDown → shutdown
               ↘ failed        ↘ failed
```

- `fail()` is a public method that transitions from `bootstrapped` or `ready` to `failed`, enabling external error handling to mark the application as failed

- `markReady()` is a public method called by platform integration packages (`flura_flutter`) after installing runtime handlers
- In pure-Dart contexts (no Flutter), `markReady()` can be called immediately after `bootstrap()` if no additional setup is needed
- Calling `markReady()` before `bootstrap()` or in `failed` state throws `FluraException`
- `fail()` is a public method that transitions from `bootstrapped` or `ready` to `failed`
- `fail()` in `created`, `bootstrapping`, `shuttingDown`, or `shutdown` throws `FluraException` (invalid state transitions)
- `fail()` in `failed` is a no-op (already failed)
- `fail()` only changes state — it does NOT trigger shutdown or rollback; `shutdown()` must be called explicitly for cleanup

---

## Decision 31: Single-Bootstrap Application

**Decision:** A `FluraApplication` permits only one bootstrap attempt.

- After a successful bootstrap, calling `bootstrap()` again throws `BootstrapAlreadyAttemptedException`
- After a failed bootstrap (state = failed), calling `bootstrap()` again throws `BootstrapAlreadyAttemptedException`
- To retry after failure, create a new `FluraApplication` instance
- `DuplicateBootstrapException` is renamed to `BootstrapAlreadyAttemptedException` for clarity

**Rationale:**
- Providers may have side effects that rollback cannot fully undo
- A fresh application instance ensures a clean state
- Simpler lifecycle semantics for users

---

## Decision 32: Logger Bridge Uses Flura-Owned Type

**Decision:** `flura_capsa` does not depend on `AppLogger` or `flutter_facades`. The logger forwarder uses a Flura-owned event type.

- `CapsaServiceProvider` accepts an optional `CapsaLogForwarder` callback (`void Function(FluraCapsaLogEvent)`)
- `FluraCapsaLogEvent` is a value class in `flura_capsa` containing `message`, `level`, and `timestamp`
- Inside `boot()`, `CapsaLogger.sink` is wired to convert `CapsaLogRecord` → `FluraCapsaLogEvent` and invoke the forwarder
- Users who want to forward `CapsaLogger` events to `AppLogger` provide the forwarder themselves, mapping `FluraCapsaLogEvent` to `AppLogger` calls
- The actual adapter lives in user code or a future package (`flura_capsa_facades`) that depends on both `flura_capsa` and `flura_facades`

**Rationale:**
- `AppLogger` lives in `flutter_facades` — depending on it would add an unwanted dependency to `flura_capsa`
- A Flura-owned event type prevents coupling to Capsa's `CapsaLogRecord` at the forwarder API boundary
- The callback abstraction keeps `flura_capsa` decoupled while still allowing bridging
- Consistent with the principle that integration packages stay focused on their primary concern

---

## Decision 33: Rollback Container Policy

**Decision:** During bootstrap rollback, the container is NOT automatically disposed.

- Rollback shuts down successfully-booted providers in reverse order
- If a provider fails during `boot()`, that provider is also shut down (partial resource cleanup) before the rollback of already-booted providers
- Shutdown errors during rollback are swallowed (best-effort)
- The container remains intact so the caller can inspect state (e.g., check which services were registered)
- The application enters `failed` state after rollback
- The caller can call `shutdown()` after failure to clean up remaining resources (dispose container, run shutdown callbacks), or discard the application instance
- Providers already shut down during rollback are tracked via `_shutdownProviders` set and skipped during the post-failure `shutdown()` to avoid double-shutdown

**Rationale:**
- Preserving the container allows post-mortem inspection
- Clean separation between rollback (provider shutdown) and explicit disposal (container cleanup)
- Consistent with the idempotent shutdown policy — `shutdown()` always cleans up regardless of state

---

## Decision 34: Reactive Bridge Uses Verified UmayDB APIs

**Decision:** `flura_capsa_umay` adapts only public UmayDB APIs that actually exist in `umay_db v1.2.0`:

- `LinqQueryBuilder.watch()` → `Stream<List<T>>` — verified existing API
- `ChangeBus.stream` → `Stream<ChangeEvent>` — verified existing API

**Not assumed (unless verified):**
- `UmayBox.watch()` — not a direct public API (confirmed in Discovery Report); the bridge must use `LinqQueryBuilder.watch()` or `ChangeBus` instead
- Any other undocumented reactive APIs

**Rationale:**
- The bridge must be implementable against the current `umay_db` release without modifying the database package
- If UmayDB adds new reactive APIs in a future version, the bridge can be extended accordingly

---

## Decision 35: Provider Ordering Is Explicit

**Decision:** `FluraApplication` processes providers in the exact order they are passed to the constructor. There is no automatic topological sort in MVP.

**Rules:**
- Providers are registered in the order they appear in the list
- Providers are booted in the same order
- Providers are shut down in reverse order (last booted, first shut down)
- The user is responsible for ordering providers correctly (e.g., database provider before repository provider)
- A later version may add dependency-graph validation as an optional feature

**Rationale:**
- Automatic sorting requires providers to declare dependencies, adding complexity to the `FluraServiceProvider` interface
- In MVP, the typical provider count is small (< 20), making manual ordering manageable
- Reverse shutdown order is natural: if A depends on B, A should be listed after B and shut down before B

---

## Decision 36: Duplicate Registration Policy

**Decision:** Registering the same type twice via `FluraContainer` throws `ServiceAlreadyRegisteredException`.

**Rules:**
- `container.instance<T>(value)` on a type `T` that already has a binding throws
- `container.singleton<T>(factory)` on an already-bound `T` throws
- `container.factory<T>(factory)` on an already-bound `T` throws
- To override an existing binding, use child scopes or `replace<T>()` (where available)

**Rationale:**
- Silent overwrites hide bugs (e.g., two providers both registering the same service)
- Early failure (during bootstrap) is better than mysterious runtime behavior
- Test overrides use child scopes or `FakeFluraContainer` instead of re-registration

**`replace<T>()` and `FluraOverridableContainer`:**
- `replace<T>()` is NOT part of `FluraContainer` interface — it is an optional capability via `FluraOverridableContainer`
- `DefaultFluraContainer implements FluraOverridableContainer` — provides `replace<T>()` and `replaceInstance<T>()`
- `replace()` on a non-existent binding throws `ServiceNotFoundException` for safety
- Adapters (UltraDI, SimpleContainer) are not required to provide `replace<T>()`

```dart
abstract interface class FluraOverridableContainer
    implements FluraContainer {
  void replace<T>(FluraFactory<T> factory);
  void replaceInstance<T>(T value);
}
```

---

## Decision 37: Scope Semantics

**Decision:** Parent-child scope semantics for MVP:

- **Root container** — holds all provider-registered bindings; owns all singletons created during bootstrap
- **Child scope** — created via `container.createScope()`; has its own binding table
- **Resolution order:** child → parent (child checked first, parent as fallback)
- **Singleton lifecycle:** singletons created in the root survive child disposal; singletons created in the child are disposed with the child
- **Transient factories are NOT tracked or disposed automatically in MVP** — `factory()` results are not automatically disposed on scope disposal; the caller is responsible for cleaning up any transients that require disposal
- Disposal automatically applies only to owned singleton instances (`instance()`, `singleton()`) and explicitly registered disposable resources
- If transient tracking is needed in the future, an optional `FluraTransientTracking` capability can be added
- **Override:** child can register a different implementation for a type already bound in the parent; the override applies only within the child scope
- **Disposal:** disposing a child scope cleans up owned singletons and explicit `instance()` registrations created within that scope; `factory()` transient results and parent singletons are unaffected
- **Provider scope:** all providers register in the root container — child scopes are for component-level isolation (e.g., per-request or per-screen)
- **Scope ownership:** `FluraApplication` owns only the root container. Child scopes must be disposed explicitly by the caller. `FluraApplication.shutdown()` does NOT auto-dispose child scopes.
- **`createScope()` return type:** `FluraContainer` (not `FluraScope`) — adapters without disposal capabilities can still create scopes; disposal is an optional capability verified at runtime via `is FluraScope`

**Rationale:**
- Simple semantics easy to test and reason about
- No cross-scope disposal of parent resources
- Override enables test scopes without global state manipulation
- Not tracking transients avoids memory growth and complexity; MVP callers manage transient lifecycle explicitly

---

## Decision 38: FluraContainer Interface Contract

**Decision:** The precise interfaces shipped in `flura_core`:

```dart
typedef FluraFactory<T> = T Function(FluraResolver resolver);

abstract interface class FluraResolver {
  T resolve<T>();
  bool has<T>();
}

abstract interface class FluraContainer implements FluraResolver {
  void instance<T>(T value);
  void singleton<T>(FluraFactory<T> factory);
  void factory<T>(FluraFactory<T> factory);
  FluraContainer createScope();
}

abstract interface class FluraScope extends FluraContainer {
  @override
  FluraScope createScope();  // covariant return — scope creation returns a scope
  FutureOr<void> dispose();
}

abstract interface class FluraOverridableContainer
    implements FluraContainer {
  void replace<T>(FluraFactory<T> factory);
  void replaceInstance<T>(T value);
}
```

**Key design decisions:**
- `FluraResolver` is the read-only interface — service consumers depend on this, not on `FluraContainer`
- `FluraContainer` adds write operations — only `FluraApplication` and `FluraServiceProvider.register()` interact with this
- `boot()` and `shutdown()` receive `FluraResolver` (not `FluraContainer`) — prevents providers from registering new bindings after the registration phase
- `createScope()` returns `FluraContainer` (not `FluraScope`) on the base interface — adapters without disposal return a plain `FluraContainer`-implementing scope
- `FluraScope` overrides `createScope()` with covariant `FluraScope` return type — containers that support disposal return disposable scopes
- `FluraScope` splits out disposal — adapters without disposal implement only `FluraContainer`
- `FluraOverridableContainer` is an optional interface for containers that support binding replacement
- `DefaultFluraContainer implements FluraScope, FluraOverridableContainer` — full disposal, circular detection, `replace<T>()`, `replaceInstance<T>()`
- `FluraFactory<T>` takes `FluraResolver` (not `FluraContainer`) — prevents factories from registering new bindings
- `has<T>()` checks for a binding in the current scope and ancestor scopes; it does NOT instantiate the service and does NOT validate the factory

**Rationale:**
- Keeps the core interface small and implementable
- Runtime type check (`is FluraScope`) is used in `FluraApplication.shutdown()` before disposal
- Runtime type check (`is FluraOverridableContainer`) enables optional override detection
- Separation of concerns: consumers resolve, containers register, scopes dispose

---

*Decisions recorded: 2026-07-11 (initial) / Updated: 2026-07-11 v7 (D17/D19/D21/D23/D24/D30/D33/D36/D37/D38 corrected: FluraScope overrides createScope()→FluraScope, FluraOverridableContainer interface, FluraBootstrapException renamed, boot/shutdown take FluraResolver, attempted-provider rollback, register failure documented, transient disposal policy, FluraServiceProvider contract finalized)*
*Next: Flura architecture is ready for Phase 1 — flura_core implementation*