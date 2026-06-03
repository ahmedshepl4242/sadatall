import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../core/config/api_config.dart';
import 'storage_service.dart';
import 'package:sadat_delivery_merged/main.dart' show navigatorKey;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final StorageService _storageService = StorageService();
  String? _currentBaseUrl; // Store the current base URL

  void initialize() {
    _initializeInternal();
  }

  /// Async initialization that ensures the base URL is loaded from storage
  Future<void> initializeAsync() async {
    await _initializeInternalAsync();
  }

  /// Asynchronous internal initialization that reloads base URL from storage
  Future<void> _initializeInternalAsync() async {
    // Get the base URL directly from storage for initial setup
    final baseUrl = await _getCurrentBaseUrlFromStorage();
    _currentBaseUrl = baseUrl; // Store it for reference

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Tenant-ID': AppConstants.tenantId,
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString(), wrapWidth: 2048),
        ),
      );
    }

    _setupInterceptors();
  }

  void _initializeInternal() {
    // For sync initialization, we'll try to get a current URL with fallback
    // The most recent one is stored in _currentBaseUrl, otherwise get from config manager
    final baseUrl = _currentBaseUrl ?? _getBaseUrl();

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Tenant-ID': AppConstants.tenantId,
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString(), wrapWidth: 2048),
        ),
      );
    }

    _setupInterceptors();
  }

  /// Gets the current base URL, trying to use the dynamic one if available
  String _getBaseUrl() {
    try {
      return ApiConfigManager().getBaseUrl();
    } catch (e) {
      // If ApiConfigManager is not initialized yet, fall back to default
      return AppConstants.baseUrl;
    }
  }

  /// Reinitializes the API service with the updated base URL
  void reinitialize() {
    _initializeInternal();
  }

  /// Gets the current base URL directly from storage
  Future<String> _getCurrentBaseUrlFromStorage() async {
    try {
      // Use the ApiConfigManager's async method that gets directly from storage
      return await ApiConfigManager().getBaseUrlAsync();
    } catch (e) {
      // If everything fails, fall back to default
      return AppConstants.baseUrl;
    }
  }

  /// Reloads the base URL from local storage and reinitializes if changed
  Future<void> reloadBaseUrlFromStorage() async {
    await ApiConfigManager().reloadBaseUrlFromStorage();
    // Reinitialize to use the potentially updated base URL
    _initializeInternal();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the current base URL from storage
          final currentBaseUrl = await _getCurrentBaseUrlFromStorage();

          // Update our stored reference
          _currentBaseUrl = currentBaseUrl;

          // Only update the options if the base URL has actually changed
          if (currentBaseUrl != _dio.options.baseUrl ||
              currentBaseUrl != options.baseUrl) {
            // Update the base URL for this request if it has changed
            options.baseUrl = currentBaseUrl;
          }

          final token = await _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Print the request with token information
          // if (kDebugMode) {
          //   print('=== REQUEST ===');
          //   print('Method: ${options.method}');
          //   print('URL: ${options.uri}');
          //   print('Headers: ${options.headers}');
          //   if (options.queryParameters.isNotEmpty) {
          //     print('Query: ${options.queryParameters}');
          //   }
          //   if (options.data is FormData) {
          //     print(
          //         'Data: FormData with ${(options.data as FormData).fields.length} fields and ${(options.data as FormData).files.length} files');
          //     for (var field in (options.data as FormData).fields) {
          //       print('Field: ${field.key} = ${field.value}');
          //     }
          //     for (var file in (options.data as FormData).files) {
          //       print('File: ${file.key} = ${file.value.filename}');
          //     }
          //   } else {
          //     print('Data: ${options.data}');
          //   }
          //   print('================');
          // }

          handler.next(options);
        },
        onResponse: (response, handler) {
          // Print the response
          if (kDebugMode) {
            // print('=== RESPONSE ===');
            // print('Method: ${response.requestOptions.method}');
            // print('URL: ${response.requestOptions.path}');
            // print('Status Code: ${response.statusCode}');
            // print('Headers: ${response.headers}');
            // print('Data: ${response.data}');
            // print('================');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          // Print the error
          if (kDebugMode) {
            // print('=== ERROR ===');
            // print('Method: ${error.requestOptions.method}');
            // print('URL: ${error.requestOptions.path}');
            // print('Status Code: ${error.response?.statusCode}');
            // print('Message: ${error.message}');
            // print('Data: ${error.response?.data}');
            // print('================');
          }

          if (error.response?.statusCode == 401) {
            // Check if this is a refresh token request itself to avoid infinite loop
            if (error.requestOptions.path
                .contains(AppConstants.refreshTokenEndpoint)) {
              // If the refresh token endpoint itself returns 401, clear tokens and navigate to login immediately
              await _storageService.clearAllTokens();

              // if (kDebugMode) {
              //   print(
              //       '=== REFRESH TOKEN ENDPOINT FAILED - REDIRECTING TO LOGIN ===');
              //   print('Method: ${error.requestOptions.method}');
              //   print('URL: ${error.requestOptions.path}');
              //   print('================');
              // }

              // Navigate to login screen
              if (navigatorKey.currentContext != null) {
                Navigator.of(navigatorKey.currentContext!)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
              return;
            }

            final refreshed = await _refreshToken();
            if (refreshed) {
              final newToken = await _storageService.getAccessToken();
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';

              try {
                final response = await _dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );

                // Check if the retry response is still unauthorized
                if (response.statusCode == 401) {
                  // If still unauthorized after refresh, clear tokens and navigate to login
                  await _storageService.clearAllTokens();

                  // if (kDebugMode) {
                  //   print(
                  //       '=== RETRY STILL UNAUTHORIZED - REDIRECTING TO LOGIN ===');
                  //   print('Method: ${response.requestOptions.method}');
                  //   print('URL: ${response.requestOptions.path}');
                  //   print('Status Code: ${response.statusCode}');
                  //   print('================');
                  // }

                  // Navigate to login screen
                  if (navigatorKey.currentContext != null) {
                    Navigator.of(navigatorKey.currentContext!)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                  return;
                }

                // // Print the retry response
                // if (kDebugMode) {
                //   print('=== RETRY RESPONSE (after token refresh) ===');
                //   print('Method: ${response.requestOptions.method}');
                //   print('URL: ${response.requestOptions.path}');
                //   print('Status Code: ${response.statusCode}');
                //   print('Headers: ${response.headers}');
                //   print('Data: ${response.data}');
                //   print('================');
                // }

                handler.resolve(response);
                return;
              } catch (e) {
                // If retry fails, clear tokens and navigate to login
                if (kDebugMode) {
                  print('=== RETRY FAILED - REDIRECTING TO LOGIN ===');
                  print('Method: ${error.requestOptions.method}');
                  print('URL: ${error.requestOptions.path}');
                  print('Error: $e');
                  print('================');
                }

                await _storageService.clearAllTokens();

                // Navigate to login screen
                if (navigatorKey.currentContext != null) {
                  Navigator.of(navigatorKey.currentContext!)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                }
                return;
              }
            } else {
              // If refresh token is invalid, clear all tokens and navigate to login
              await _storageService.clearAllTokens();

              if (kDebugMode) {
                print('=== REFRESH TOKEN INVALID - REDIRECTING TO LOGIN ===');
                print('Method: ${error.requestOptions.method}');
                print('URL: ${error.requestOptions.path}');
                print('================');
              }

              // Navigate to login screen
              if (navigatorKey.currentContext != null) {
                Navigator.of(navigatorKey.currentContext!)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      // if (kDebugMode) {
      //   print('=== REFRESH TOKEN REQUEST ===');
      //   print('Method: POST');
      //   print('URL: ${AppConstants.refreshTokenEndpoint}');
      //   print('Data: {type: user, refreshToken: $refreshToken}');
      //   print('================');
      // }

      final response = await _dio.post(
        AppConstants.refreshTokenEndpoint,
        data: {
          'type': 'user',
          'refreshToken': refreshToken,
        },
      );

      // if (kDebugMode) {
      //   print('=== REFRESH TOKEN RESPONSE ===');
      //   print('Method: POST');
      //   print('URL: ${AppConstants.refreshTokenEndpoint}');
      //   print('Status Code: ${response.statusCode}');
      //   print('Data: ${response.data}');
      //   print('================');
      // }

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']?['accessToken'] ??
            response.data['data']?['token'];
        final newRefreshToken = response.data['data']?['refreshToken'];

        if (newAccessToken != null) {
          await _storageService.saveAccessToken(newAccessToken.toString());
        }
        if (newRefreshToken != null) {
          await _storageService.saveRefreshToken(newRefreshToken.toString());
        }

        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('=== REFRESH TOKEN ERROR ===');
        print('Method: POST');
        print('URL: ${AppConstants.refreshTokenEndpoint}');
        print('Error: $e');
        print('================');
        debugPrint('Token refresh failed: $e');
      }
    }
    return false;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();

      // Add file
      formData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(file.path),
      ));

      // Add other data
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  Future<ApiResponse<dynamic>> updateFCMToken(String token) async {
    try {
      final response = await _dio.put(
        AppConstants.fcmTokenEndpoint,
        data: {'fcmToken': token},
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse.fromException(e);
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.fromResponse(Response response) {
    final responseData = response.data;

    if (responseData is Map<String, dynamic>) {
      return ApiResponse(
        success: responseData['success'] ?? true,
        data: responseData['data'],
        message: responseData['message'],
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      success: response.statusCode! >= 200 && response.statusCode! < 300,
      data: responseData,
      statusCode: response.statusCode,
    );
  }

  factory ApiResponse.fromError(DioException error) {
    String errorMessage = 'حدث خطأ غير متوقع '+'(DioException): ${error.message}';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'انتهت مهلة الاتصال';
    } else if (error.type == DioExceptionType.connectionError) {
      errorMessage = 'خطأ في الاتصال بالشبكة';
    } else if (error.response?.data is Map<String, dynamic>) {
      final responseData = error.response!.data as Map<String, dynamic>;
      // Try 'error' first (validation failures), then 'message', then fallback
      final details = responseData['details'];
      if (details is List && details.isNotEmpty) {
        errorMessage = details
            .map((d) => d['msg']?.toString() ?? '')
            .where((m) => m.isNotEmpty)
            .join('\n');
      } else {
        errorMessage = responseData['error']?.toString() ??
            responseData['message']?.toString() ??
            errorMessage;
      }
    }

    return ApiResponse(
      success: false,
      error: errorMessage,
      statusCode: error.response?.statusCode,
    );
  }

  factory ApiResponse.fromException(dynamic exception) {
    return ApiResponse(
      success: false,
      error: 'حدث خطأ غير متوقع: ${exception.toString()}',
    );
  }
}
