class EnvConfig {
  // Environment settings
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: true);

  // API Configuration
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://cloudrun-v2.xemlicham.com',
  );

  static const int apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30000,
  );

  // App Information
  static const String appName = 'Thuoc Lo Ban';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Firebase Configuration (if needed)
  static const bool enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: false,
  );
  static const bool enableCrashlytics = bool.fromEnvironment(
    'ENABLE_CRASHLYTICS',
    defaultValue: false,
  );
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  // Feature Flags
  static const bool enableOfflineMode = bool.fromEnvironment(
    'ENABLE_OFFLINE',
    defaultValue: true,
  );
  static const bool enableCache = bool.fromEnvironment(
    'ENABLE_CACHE',
    defaultValue: true,
  );
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: !isProduction,
  );

  // Cache Settings
  static const int defaultCacheExpiration = int.fromEnvironment(
    'CACHE_EXPIRATION',
    defaultValue: 24,
  ); // hours
  static const int maxCacheSize = int.fromEnvironment(
    'MAX_CACHE_SIZE',
    defaultValue: 100,
  ); // entries

  // AI Configuration
  static const String openAIApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  // Numerology Specific
  static const bool enableAdvancedCalculations = bool.fromEnvironment(
    'ENABLE_ADVANCED',
    defaultValue: true,
  );
  static const bool enablePreviewCalculations = bool.fromEnvironment(
    'ENABLE_PREVIEW',
    defaultValue: true,
  );

  // Development Settings
  static const bool showDebugInfo = bool.fromEnvironment(
    'SHOW_DEBUG_INFO',
    defaultValue: isDebug,
  );
  static const bool enableTestMode = bool.fromEnvironment(
    'TEST_MODE',
    defaultValue: false,
  );

  // Get environment name
  static String get environmentName {
    if (isProduction) return 'production';
    if (enableTestMode) return 'test';
    return 'development';
  }

  // Get configuration summary
  static Map<String, dynamic> get configSummary => {
    'environment': environmentName,
    'isProduction': isProduction,
    'isDebug': isDebug,
    'apiUrl': apiUrl,
    'apiTimeout': apiTimeout,
    'enableOfflineMode': enableOfflineMode,
    'enableCache': enableCache,
    'enableLogging': enableLogging,
    'appVersion': appVersion,
    'buildNumber': buildNumber,
  };
}
