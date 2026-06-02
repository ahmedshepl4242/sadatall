import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  Future<void> initialize() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the token
    _fcmToken = await _firebaseMessaging.getToken();
    if (_fcmToken != null) {
      print('FCM Token: $_fcmToken');
      // Send token to backend
      await _sendTokenToBackend(_fcmToken!);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      print('FCM Token refreshed: $newToken');
      // Send new token to backend
      await _sendTokenToBackend(newToken);
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Only send FCM token if user is logged in (has access token)
      final storageService = StorageService();
      final accessToken = await storageService.getAccessToken();
      
      if (accessToken != null && accessToken.isNotEmpty) {
        final apiService = ApiService();
        await apiService.updateFCMToken(token);
        if (kDebugMode) {
          print('FCM token sent to backend successfully');
        }
      } else if (kDebugMode) {
        print('Skipping FCM token update - user not logged in');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM token to backend: $e');
      }
    }
  }
  
  // Public method for sending FCM token to backend (used after login/signup)
  Future<void> sendTokenToBackend(String? token) async {
    if (token != null) {
      await _sendTokenToBackend(token);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.notification?.title}');
    
    // Show local notification
    _showLocalNotification(
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
    );
    
    // Handle specific notification types
    _handleNotificationData(message.data);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Background message received: ${message.notification?.title}');
    
    // Handle specific notification types in background
    _handleNotificationData(message.data);
  }

  static void _handleNotificationData(Map<String, dynamic> data) {
    final String? type = data['type'] as String?;
    final String? orderId = data['orderId'] as String?;
    final String? newStatus = data['status'] as String?;
    final String? captainName = data['captainName'] as String?;

    switch (type) {
      case 'order_status_update':
        // Handle order status update
        print('Order status update for order: $orderId, new status: $newStatus');
        break;
      case 'new_order_confirmation':
        // Handle new order confirmation
        print('New order confirmation for order: $orderId');
        break;
      case 'captain_assigned':
        // Handle captain assigned
        print('Captain $captainName assigned to order: $orderId');
        break;
      case 'order_delivered':
        // Handle order delivered
        print('Order delivered: $orderId');
        break;
      case 'order_cancelled':
        // Handle order cancelled
        print('Order cancelled: $orderId');
        break;
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<String?> getToken() async {
    return _fcmToken ?? await _firebaseMessaging.getToken();
  }

  void subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  void unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> clearAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}