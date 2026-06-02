import 'dart:io';
import 'package:sadat_delivery_merged/vendor/constants/app_constants.dart';
import 'package:sadat_delivery_merged/vendor/core/config/api_config.dart';

import '../models/product_item.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ItemService {
  static final ItemService _instance = ItemService._internal();
  factory ItemService() => _instance;
  ItemService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Endpoint from script.txt
  static const String _itemsEndpoint = AppConstants.itemsEndpoint;

  Future<ApiResponse<List<ProductItem>>> getItems(
      {int page = 1, int limit = 10}) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<List<ProductItem>>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final vendor = await _authService.getCurrentVendor();
      if (vendor == null) {
        return ApiResponse<List<ProductItem>>(
          success: false,
          error: 'لم يتم العثور على بيانات البائع',
        );
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        "$_itemsEndpoint/vendors/${vendor.id}",
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        if (response.data!.containsKey('items')) {
          final itemsData = response.data!['items'] as List;
          final items =
              itemsData.map((item) => ProductItem.fromJson(item)).toList();

          return ApiResponse<List<ProductItem>>(
            success: true,
            data: items,
            message: response.message ?? 'تم استرداد المنتجات بنجاح',
          );
        } else {
          return ApiResponse<List<ProductItem>>(
            success: false,
            error: 'بيانات المنتجات غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<List<ProductItem>>(
          success: false,
          error: response.error ?? 'فشل في استرداد المنتجات',
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<List<ProductItem>>(
        success: false,
        error: 'حدث خطأ أثناء استرداد المنتجات: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<ProductItem>> createItem({
    required File image,
    required String name,
    required String description,
    required double price,
    bool? isAvailable,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<ProductItem>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      // Use multipart form data for creation
      final formData = FormData();

      // Add required image field (actual file, not imageUrl)
      formData.files.add(MapEntry(
        'photo',
        await MultipartFile.fromFile(
          image.path,
          filename: 'item_image.jpg',
        ),
      ));

      // Add required fields
      formData.fields.add(MapEntry('name', name));
      formData.fields.add(MapEntry('description', description));
      formData.fields.add(MapEntry('price', price.toString()));

      // Add optional fields
      if (isAvailable != null) {
        formData.fields.add(MapEntry('isAvailable', isAvailable.toString()));
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        _itemsEndpoint,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.success && response.data != null) {
        final item = ProductItem.fromJson(response.data!);
        return ApiResponse<ProductItem>(
          success: true,
          data: item,
          message: response.message ?? 'تم إنشاء المنتج بنجاح',
        );
      } else {
        return ApiResponse<ProductItem>(
          success: false,
          error: response.error ?? 'فشل في إنشاء المنتج',
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<ProductItem>(
        success: false,
        error: 'حدث خطأ أثناء إنشاء المنتج: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<ProductItem>> updateItem({
    required String id,
    File? image, // Actual file for upload, not imageUrl
    String? name,
    String? description,
    double? price,
    bool? isAvailable,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<ProductItem>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      // Use multipart form data if image is provided
      if (image != null) {
        final formData = FormData();

        // Add image file
        formData.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(
            image.path,
            filename: 'item_image.jpg',
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
        if (isAvailable != null) {
          formData.fields.add(MapEntry('isAvailable', isAvailable.toString()));
        }

        final response = await _apiService.put<Map<String, dynamic>>(
          '$_itemsEndpoint/$id',
          data: formData,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            contentType: 'multipart/form-data',
          ),
        );

        if (response.success && response.data != null) {
          final item = ProductItem.fromJson(response.data!);
          return ApiResponse<ProductItem>(
            success: true,
            data: item,
            message: response.message ?? 'تم تحديث المنتج بنجاح',
          );
        } else {
          return ApiResponse<ProductItem>(
            success: false,
            error: response.error ?? 'فشل في تحديث المنتج',
          );
        }
      } else {
        // No image update, use JSON
        final Map<String, dynamic> updateData = {};
        if (name != null) updateData['name'] = name;
        if (description != null) updateData['description'] = description;
        if (price != null) updateData['price'] = price;
        if (isAvailable != null) updateData['isAvailable'] = isAvailable;

        final response = await _apiService.put<Map<String, dynamic>>(
          '$_itemsEndpoint/$id',
          data: updateData,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (response.success && response.data != null) {
          final item = ProductItem.fromJson(response.data!);
          return ApiResponse<ProductItem>(
            success: true,
            data: item,
            message: response.message ?? 'تم تحديث المنتج بنجاح',
          );
        } else {
          return ApiResponse<ProductItem>(
            success: false,
            error: response.error ?? 'فشل في تحديث المنتج',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<ProductItem>(
        success: false,
        error: 'حدث خطأ أثناء تحديث المنتج: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> deleteItem(String id) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<void>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.delete<Map<String, dynamic>>(
        '$_itemsEndpoint/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success) {
        return ApiResponse<void>(
          success: true,
          message: response.message ?? 'تم حذف المنتج بنجاح',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          error: response.error ?? 'فشل في حذف المنتج',
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<void>(
        success: false,
        error: 'حدث خطأ أثناء حذف المنتج: ${e.toString()}',
      );
    }
  }
}
