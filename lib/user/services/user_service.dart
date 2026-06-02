import '../models/user_profile.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<ApiResponse<UserProfile>> getUserProfile() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<UserProfile>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.userProfileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        final dataContainer = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data!;

        if (dataContainer != null) {
          final userProfile = UserProfile.fromJson(dataContainer);

          return ApiResponse<UserProfile>(
            success: true,
            data: userProfile,
            message: response.message ?? 'تم استرداد الملف الشخصي بنجاح',
          );
        } else {
          return ApiResponse<UserProfile>(
            success: false,
            error: 'بيانات الملف الشخصي غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<UserProfile>(
          success: false,
          error: response.error ?? 'فشل في استرداد الملف الشخصي',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserService.getUserProfile error: $e');
      }
      return ApiResponse<UserProfile>(
        success: false,
        error: 'حدث خطأ أثناء استرداد الملف الشخصي: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<UserProfile>> updateUserProfile({
    String? userName,
    String? email,
    String? address,
    String? phoneNumber,
    String? neighborhoodId,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<UserProfile>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final updateData = <String, dynamic>{};
      if (userName != null) updateData['userName'] = userName;
      if (email != null) updateData['email'] = email;
      if (address != null) updateData['address'] = address;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (neighborhoodId != null) updateData['neighborhoodId'] = neighborhoodId;

      final response = await _apiService.put<Map<String, dynamic>>(
        AppConstants.userProfileEndpoint,
        data: updateData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.success && response.data != null) {
        final dataContainer = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data!;

        if (dataContainer != null) {
          final userProfile = UserProfile.fromJson(dataContainer);

          return ApiResponse<UserProfile>(
            success: true,
            data: userProfile,
            message: response.message ?? 'تم تحديث الملف الشخصي بنجاح',
          );
        } else {
          return ApiResponse<UserProfile>(
            success: false,
            error: 'بيانات الملف الشخصي غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<UserProfile>(
          success: false,
          error: response.error ?? 'فشل في تحديث الملف الشخصي',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserService.updateUserProfile error: $e');
      }
      return ApiResponse<UserProfile>(
        success: false,
        error: 'حدث خطأ أثناء تحديث الملف الشخصي: ${e.toString()}',
      );
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });
}