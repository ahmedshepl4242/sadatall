import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/order_service.dart';
import 'navigator_key.dart';

import 'core/services/base_url_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main/main_app_screen.dart';
import 'utils/time_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for Cairo
  TimeUtils.initialize();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize API service with default URL first
  ApiService apiService = ApiService();
  apiService.initialize();

  // Fetch the base URL from Firestore and update the API service with a timeout
  print('Starting Firebase IP/URL fetch on app launch...');
  // Add timeout to prevent hanging on network issues
  try {
    final urlFetchFuture = BaseUrlService.initializeBaseUrl();
    await urlFetchFuture.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print(
            'Firebase IP/URL fetch timed out after 10 seconds, using default URL');
        return; // Return early if timeout occurs
      },
    );
    if (BaseUrlService.isInitialized) {
      print(
          'Firebase IP/URL fetch completed. Updating API service with: ${BaseUrlService.baseUrl}');
      apiService.updateBaseUrl(BaseUrlService.baseUrl);
      print('API service base URL updated');
    } else {
      print(
          'Firebase IP/URL fetch failed or was not needed. Using default URL.');
    }
  } catch (e) {
    print('Firebase IP/URL fetch failed with error: $e. Using default URL.');
  }

  // Initialize notification service with timeout
  try {
    final notificationInitFuture = NotificationService().initialize();
    await notificationInitFuture.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('Notification service initialization timed out');
        return;
      },
    );
  } catch (e) {
    print('Notification service initialization failed: $e');
  }

  // Initialize and check authentication status with timeout
  final authProvider = AuthProvider();
  try {
    final authCheckFuture = authProvider.checkAuthStatus();
    await authCheckFuture.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('Authentication check timed out, proceeding with default state');
        return;
      },
    );

    // If user is already logged in, send the FCM token to the backend
    if (authProvider.isAuthenticated) {
      await Future.delayed(const Duration(
          milliseconds:
              500)); // Small delay to ensure everything is initialized
      final notificationService = NotificationService();
      if (notificationService.fcmToken != null &&
          notificationService.fcmToken!.isNotEmpty) {
        final orderService = OrderService();
        final response =
            await orderService.updateFCMToken(notificationService.fcmToken!);
        if (kDebugMode) {
          print(response.success
              ? 'FCM token sent successfully on startup'
              : 'Failed to send FCM token on startup: ${response.error}');
        }
      }
    }
  } catch (e) {
    print('Authentication check failed: $e, proceeding with default state');
  }

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    // Check for stored notifications after app initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().checkStoredNotifications();
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'تعالالي للمتاجر - T3alaly Business',
        debugShowCheckedModeBanner: false,

        // Localization - Removed per user request

        // Theme

        // Theme
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,

        // Navigation
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/main': (context) => const MainAppScreen(),
          '/dashboard': (context) => const MainAppScreen(),
          '/order-details': (context) =>
              const Placeholder(), // This will be handled differently
        },

        // Builder for RTL support
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}
