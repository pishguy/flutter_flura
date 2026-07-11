enum FluraEnvironment {
  development,
  staging,
  production,
  test;

  bool get isDevelopment => this == FluraEnvironment.development;
  bool get isStaging => this == FluraEnvironment.staging;
  bool get isProduction => this == FluraEnvironment.production;
  bool get isTest => this == FluraEnvironment.test;

  static FluraEnvironment fromName(String name) {
    return FluraEnvironment.values.firstWhere(
      (e) => e.name == name.toLowerCase(),
      orElse: () => FluraEnvironment.development,
    );
  }
}
