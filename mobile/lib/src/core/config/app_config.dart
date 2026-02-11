/// Application configuration management
class AppConfig {
  static const bool _kUseMockData = bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false);
  static const bool _kIsDebugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: true);
  
  /// Whether to use mock data instead of real Supabase data
  static bool get useMockData => _kUseMockData;
  
  /// Whether the app is in debug mode
  static bool get isDebugMode => _kIsDebugMode;
  
  /// Whether to enable verbose logging
  static bool get enableVerboseLogging => _kIsDebugMode;
  
  /// API timeout duration
  static const Duration apiTimeout = Duration(seconds: 30);
  
  /// Cache duration for loan data
  static const Duration loanCacheDuration = Duration(minutes: 5);
}