import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:sadat_delivery_merged/captain/core/services/location_tracking_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/firebase_config_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/captain_locked_screen.dart';
import 'main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the dynamic base URL configuration
  try {
    final baseUrl = await FirebaseConfigService.getBaseUrlWithFallback();
    // print("Using Base URL: $baseUrl");
  } catch (e) {
    // print("Error initializing dynamic base URL: $e");
  }

  // Initialize Firebase (using default config for other services)
  await Firebase.initializeApp();

  // Initialize notification service
  try {
    await NotificationService().initialize();
    print("Notification service initialized successfully");
  } catch (e) {
    debugPrint('Failed to initialize notification service: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SADAT Captain',
      theme: AppTheme.light,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVersion());
  }

  Future<void> _checkVersion() async {
    final requiredVersion = await FirebaseConfigService.checkForceUpdate();
    if (requiredVersion != null && mounted) {
      _showForceUpdateDialog(requiredVersion);
    }
  }

  void _showForceUpdateDialog(String requiredVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'تحديث مطلوب',
              textAlign: TextAlign.center,
            ),
            content: Text(
              'يتطلب التطبيق تحديثاً إلى الإصدار $requiredVersion أو أحدث.\n'
              'يرجى تحديث التطبيق للمتابعة.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  const storeUrl =
                      'https://play.google.com/store/apps/details?id=com.sadat.delivery_captain';
                  final uri = Uri.parse(storeUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('تحديث الآن'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check if captain is locked (handles both signup and login with locked captains)
    if (authState.isLocked) {
      return const CaptainLockedScreen();
    }

    return authState.isAuthenticated
        ? const MainNavigation()
        : const LoginScreen();
  }
}
