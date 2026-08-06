abstract class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error occurred']) : super(message);
}

class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed']) : super(message);
}

class ValidationException extends AppException {
  const ValidationException([String message = 'Validation failed']) : super(message);
}

class LocationException extends AppException {
  const LocationException([String message = 'Location service error']) : super(message);
}

class NotificationException extends AppException {
  const NotificationException([String message = 'Notification service error']) : super(message);
}

class CacheException extends AppException {
  const CacheException([String message = 'Cache operation failed']) : super(message);
}