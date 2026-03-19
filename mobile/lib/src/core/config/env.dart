class Environment {
  // Trimmed at runtime to guard against invisible whitespace from copy-paste
  static String get supabaseUrl => 'https://knarlvwnuvedyfvvaota.supabase.co'.trim();
  static String get supabaseAnonKey => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuYXJsdndudXZlZHlmdnZhb3RhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3MjQxMzQsImV4cCI6MjA4NTMwMDEzNH0.ychlatdBNWPWvwoeT4NzKHS5HNv1ZytKQ31E1RvXvrA'.trim();

  // Database table names
  static const String inventoryTable = 'inventory';
  static const String transactionsTable = 'transactions';
  static const String userProfilesTable = 'user_profiles';
}