import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Base application exception
abstract class AppException implements Exception {
  const AppException(this.message, {this.code, this.details});
  
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

/// Data-related exceptions
class DataException extends AppException {
  const DataException(super.message, {super.code, super.details});
}

/// Loan-specific exceptions
class LoanException extends AppException {
  const LoanException(super.message, {super.code, super.details});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

/// Exception handler utility
class ExceptionHandler {
  static String getDisplayMessage(Object exception) {
    if (exception is AppException) {
      return exception.message;
    }

    if (exception is sb.PostgrestException) {
      if (exception.message.contains('null value in column "quantity"')) {
        return 'The quantity field is required by the server.';
      }
      if (exception.message.contains('stock_available_check')) {
        return 'Insufficient stock available for this item.';
      }
      return exception.message;
    }

    if (exception is sb.AuthException) {
      final msg = exception.message.toLowerCase();
      if (msg.contains('user already registered')) return 'REGISTRATION CONFLICT: This email is already bound to a LIGTAS profile.';
      if (msg.contains('invalid login credentials')) return 'CREDENTIAL MISMATCH: Access denied to the internal network.';
      if (msg.contains('email not confirmed')) return 'PENDING AUTHORIZATION: Please verify your secure link.';
      if (msg.contains('weak password')) return 'SECURITY ALERT: Password strength does not meet Command standards.';
      return exception.message;
    }
    
    // Handle common Supabase exceptions
    final message = exception.toString().toLowerCase();
    if (message.contains('jwt')) {
      return 'Session expired. Please log in again.';
    }
    if (message.contains('network') || message.contains('socket_exception')) {
      return 'Network error. Check your internet connection.';
    }
    if (message.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
  
  static AppException fromException(Object exception) {
    if (exception is AppException) {
      return exception;
    }
    
    final display = getDisplayMessage(exception);
    final str = exception.toString().toLowerCase();

    if (str.contains('jwt') || str.contains('auth') || exception is sb.AuthException) {
      return AuthException(display);
    }
    if (str.contains('network') || str.contains('connection') || str.contains('socket')) {
      return NetworkException(display);
    }
    
    return DataException(display);
  }
}
