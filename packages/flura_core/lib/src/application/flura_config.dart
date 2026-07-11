import 'flura_environment.dart';

class FluraConfig {
  final String name;
  final FluraEnvironment environment;
  final String? databaseDirectory;
  final bool debugLogging;
  final Map<String, Object?> custom;

  const FluraConfig({
    this.name = 'FluraApp',
    this.environment = FluraEnvironment.development,
    this.databaseDirectory,
    this.debugLogging = false,
    this.custom = const {},
  });

  FluraConfig copyWith({
    String? name,
    FluraEnvironment? environment,
    String? databaseDirectory,
    bool? debugLogging,
    Map<String, Object?>? custom,
  }) {
    return FluraConfig(
      name: name ?? this.name,
      environment: environment ?? this.environment,
      databaseDirectory: databaseDirectory ?? this.databaseDirectory,
      debugLogging: debugLogging ?? this.debugLogging,
      custom: custom ?? this.custom,
    );
  }

  static FluraConfig get test => const FluraConfig(
        name: 'TestApp',
        environment: FluraEnvironment.test,
        debugLogging: false,
      );

  static FluraConfig get development => const FluraConfig(
        name: 'DevApp',
        environment: FluraEnvironment.development,
        debugLogging: true,
      );

  T get<T>(String key, {T? fallback}) {
    final value = custom[key];
    if (value is T) return value;
    if (fallback != null) return fallback;
    throw StateError('Config key "$key" not found');
  }

  T? getOrNull<T>(String key) {
    final value = custom[key];
    if (value is T) return value;
    return null;
  }

  bool has(String key) => custom.containsKey(key);
}
