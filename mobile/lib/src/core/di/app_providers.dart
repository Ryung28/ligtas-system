import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../../features/loans/repositories/loan_repository.dart';

/// Centralized dependency injection for the application
class AppProviders {
  
  /// Supabase client provider
  static final supabaseClientProvider = Provider<SupabaseClient>((ref) {
    return Supabase.instance.client;
  });
  
  /// Loan repository provider with environment-based selection
  static final loanRepositoryProvider = Provider<LoanRepository>((ref) {
    final supabaseClient = ref.read(supabaseClientProvider);
    
    if (AppConfig.useMockData) {
      // Return mock repository for testing/development
      throw UnimplementedError('Mock repository removed - use Supabase in all environments');
    }
    
    return SupabaseLoanRepository(supabaseClient);
  });
}