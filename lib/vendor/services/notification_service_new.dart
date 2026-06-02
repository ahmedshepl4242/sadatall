
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'order_service.dart';

// Global key for accessing navigator state
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService initialization error: $e');
      }
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

    if (kDebugMode) {
      print('Notification permission status: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
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

    // Configure message handling when app is in background
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }

      // Send token to backend
      if (_fcmToken != null) {
        await _orderService.updateFCMToken(_fcmToken!);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
        await _orderService.updateFCMToken(newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Show notification in a dialog or snackbar when app is in foreground
    if (navigatorKey.currentContext != null) {
      // Show in Snackbar
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
          action: message.data['orderId'] != null
              ? SnackBarAction(
                  label: 'View',
                  onPressed: () => _handleNotificationNavigation(message.data),
                )
              : null,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    _handleNotificationNavigation(message.data);
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final orderId = data['orderId'];

    switch (type) {
      case 'new_order':
      case 'order_update':
        if (orderId != null) {
          // Navigate to order details using the global navigator key
          if (kDebugMode) {
            print('Navigate to order: $orderId');
          }
          // Example navigation using global key (you'll need to implement the actual route)
          // navigatorKey.currentState?.pushNamed('/order-details', arguments: orderId);
        }
        break;
      case 'customer_message':
        if (kDebugMode) {
          print('Navigate to customer message');
        }
        // navigatorKey.currentState?.pushNamed('/customer-message');
        break;
      default:
        if (kDebugMode) {
          print('Unknown notification type: $type');
        }
    }
  }

  // Utility methods
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic $topic: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic $topic: $e');
      }
    }
  }
}

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: you may want to initialize Firebase here if using other Firebase services
  if (kDebugMode) {
    print('Handling background message:');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}
