import 'api_exception.dart';

/// Maps various error types to user-friendly messages.
class ErrorMapper {
  ErrorMapper._();

  /// Returns a user-friendly error message from any error type.
  static String mapError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    if (error is String) {
      return error;
    }
    if (error is Exception) {
      final msg = error.toString();
      // Strip "Exception: " prefix if present
      if (msg.startsWith('Exception: ')) {
        return msg.substring(11);
      }
      return msg;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
