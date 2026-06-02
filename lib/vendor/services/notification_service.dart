import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../navigator_key.dart'; // Import the global navigator key
import 'dart:convert';
import 'order_service.dart';
import 'auth_service.dart';
import '../utils/time_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final OrderService _orderService = OrderService();

  bool _isInitialized = false;
  String? _fcmToken;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      await _requestPermissions();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      // Get and save FCM token
      await _getFCMToken();

      _isInitialized = true;

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  // Check for any stored background notifications and display them
  Future<void> checkStoredNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications =
          prefs.getStringList('background_notifications') ?? [];

      if (notifications.isNotEmpty && navigatorKey.currentContext != null) {
        // Display all stored notifications
        for (final notificationStr in notifications) {
          try {
            final notificationData = jsonDecode(notificationStr);
            final title = notificationData['title'] as String?;
            final body = notificationData['body'] as String?;
            final data = notificationData['data'] as Map<String, dynamic>?;

            if (title != null || body != null) {
              // Show notification dialog
              await showDialog(
                context: navigatorKey.currentContext!,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(title ?? 'تنبيه جديد'),
                    content: Text(body ?? ''),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('إغلاق'),
                      ),
                    ],
                  );
                },
              );
            }
          } catch (e) {
            if (kDebugMode) {}
          }
        }

        // Clear stored notifications after displaying them
        await prefs.remove('background_notifications');
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {}
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Configure message handling for foreground (this is key to show system notifications when app is in foreground)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Show alert notification in foreground
      badge: true, // Update badge number in foreground
      sound: true, // Play sound in foreground
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message if app was opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      if (kDebugMode) {}

      // Only send token to backend if user is logged in
      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        final authService = AuthService();
        final isLoggedIn = await authService.isLoggedIn();

        if (isLoggedIn) {
          final response = await _orderService.updateFCMToken(_fcmToken!);
          if (!response.success && kDebugMode) {}
        } else if (kDebugMode) {}
      }

      // Listen for token refresh - only send if user is logged in
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        if (kDebugMode) {}

        if (newToken.isNotEmpty) {
          final authService = AuthService();
          final isLoggedIn = await authService.isLoggedIn();

          if (isLoggedIn) {
            final response = await _orderService.updateFCMToken(newToken);
            if (!response.success && kDebugMode) {}
          } else if (kDebugMode) {}
        }
      });
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {}

    // Show notification in a dialog or snackbar when app is in foreground
    if (navigatorKey.currentContext != null) {
      // Show in Snackbar first
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.notification?.title != null)
                Text(
                  message.notification!.title!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (message.notification?.body != null)
                Text(message.notification!.body!),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );

      // Also show as dialog for better visibility
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNotificationDialog(message);
      });
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {}

    _handleNotificationNavigation(message.data);
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final orderId = data['orderId'];

    if (kDebugMode) {}

    switch (type) {
      case 'new_order':
      case 'order_update':
        if (orderId != null) {
          // Navigate to order details using the global navigator key
          if (navigatorKey.currentContext != null) {
            try {
              // Navigate to main screen first, then navigate to order details
              navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil('/main', (route) => route.isFirst);

              // Show a snackbar indicating we're loading the order
              if (navigatorKey.currentContext != null) {
                ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                  const SnackBar(
                    content: Text('جاري تحميل تفاصيل الطلب...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }

              // We'll need to fetch the order and then navigate to its details
              // For now, we'll show a message to the user to check the orders section
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (navigatorKey.currentContext != null) {
                  ScaffoldMessenger.of(navigatorKey.currentContext!)
                      .showSnackBar(
                    SnackBar(
                      content: const Text(
                          'طلب جديد تم استلامه - يرجى التحقق من قسم الطلبات'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              });
            } catch (e) {
              if (kDebugMode) {}

              // Fallback: show dialog
              if (navigatorKey.currentContext != null) {
                showDialog(
                  context: navigatorKey.currentContext!,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('طلب جديد'),
                      content: const Text(
                          'لقد استلمت طلباً جديداً - يرجى التحقق من قسم الطلبات في التطبيق'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('موافق'),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          }
        }
        break;
      default:
        if (kDebugMode) {}
        // Show a generic dialog for unknown notification types
        if (navigatorKey.currentContext != null) {
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('تنبيه جديد'),
                content: const Text('لديك تنبيه جديد من النظام'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('موافق'),
                  ),
                ],
              );
            },
          );
        }
    }
  }

  // Show notification in a dialog for better visibility
  Future<void> _showNotificationDialog(RemoteMessage message) async {
    if (navigatorKey.currentContext == null) return;

    final title = message.notification?.title ?? 'تنبيه جديد';
    final body = message.notification?.body ?? 'لديك تنبيه جديد';

    // Don't show duplicate dialogs quickly
    await showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  // Public methods
  Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? actionData,
  }) async {
    // Create the notification message
    final message = RemoteMessage(
      notification: RemoteNotification(
        title: title,
        body: body,
      ),
      data: actionData != null ? {'actionData': actionData} : {},
    );

    // Handle it as a foreground message
    _handleForegroundMessage(message);
  }

  Future<void> clearAllNotifications() async {
    // For Firebase Cloud Messaging, notifications are automatically cleared when tapped
    // This is a placeholder method to maintain API compatibility
    // If you need more control, you would need to implement platform-specific code
    if (kDebugMode) {}

    // Clear stored background notifications
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('background_notifications');
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  // Getter methods
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  // Topic subscription methods
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  // Public method to send FCM token (can be called after login)
  Future<void> sendFCMTokenIfNeeded() async {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      await _sendFCMTokenToBackend(_fcmToken!);
    }
  }

  // Private method to send FCM token to backend - only if user is logged in
  Future<void> _sendFCMTokenToBackend(String token) async {
    try {
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();

      if (isLoggedIn) {
        final response = await _orderService.updateFCMToken(token);
        if (!response.success && kDebugMode) {
        } else if (kDebugMode) {}
      } else if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }
}

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  // Note: Only initialize if not already initialized
  try {
    if (kDebugMode) {}

    // Store notification data for when app is opened
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications =
          prefs.getStringList('background_notifications') ?? [];
      final notificationData = jsonEncode({
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'timestamp': TimeUtils.currentTimeInCairo.toUtc().toIso8601String(),
      });
      notifications.add(notificationData);

      // Keep only last 10 notifications to prevent storage bloat
      if (notifications.length > 10) {
        notifications.removeRange(0, notifications.length - 10);
      }

      await prefs.setStringList('background_notifications', notifications);
    } catch (e) {
      if (kDebugMode) {}
    }
  } catch (e) {
    if (kDebugMode) {}
  }
}
