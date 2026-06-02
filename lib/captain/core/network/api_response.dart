class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final DateTime timestamp;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'],
      message: json['message'],
      error: json['error'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}