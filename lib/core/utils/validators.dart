/// Form validation utilities.
/// Provides reusable validators for common input fields.
class Validators {
  Validators._();

  /// Validates that a field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates phone number (10 digits).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Validates phone number (optional — only validates format if not empty).
  static String? phoneOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return phone(value);
  }

  /// Validates minimum length.
  static String? minLength(String? value, int length, [String fieldName = 'This field']) {
    if (value == null || value.length < length) {
      return '$fieldName must be at least $length characters';
    }
    return null;
  }

  /// Validates password.
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates email (optional — only validates format if not empty).
  static String? emailOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return email(value);
  }
}
