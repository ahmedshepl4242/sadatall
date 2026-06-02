import 'dart:math';

import 'package:intl/intl.dart';

class AppUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date.toLocal());
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime.toLocal());
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time.toLocal());
  }

  static String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} ج.م';
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()} م';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} كم';
    }
  }

  static String getOrderStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'في الانتظار';
      case 'COUNTER_OFFER_SENT':
        return 'تم إرسال العرض المقابل';
      case 'COUNTER_OFFER_ACCEPTED':
        return 'تم قبول العرض المقابل';
      case 'ACCEPTED_BY_CAPTAIN':
        return 'تم قبوله من الكابتن';
      case 'DELIVERED':
        return 'تم التسليم';
      case 'CANCELLED':
        return 'ملغى';
      default:
        return status;
    }
  }

  static String getRequestStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'في الانتظار';
      case 'APPROVED':
        return 'موافق عليه';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return status;
    }
  }

  static bool isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth radius in meters

    final double lat1Rad = lat1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double deltaLatRad = (lat2 - lat1) * (pi / 180);
    final double deltaLonRad = (lon2 - lon1) * (pi / 180);

    final double a =
        pow(sin(deltaLatRad / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLonRad / 2), 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  static bool isRTL(String text) {
    return RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ).hasMatch(text);
  }

  /// Converts error messages to user-friendly Arabic messages
  static String getLocalizedErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    // Network related errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable') ||
        errorString.contains('failed host lookup')) {
      return 'خطأ في الاتصال. تأكد من اتصالك بالإنترنت';
    }

    // Authentication errors
    if (errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('authentication') ||
        errorString.contains('token')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى';
    }

    // Permission errors
    if (errorString.contains('forbidden') ||
        errorString.contains('403') ||
        errorString.contains('permission')) {
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    }

    // Server errors
    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
    }

    // Order-specific errors
    if (errorString.contains('not available for pickup')) {
      return 'الطلب غير متاح حالياً. ربما تم قبوله من كابتن آخر';
    }
    if (errorString.contains('maximum order capacity')) {
      return 'لقد وصلت للحد الأقصى من الطلبات الحالية';
    }
    if (errorString.contains('delivery price is required')) {
      return 'سعر التوصيل مطلوب للطلبات الخاصة';
    }
    if (errorString.contains('already exists')) {
      return 'البيانات موجودة مسبقاً (البريد أو اسم المستخدم أو رقم الهاتف)';
    }

    // Not found errors
    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'المورد المطلوب غير موجود';
    }

    // Validation errors
    if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('bad request:') ||
        errorString.contains('statuscode: 400')) {
      return 'البيانات المدخلة غير صحيحة';
    }

    // Generic fallback
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }
}
