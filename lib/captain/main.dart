import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_initialization_service.dart';
import 'core/services/firebase_config_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/captain_locked_screen.dart';
import 'main_navigation.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializationService.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'تعالالي _T3alaly',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigation(),
        '/dashboard': (context) => const MainNavigation(),
      },
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

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
            title: const Text('تحديث مطلوب', textAlign: TextAlign.center),
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
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
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

    if (authState.isLocked) {
      return const CaptainLockedScreen();
    }

    return authState.isAuthenticated ? const MainNavigation() : const LoginScreen();
  }
}
