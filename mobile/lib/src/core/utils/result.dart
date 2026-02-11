/// Result pattern for handling success/failure states
sealed class Result<T> {
  const Result();
}

/// Success result containing data
class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

/// Failure result containing error
class Failure<T> extends Result<T> {
  const Failure(this.exception);
  final Exception exception;
}

/// Extensions for Result pattern
extension ResultExtensions<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is failure
  bool get isFailure => this is Failure<T>;
  
  /// Get data if success, null if failure
  T? get dataOrNull => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>() => null,
  };
  
  /// Get exception if failure, null if success
  Exception? get exceptionOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(exception: final exception) => exception,
  };
  
  /// Transform success data
  Result<R> map<R>(R Function(T) transform) => switch (this) {
    Success<T>(data: final data) => Success(transform(data)),
    Failure<T>(exception: final exception) => Failure(exception),
  };
  
  /// Handle both success and failure cases
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(Exception exception) onFailure,
  ) => switch (this) {
    Success<T>(data: final data) => onSuccess(data),
    Failure<T>(exception: final exception) => onFailure(exception),
  };
}