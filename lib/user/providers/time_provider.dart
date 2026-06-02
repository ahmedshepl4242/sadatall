import 'package:flutter/foundation.dart';
import '../utils/time_utils.dart';

class TimeProvider extends ChangeNotifier {
  TimeProvider() {
    TimeUtils.initialize();
  }

  /// Get the current time in Cairo timezone
  DateTime getCairoTimeNow() {
    return TimeUtils.toUtcTime(TimeUtils.currentTimeInCairo);
  }

  /// Convert any DateTime to Cairo time for display
  DateTime convertToCairoTime(DateTime dateTime) {
    return TimeUtils.toUtcTime(TimeUtils.toCairoTime(dateTime));
  }

  /// Format a DateTime using Cairo timezone and Arabic locale
  String formatCairoDateTime(DateTime dateTime, {String pattern = 'dd/MM/yyyy - hh:mm a'}) {
    return TimeUtils.formatCairoDateTimeArabic(dateTime, pattern: pattern);
  }

  /// Format a DateTime to Cairo date only in Arabic
  String formatCairoDate(DateTime dateTime, {String pattern = 'dd/MM/yyyy'}) {
    return TimeUtils.formatCairoDateArabic(dateTime, pattern: pattern);
  }

  /// Format a DateTime to Cairo time only in Arabic
  String formatCairoTime(DateTime dateTime, {String pattern = 'hh:mm a'}) {
    return TimeUtils.formatCairoTimeArabic(dateTime, pattern: pattern);
  }

  /// Format a DateTime to relative time in Arabic
  String formatRelativeTime(DateTime dateTime) {
    return TimeUtils.formatRelativeTimeArabic(dateTime);
  }

  /// Notify listeners when time updates (if needed for real-time updates)
  void updateTime() {
    notifyListeners();
  }
}