import 'package:flutter/foundation.dart';
import '../models/complaint.dart';
import 'api_service.dart';

class ComplaintService {
  final ApiService _apiService = ApiService();

  // Submit a new complaint
  Future<ApiResponse<Complaint>> submitComplaint(String description) async {
    try {
      final response = await _apiService.post(
        '/complains',
        data: {
          'description': description,
          'type': 'USER', // Always send as "USER" for this application
        },
      );

      if (response.success && response.data != null) {
        final complaintData = response.data;
        final complaint = Complaint.fromJson(complaintData);
        return ApiResponse<Complaint>(
          success: true,
          data: complaint,
          message: response.data['message'] as String?,
        );
      } else {
        return ApiResponse<Complaint>(
          success: false,
          error: response.message ?? 'Failed to submit complaint',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting complaint: $e');
      }
      return ApiResponse<Complaint>(
        success: false,
        error: 'حدث خطأ أثناء إرسال الشكوى',
      );
    }
  }

  // Get user's complaints with pagination
  Future<ApiResponse<Map<String, dynamic>>> getUserComplaints({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/complains',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.success && response.data != null) {
        final complaintsData = response.data;
        final complaintsList = complaintsData['complains'] as List;
        final complaints = complaintsList
            .map((item) => Complaint.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: {
            'complaints': complaints,
            'pagination': complaintsData['pagination'],
          },
          message: response.data['message'] as String?,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          error: response.message ?? 'Failed to fetch complaints',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching complaints: $e');
      }
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'حدث خطأ أثناء جلب الشكاوى',
      );
    }
  }

  // Delete a complaint
  Future<ApiResponse<dynamic>> deleteComplaint(String id) async {
    try {
      final response = await _apiService.delete('/complains/$id');

      if (response.success) {
        return ApiResponse<dynamic>(
          success: true,
          message: response.data['message'] as String?,
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          error: response.message ?? 'Failed to delete complaint',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting complaint: $e');
      }
      return ApiResponse<dynamic>(
        success: false,
        error: 'حدث خطأ أثناء حذف الشكوى',
      );
    }
  }
}
