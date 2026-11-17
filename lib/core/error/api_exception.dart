import 'package:dio/dio.dart';

/// Custom exception class for API errors.
/// Wraps Dio exceptions into user-friendly error messages.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  /// Factory constructor to create [ApiException] from a [DioException].
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your internet connection.',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Unable to connect to server. Please check your internet connection.',
        );
      default:
        return ApiException(
          message: 'An unexpected error occurred. Please try again.',
          statusCode: e.response?.statusCode,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message;
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'].toString();
    } else {
      message = switch (statusCode) {
        400 => 'Bad request. Please check your input.',
        401 => 'Unauthorized. Please login again.',
        403 => 'You do not have permission to perform this action.',
        404 => 'The requested resource was not found.',
        409 => 'A conflict occurred. Please try again.',
        422 => 'Validation failed. Please check your input.',
        500 => 'Server error. Please try again later.',
        502 => 'Server is temporarily unavailable.',
        503 => 'Service unavailable. Please try again later.',
        _ => 'An unexpected error occurred.',
      };
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
