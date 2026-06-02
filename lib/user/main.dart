import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sadat_delivery_merged/user/screens/main_screen.dart';

import 'core/config/app_initialization_service.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/time_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/splash_screen.dart';

// Global navigator key for navigation from services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all app services including fetching base URL from Firestore
  await AppInitializationService.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TimeProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'تعالالي _T3alaly',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,

        // Navigation
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/main': (context) => const MainScreen(),
          '/dashboard': (context) => const MainScreen(),
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
