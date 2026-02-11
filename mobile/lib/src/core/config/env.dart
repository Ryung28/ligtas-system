class Environment {
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'https://knarlvwnuvedyfvvaota.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuYXJsdndudXZlZHlmdnZhb3RhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3MjQxMzQsImV4cCI6MjA4NTMwMDEzNH0.ychlatdBNWPWvwoeT4NzKHS5HNv1ZytKQ31E1RvXvrA';
  
  // Database table names
  static const String inventoryTable = 'inventory';
  static const String transactionsTable = 'transactions';
  static const String userProfilesTable = 'user_profiles';
}