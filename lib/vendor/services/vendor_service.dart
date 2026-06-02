import 'dart:io';
import '../models/vendor.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class VendorService {
  static final VendorService _instance = VendorService._internal();
  factory VendorService() => _instance;
  VendorService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<ApiResponse<Vendor>> getProfile() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<Vendor>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.vendorProfileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        // Extract vendor data from nested structure according to schema
        final vendorData = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data;

        if (vendorData != null) {
          final vendor = Vendor.fromJson(vendorData);
          // Check if the vendor is locked based on the isLocked field
          if (vendor.isLocked == true) {
            return ApiResponse<Vendor>(
              success: false,
              error: 'يرجى الانتظار حتى يتم فتح الحساب',
            );
          }
          return ApiResponse<Vendor>(
            success: true,
            data: vendor,
            message: response.message ?? 'تم استرداد البيانات بنجاح',
          );
        } else {
          return ApiResponse<Vendor>(
            success: false,
            error: 'بيانات المطعم غير صحيحة في الرد',
          );
        }
      } else {
        // Check if the error is specifically about the vendor being locked
        if (response.error != null && 
            (response.error!.toLowerCase().contains('vendor is locked'))) {
          return ApiResponse<Vendor>(
            success: false,
            error: 'يرجى الانتظار حتى يتم فتح الحساب',
          );
        } else {
          return ApiResponse<Vendor>(
            success: false,
            error: response.error ?? 'فشل في استرداد البيانات',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<Vendor>(
        success: false,
        error: 'حدث خطأ أثناء استرداد البيانات: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Vendor>> updateProfile({
    String? vendorName,
    String? contactNumber,
    String? address,
    String? description,
    double? latitude,
    double? longitude,
    int? neighborhoodId,
    List<int>? categories,
    File? image,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<Vendor>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      FormData formData = FormData();

      if (vendorName != null)
        formData.fields.add(MapEntry('vendorName', vendorName));
      if (contactNumber != null)
        formData.fields.add(MapEntry('contactNumber', contactNumber));
      if (address != null) formData.fields.add(MapEntry('address', address));
      if (description != null)
        formData.fields.add(MapEntry('description', description));
      if (latitude != null)
        formData.fields.add(MapEntry('latitude', latitude.toString()));
      if (longitude != null)
        formData.fields.add(MapEntry('longitude', longitude.toString()));
      if (neighborhoodId != null)
        formData.fields
            .add(MapEntry('neighborhoodId', neighborhoodId.toString()));
      if (categories != null) {
        // Send categories as comma-separated string or individual fields
        // Try multiple formats to match backend expectations
        formData.fields.add(MapEntry('categories', categories.join(',')));
      }

      if (image != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(image.path),
        ));
      }

      final response = await _apiService.put<Map<String, dynamic>>(
        AppConstants.vendorProfileEndpoint,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        // Extract vendor data from nested structure according to schema
        final vendorData = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data;

        if (vendorData != null) {
          final vendor = Vendor.fromJson(vendorData);
          // Check if the vendor is locked based on the isLocked field
          if (vendor.isLocked == true) {
            return ApiResponse<Vendor>(
              success: false,
              error: 'يرجى الانتظار حتى يتم فتح الحساب',
            );
          }
          return ApiResponse<Vendor>(
            success: true,
            data: vendor,
            message: response.message ?? 'تم تحديث البيانات بنجاح',
          );
        } else {
          return ApiResponse<Vendor>(
            success: false,
            error: 'بيانات المطعم غير صحيحة في الرد',
          );
        }
      } else {
        // Check if the error is specifically about the vendor being locked
        if (response.error != null && 
            (response.error!.toLowerCase().contains('vendor is locked'))) {
          return ApiResponse<Vendor>(
            success: false,
            error: 'يرجى الانتظار حتى يتم فتح الحساب',
          );
        } else {
          return ApiResponse<Vendor>(
            success: false,
            error: response.error ?? 'فشل في تحديث البيانات',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<Vendor>(
        success: false,
        error: 'حدث خطأ أثناء تحديث البيانات: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getStatus() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.vendorStatusEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        // Extract data from nested structure according to schema
        final statusData = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data;
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: statusData,
          message: response.message ?? 'تم استرداد الحالة بنجاح',
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          error: response.error ?? 'فشل في استرداد الحالة',
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'حدث خطأ أثناء استرداد الحالة: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Vendor>> updateStatus(String isOpen) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<Vendor>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.put<Map<String, dynamic>>(
        AppConstants.vendorStatusEndpoint,
        data: {'isOpen': isOpen},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        // Extract vendor data from nested structure according to schema
        final vendorData = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data;

        if (vendorData != null) {
          final vendor = Vendor.fromJson(vendorData);
          // Check if the vendor is locked based on the isLocked field
          if (vendor.isLocked == true) {
            return ApiResponse<Vendor>(
              success: false,
              error: 'يرجى الانتظار حتى يتم فتح الحساب',
            );
          }
          return ApiResponse<Vendor>(
            success: true,
            data: vendor,
            message: response.message ?? 'تم تحديث الحالة بنجاح',
          );
        } else {
          return ApiResponse<Vendor>(
            success: false,
            error: 'بيانات المطعم غير صحيحة في الرد',
          );
        }
      } else {
        // Check if the error is specifically about the vendor being locked
        if (response.error != null && 
            (response.error!.toLowerCase().contains('vendor is locked'))) {
          return ApiResponse<Vendor>(
            success: false,
            error: 'يرجى الانتظار حتى يتم فتح الحساب',
          );
        } else {
          return ApiResponse<Vendor>(
            success: false,
            error: response.error ?? 'فشل في تحديث الحالة',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {}
      return ApiResponse<Vendor>(
        success: false,
        error: 'حدث خطأ أثناء تحديث الحالة: ${e.toString()}',
      );
    }
  }
}
