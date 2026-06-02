
import 'api_service.dart';
import 'auth_service.dart';

import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import '../utils/time_utils.dart';

class NeighborhoodService {
  static final NeighborhoodService _instance = NeighborhoodService._internal();
  factory NeighborhoodService() => _instance;
  NeighborhoodService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<ApiResponse<List<Neighborhood>>> getNeighborhoods({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      // final token = await _authService.getAccessToken();
      // if (token == null) {
      //   return ApiResponse<List<Neighborhood>>(
      //     success: false,
      //     error: 'غير مصرح للوصول',
      //   );
      // }

      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '/neighborhoods',
        queryParameters: queryParameters,
        // options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.success && response.data != null) {
        final dataContainer = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data!;

        if (dataContainer != null &&
            dataContainer.containsKey('neighborhoods')) {
          final neighborhoodsData = dataContainer['neighborhoods'] as List;
          final neighborhoods = neighborhoodsData
              .map((neighborhood) => Neighborhood.fromJson(neighborhood))
              .toList();

          return ApiResponse<List<Neighborhood>>(
            success: true,
            data: neighborhoods,
            message: response.message ?? 'تم استرداد الأحياء بنجاح',
          );
        } else {
          return ApiResponse<List<Neighborhood>>(
            success: false,
            error: 'بيانات الأحياء غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<List<Neighborhood>>(
          success: false,
          error: response.error ?? 'فشل في استرداد الأحياء',
        );
      }
    } catch (e) {
      if (kDebugMode) {

      }
      return ApiResponse<List<Neighborhood>>(
        success: false,
        error: 'حدث خطأ أثناء استرداد الأحياء: ${e.toString()}',
      );
    }
  }
}

class Neighborhood {
  final String id;
  final String name;
  final tz.TZDateTime createdAt;
  final tz.TZDateTime updatedAt;

  Neighborhood({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Neighborhood.fromJson(Map<String, dynamic> json) {
    return Neighborhood(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? TimeUtils.toCairoTime(DateTime.parse(json['createdAt'].toString()))
          : TimeUtils.currentTimeInCairo,
      updatedAt: json['updatedAt'] != null 
          ? TimeUtils.toCairoTime(DateTime.parse(json['updatedAt'].toString()))
          : TimeUtils.currentTimeInCairo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
