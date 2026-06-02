import 'dart:io';
import '../models/menu_item.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MenuService {
  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<ApiResponse<List<MenuItem>>> getMenus(
      {int page = 1, int limit = 10}) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<List<MenuItem>>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.menusEndpoint,
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        if (response.data!.containsKey('menus')) {
          final menusData = response.data!['menus'] as List;
          final menus =
              menusData.map((menu) => MenuItem.fromJson(menu)).toList();

          return ApiResponse<List<MenuItem>>(
            success: true,
            data: menus,
            message: response.message ?? 'تم استرداد القوائم بنجاح',
          );
        } else {
          return ApiResponse<List<MenuItem>>(
            success: false,
            error: 'بيانات القوائم غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<List<MenuItem>>(
          success: false,
          error: response.error ?? 'فشل في استرداد القوائم',
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<List<MenuItem>>(
        success: false,
        error: 'حدث خطأ أثناء استرداد القوائم: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<MenuItem>> createMenu({
    required File photo,
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isAvailable,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<MenuItem>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      // Use multipart form data for creation as per schema
      final formData = FormData();

      // Add required photo field
      formData.files.add(MapEntry(
        'photo',
        await MultipartFile.fromFile(
          photo.path,
          filename: 'menu_photo.jpg',
        ),
      ));

      // Add optional fields if provided
      if (name != null) {
        formData.fields.add(MapEntry('name', name));
      }
      if (description != null) {
        formData.fields.add(MapEntry('description', description));
      }
      if (price != null) {
        formData.fields.add(MapEntry('price', price.toString()));
      }
      if (category != null) {
        formData.fields.add(MapEntry('category', category));
      }
      if (isAvailable != null) {
        formData.fields.add(MapEntry('isAvailable', isAvailable.toString()));
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.menusEndpoint,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.success && response.data != null) {
        final menu = MenuItem.fromJson(response.data!);
        return ApiResponse<MenuItem>(
            success: true,
            data: menu,
            message: response.message ?? 'تم إنشاء العنصر بنجاح',
          );
      } else {
        return ApiResponse<MenuItem>(
          success: false,
          error: response.error ?? 'فشل في إنشاء العنصر',
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<MenuItem>(
        success: false,
        error: 'حدث خطأ أثناء إنشاء العنصر: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<MenuItem>> updateMenu({
    required String id,
    String? photo, // Base64 encoded photo as per schema
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isAvailable,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<MenuItem>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      // Build update data according to schema
      final Map<String, dynamic> updateData = {};
      if (photo != null) updateData['photo'] = photo; // Base64 format
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (category != null) updateData['category'] = category;
      if (isAvailable != null) updateData['isAvailable'] = isAvailable;

      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConstants.menusEndpoint}/$id',
        data: updateData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        final menu = MenuItem.fromJson(response.data!);
        return ApiResponse<MenuItem>(
            success: true,
            data: menu,
            message: response.message ?? 'تم تحديث العنصر بنجاح',
          );
      } else {
        return ApiResponse<MenuItem>(
          success: false,
          error: response.error ?? 'فشل في تحديث العنصر',
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<MenuItem>(
        success: false,
        error: 'حدث خطأ أثناء تحديث العنصر: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> deleteMenu(String id) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<void>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.delete<Map<String, dynamic>>(
        '${AppConstants.menusEndpoint}/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success) {
        return ApiResponse<void>(
          success: true,
          message: response.message ?? 'تم حذف العنصر بنجاح',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          error: response.error ?? 'فشل في حذف العنصر',
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<void>(
        success: false,
        error: 'حدث خطأ أثناء حذف العنصر: ${e.toString()}',
      );
    }
  }

  // Future<ApiResponse<MenuStats>> getMenuStats() async {
  //   try {
  //     final token = await _authService.getAccessToken();
  //     if (token == null) {
  //       return ApiResponse<MenuStats>(
  //         success: false,
  //         error: 'غير مصرح للوصول',
  //       );
  //     }

  //     final response = await _apiService.get<Map<String, dynamic>>(
  //       AppConstants.menuStatsEndpoint,
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );

  //     if (response.success && response.data != null) {
  //       // Extract stats data from nested structure according to schema
  //       final statsData = response.data is Map<String, dynamic> &&
  //               response.data!.containsKey('data')
  //           ? response.data!['data'] as Map<String, dynamic>?
  //           : response.data;

  //       if (statsData != null) {
  //         final stats = MenuStats.fromJson(statsData);
  //         return ApiResponse<MenuStats>(
  //           success: true,
  //           data: stats,
  //           message: response.message ?? 'تم استرداد الإحصائيات بنجاح',
  //         );
  //       } else {
  //         return ApiResponse<MenuStats>(
  //           success: false,
  //           error: 'بيانات الإحصائيات غير صحيحة في الرد',
  //         );
  //       }
  //     } else {
  //       return ApiResponse<MenuStats>(
  //         success: false,
  //         error: response.error ?? 'فشل في استرداد الإحصائيات',
  //       );
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {}

  //   }
  // }
}
