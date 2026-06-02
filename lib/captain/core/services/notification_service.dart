import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sadat_delivery_merged/captain/core/config/api_config.dart';
import '../errors/app_exceptions.dart';
import '../network/api_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiClient _apiClient = ApiClient();
  StreamSubscription<String>? _tokenSubscription;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Request permission for notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        throw const NotificationException('Notification permission denied');
      }

      // Initialize local notifications
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings(
            '@mipmap/ic_launcher',
          ); // change icon if needed
      const DarwinInitializationSettings iosInitSettings =
          DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          final payload =
              details.payload; // you passed this in _localNotifications.show()
          if (kDebugMode) {
            print('Notification tapped with payload: $payload');
          }

          if (payload != null) {
            switch (payload) {
              case 'new_order':
                // Navigate to "New Order" screen
                // NavigationService.pushNamed('/orders');
                break;
              case 'request_reply':
                // Navigate to "Requests" screen
                // NavigationService.pushNamed('/requests');
                break;
              default:
                // Maybe go to home screen
                break;
            }
          }
        },
      );

      // Configure message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle notification when app is terminated
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // Listen for token refreshes
      _tokenSubscription = _firebaseMessaging.onTokenRefresh.listen((token) {
        if (kDebugMode) {
          print('FCM Token refreshed: $token');
        }
        updateFCMTokenOnServer(token);
      });

      if (kDebugMode) {
        print('Notification service initialized successfully');
      }
    } catch (e) {
      throw NotificationException('Failed to initialize notifications: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      throw NotificationException('Failed to get FCM token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      throw NotificationException('Failed to subscribe to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      throw NotificationException(
        'Failed to unsubscribe from topic $topic: $e',
      );
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    final notification = message.notification;
    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'default_channel', // channel id
            'General Notifications', // channel name
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('order_ping'),
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'order_ping.mp3',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: message.data['type'], // pass type for navigation
      );
    }

    // Custom logic based on type
    final messageType = message.data['type'];
    switch (messageType) {
      case 'new_order':
        _handleNewOrderNotification(message);
        break;
      case 'request_reply':
        _handleRequestReplyNotification(message);
        break;
      default:
        if (kDebugMode) {
          print('Unknown notification type: $messageType');
        }
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message clicked: ${message.messageId}');
    }

    // Navigate to appropriate screen based on message type
    final messageType = message.data['type'];
    switch (messageType) {
      case 'new_order':
        // Navigate to available orders screen
        break;
      case 'request_reply':
        // Navigate to requests screen
        break;
    }
  }

  void _handleNewOrderNotification(RemoteMessage message) {
    // Handle new order notification
    if (kDebugMode) {
      print('New order notification received');
    }
    // You can add local notification or update UI state here
  }

  void _handleRequestReplyNotification(RemoteMessage message) {
    // Handle request reply notification
    if (kDebugMode) {
      print('Request reply notification received');
    }
    // You can add local notification or update UI state here
  }

  /// Updates FCM token on the server
  Future<void> updateFCMTokenOnServer(String token) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.captainsFcmToken,
        body: {'fcmToken': token},
      );

      if (response.success) {
        if (kDebugMode) {
          print('FCM token updated on server successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to update FCM token on server: ${response.error}');
        }
      }
    } catch (e) {
      // FCM token updates should not trigger auth failures
      // This is a background operation that should fail silently
      if (kDebugMode) {
        print('Error updating FCM token on server: $e');
      }
    }
  }

  /// Sends a dummy token to server (for logout)
  Future<void> sendDummyTokenToServer() async {
    try {
      const dummyToken = 'dummy_token_logged_out';
      final response = await _apiClient.put(
        ApiConfig.captainsFcmToken,
        body: {'fcmToken': dummyToken},
      );

      if (response.success) {
        if (kDebugMode) {
          print('Dummy FCM token sent to server successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send dummy FCM token to server: ${response.error}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending dummy FCM token to server: $e');
      }
    }
  }

  Future<void> cancelTokenListener() async {
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
  }
}
