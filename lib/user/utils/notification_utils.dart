import 'package:sadat_delivery_merged/user/services/notification_service.dart';

class NotificationUtils {
  static Future<void> subscribeToOrderNotifications(String userId) async {
    // Subscribe to user-specific notifications
    NotificationService().subscribeToTopic('user_$userId');
    
    // Subscribe to general order notifications
    NotificationService().subscribeToTopic('orders');
  }

  static Future<void> unsubscribeFromOrderNotifications(String userId) async {
    // Unsubscribe from user-specific notifications
    NotificationService().unsubscribeFromTopic('user_$userId');
    
    // Unsubscribe from general order notifications
    NotificationService().unsubscribeFromTopic('orders');
  }

  static Future<void> subscribeToVendorNotifications(String vendorId) async {
    // Subscribe to vendor-specific notifications
    NotificationService().subscribeToTopic('vendor_$vendorId');
  }

  static Future<void> subscribeToCaptainNotifications(String captainId) async {
    // Subscribe to captain-specific notifications
    NotificationService().subscribeToTopic('captain_$captainId');
  }
}