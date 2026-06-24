import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/app_initialization_service.dart';
import 'navigator_key.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main/main_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'تعالالي للمتاجر - T3alaly Business',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/main': (context) => const MainAppScreen(),
          '/dashboard': (context) => const MainAppScreen(),
        },
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
