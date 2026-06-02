import '../constants/app_constants.dart';
import '../models/order.dart';
import '../models/attachment.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class UserOrderService {
  static final UserOrderService _instance = UserOrderService._internal();
  factory UserOrderService() => _instance;
  UserOrderService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<ApiResponse<List<Order>>> getUserOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<List<Order>>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParameters['status'] = status;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.userOrdersEndpoint,
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        final dataContainer = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data!;

        if (dataContainer != null && dataContainer.containsKey('orders')) {
          final ordersData = dataContainer['orders'] as List;
          final orders = ordersData
              .map((order) => Order.fromJson(order))
              .toList();

          return ApiResponse<List<Order>>(
            success: true,
            data: orders,
            message: response.message ?? 'تم استرداد الطلبات بنجاح',
          );
        } else {
          return ApiResponse<List<Order>>(
            success: false,
            error: 'بيانات الطلبات غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<List<Order>>(
          success: false,
          error: response.error ?? 'فشل في استرداد الطلبات',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserOrderService.getUserOrders error: $e');
      }
      return ApiResponse<List<Order>>(
        success: false,
        error: 'حدث خطأ أثناء استرداد الطلبات: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Order>> createOrder({
    required String vendorId,
    required String description,
    required String additionalNotes,
    required String userAddress,
    required String phoneNumber,
    required double userLatitude,
    required double userLongitude,
    required String neighborhoodId,
    List<Attachment>? attachments,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<Order>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final requestData = {
        'vendorId': vendorId == '-1' ? -1 : int.parse(vendorId),
        'description': description,
        'additionalNotes': additionalNotes,
        'userAddress': userAddress,
        'phoneNumber': phoneNumber,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'neighborhoodId': int.parse(neighborhoodId),
      };

      // Add attachments if present
      if (attachments != null && attachments.isNotEmpty) {
        requestData['attachments'] = attachments.map((a) => a.toJson()).toList();
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.createOrderByUserEndpoint,
        data: requestData,
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
          final order = Order.fromJson(dataContainer);

          return ApiResponse<Order>(
            success: true,
            data: order,
            message: response.message ?? 'تم إنشاء الطلب بنجاح',
          );
        } else {
          return ApiResponse<Order>(
            success: false,
            error: 'بيانات الطلب غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<Order>(
          success: false,
          error: response.error ?? 'فشل في إنشاء الطلب',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserOrderService.createOrder error: $e');
      }
      return ApiResponse<Order>(
        success: false,
        error: 'حدث خطأ أثناء إنشاء الطلب: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Order>> approveOrder(String orderId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<Order>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConstants.approveOrderEndpoint}/$orderId/user-approve',
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
          final order = Order.fromJson(dataContainer);

          return ApiResponse<Order>(
            success: true,
            data: order,
            message: response.message ?? 'تم قبول الطلب بنجاح',
          );
        } else {
          return ApiResponse<Order>(
            success: false,
            error: 'بيانات الطلب غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<Order>(
          success: false,
          error: response.error ?? 'فشل في قبول الطلب',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserOrderService.approveOrder error: $e');
      }
      return ApiResponse<Order>(
        success: false,
        error: 'حدث خطأ أثناء قبول الطلب: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<bool>> deleteOrder(String orderId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<bool>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.delete<Map<String, dynamic>>(
        '${AppConstants.deleteOrderEndpoint}/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success) {
        return ApiResponse<bool>(
          success: true,
          data: true,
          message: response.message ?? 'تم حذف الطلب بنجاح',
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          error: response.error ?? 'فشل في حذف الطلب',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserOrderService.deleteOrder error: $e');
      }
      return ApiResponse<bool>(
        success: false,
        error: 'حدث خطأ أثناء حذف الطلب: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<bool>> rateOrder(String orderId, int rating) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return ApiResponse<bool>(
          success: false,
          error: 'غير مصرح للوصول',
        );
      }

      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConstants.deleteOrderEndpoint}/$orderId/rate',
        data: {
          'rating': rating,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: Headers.jsonContentType,
        ),
      );

      // Check success field only as requested in the script
      if (response.success) {
        return ApiResponse<bool>(
          success: true,
          data: true,
          message: response.message ?? 'تم تقييم الطلب بنجاح',
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          error: response.error ?? 'فشل في تقييم الطلب',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserOrderService.rateOrder error: $e');
      }
      return ApiResponse<bool>(
        success: false,
        error: 'حدث خطأ أثناء تقييم الطلب: ${e.toString()}',
      );
    }
  }
}