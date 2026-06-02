import '../models/category.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart' hide Category;

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/categories',
      );

      if (response.success && response.data != null) {
        // Handle nested data structure like other services
        final dataContainer = response.data is Map<String, dynamic> &&
                response.data!.containsKey('data')
            ? response.data!['data'] as Map<String, dynamic>?
            : response.data!;

        if (dataContainer != null && dataContainer.containsKey('categories')) {
          final categoriesData = dataContainer['categories'] as List;
          final categories = categoriesData
              .map((category) => Category.fromJson(category as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<Category>>(
            success: true,
            data: categories,
            message: response.message ?? 'تم استرداد التصنيفات بنجاح',
          );
        } else {
          return ApiResponse<List<Category>>(
            success: false,
            error: 'بيانات التصنيفات غير صحيحة في الرد',
          );
        }
      } else {
        return ApiResponse<List<Category>>(
          success: false,
          error: response.error ?? 'فشل في استرداد التصنيفات',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
      return ApiResponse<List<Category>>(
        success: false,
        error: 'حدث خطأ أثناء استرداد التصنيفات: ${e.toString()}',
      );
    }
  }
}
