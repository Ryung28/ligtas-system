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
  static String getDisplayMessage(Exception exception) {
    if (exception is AppException) {
      return exception.message;
    }
    
    // Handle common Supabase exceptions
    final message = exception.toString();
    if (message.contains('JWT')) {
      return 'Session expired. Please log in again.';
    }
    if (message.contains('network')) {
      return 'Network error. Please check your connection.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
  
  static AppException fromException(Exception exception) {
    if (exception is AppException) {
      return exception;
    }
    
    final message = exception.toString();
    if (message.contains('JWT') || message.contains('auth')) {
      return AuthException(ExceptionHandler.getDisplayMessage(exception));
    }
    if (message.contains('network') || message.contains('connection')) {
      return NetworkException(ExceptionHandler.getDisplayMessage(exception));
    }
    
    return DataException(ExceptionHandler.getDisplayMessage(exception));
  }
}