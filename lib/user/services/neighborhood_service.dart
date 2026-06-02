import '../constants/app_constants.dart';
import '../models/auth_models.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class NeighborhoodService {
  static final NeighborhoodService _instance = NeighborhoodService._internal();
  factory NeighborhoodService() => _instance;
  NeighborhoodService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<List<Neighborhood>>> getNeighborhoods({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.neighborhoodsEndpoint,
        queryParameters: queryParameters,
      );

      if (response.success && response.data != null) {
        final dataContainer = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data!;

        if (dataContainer != null && dataContainer.containsKey('neighborhoods')) {
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
        print('NeighborhoodService.getNeighborhoods error: $e');
      }
      return ApiResponse<List<Neighborhood>>(
        success: false,
        error: 'حدث خطأ أثناء استرداد الأحياء: ${e.toString()}',
      );
    }
  }
}