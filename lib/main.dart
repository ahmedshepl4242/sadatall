import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App mode
import 'app_mode.dart';

// Mode selector
import 'mode_selector/mode_selector_screen.dart';

// ── Captain imports ──────────────────────────────────────────────────────────
import 'captain/core/theme/app_theme.dart' as captain_theme;
import 'captain/core/services/notification_service.dart' as captain_notif;
import 'captain/core/services/firebase_config_service.dart';
import 'captain/features/auth/presentation/providers/auth_provider.dart'
    as captain_auth;
import 'captain/features/auth/presentation/screens/login_screen.dart'
    as captain_login;
import 'captain/features/auth/presentation/screens/captain_locked_screen.dart';
import 'captain/main_navigation.dart';

// ── Vendor imports ────────────────────────────────────────────────────────────
import 'vendor/theme/app_theme.dart' as vendor_theme;
import 'vendor/providers/auth_provider.dart' as vendor_auth;
import 'vendor/services/api_service.dart';
import 'vendor/services/notification_service.dart' as vendor_notif;
import 'vendor/core/services/base_url_service.dart';
import 'vendor/screens/auth/login_screen.dart' as vendor_login;
import 'vendor/screens/auth/signup_screen.dart' as vendor_signup;
import 'vendor/screens/splash_screen.dart' as vendor_splash;
import 'vendor/screens/main/main_app_screen.dart' as vendor_main;
import 'vendor/utils/time_utils.dart';

// ── User imports ──────────────────────────────────────────────────────────────
import 'user/theme/app_theme.dart' as user_theme;
import 'user/providers/auth_provider.dart' as user_auth;
import 'user/providers/time_provider.dart';
import 'user/core/config/app_initialization_service.dart';
import 'user/screens/auth/login_screen.dart' as user_login;
import 'user/screens/auth/signup_screen.dart' as user_signup;
import 'user/screens/splash_screen.dart' as user_splash;
import 'user/screens/main_screen.dart' as user_main;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initializeAppMode(String mode) async {
  if (mode == AppMode.captain.name) {
    try {
      await FirebaseConfigService.getBaseUrlWithFallback();
    } catch (_) {}
    try {
      await captain_notif.NotificationService().initialize();
    } catch (_) {}
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  } else if (mode == AppMode.vendor.name) {
    TimeUtils.initialize();
    final apiService = ApiService();
    apiService.initialize();
    try {
      await BaseUrlService.initializeBaseUrl().timeout(
        const Duration(seconds: 10),
      );
      if (BaseUrlService.isInitialized) {
        apiService.updateBaseUrl(BaseUrlService.baseUrl);
      }
    } catch (_) {}
    try {
      await vendor_notif.NotificationService().initialize().timeout(
        const Duration(seconds: 10),
      );
    } catch (_) {}
  } else if (mode == AppMode.user.name) {
    await AppInitializationService.initializeApp();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  final prefs = await SharedPreferences.getInstance();
  final savedMode = prefs.getString('selected_app_mode');

  // If savedMode is null, we can do some default initialization (like Captain background handler)
  if (savedMode == null) {
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  } else {
    await initializeAppMode(savedMode);
  }

  runApp(ProviderScope(child: RootApp(initialMode: savedMode)));
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOT ROUTER
// ─────────────────────────────────────────────────────────────────────────────
class RootApp extends StatefulWidget {
  final String? initialMode;
  const RootApp({required this.initialMode});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  String? _initializedMode;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializedMode = widget.initialMode;
    appModeNotifier.value = widget.initialMode;
    appModeNotifier.addListener(_onModeChanged);
  }

  @override
  void dispose() {
    appModeNotifier.removeListener(_onModeChanged);
    super.dispose();
  }

  Future<void> _onModeChanged() async {
    final newMode = appModeNotifier.value;
    if (newMode == _initializedMode) {
      if (mounted) setState(() {});
      return;
    }

    if (newMode == null) {
      if (mounted) {
        setState(() {
          _initializedMode = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isInitializing = true;
      });
    }

    await initializeAppMode(newMode);

    if (mounted) {
      setState(() {
        _initializedMode = newMode;
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final mode = appModeNotifier.value;
    if (mode == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const ModeSelectorScreen(),
      );
    }
    switch (AppMode.values.byName(mode)) {
      case AppMode.captain:
        return _CaptainApp();
      case AppMode.vendor:
        return _VendorApp();
      case AppMode.user:
        return _UserApp();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAPTAIN APP
// ─────────────────────────────────────────────────────────────────────────────
class _CaptainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تعالالي _T3alaly',
      theme: captain_theme.AppTheme.light,
      home: const _CaptainAuthWrapper(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
  }
}

class _CaptainAuthWrapper extends ConsumerStatefulWidget {
  const _CaptainAuthWrapper();

  @override
  ConsumerState<_CaptainAuthWrapper> createState() =>
      _CaptainAuthWrapperState();
}

class _CaptainAuthWrapperState extends ConsumerState<_CaptainAuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVersion());
  }

  Future<void> _checkVersion() async {
    final v = await FirebaseConfigService.checkForceUpdate();
    if (v != null && mounted) _showUpdateDialog(v);
  }

  void _showUpdateDialog(String v) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('تحديث مطلوب', textAlign: TextAlign.center),
          content: Text(
            'يتطلب التطبيق تحديثاً إلى الإصدار $v أو أحدث.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(onPressed: () {}, child: const Text('تحديث الآن')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(captain_auth.authStateProvider);
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authState.isLocked) return const CaptainLockedScreen();
    return authState.isAuthenticated
        ? const MainNavigation()
        : const captain_login.LoginScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VENDOR APP
// ─────────────────────────────────────────────────────────────────────────────
class _VendorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => vendor_auth.AuthProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'تعالالي _T3alaly',
        debugShowCheckedModeBanner: false,
        theme: vendor_theme.AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const vendor_splash.SplashScreen(),
          '/login': (context) => const vendor_login.LoginScreen(),
          '/signup': (context) => const vendor_signup.SignupScreen(),
          '/main': (context) => const vendor_main.MainAppScreen(),
          '/dashboard': (context) => const vendor_main.MainAppScreen(),
        },
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USER APP
// ─────────────────────────────────────────────────────────────────────────────
class _UserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => user_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => TimeProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'تعالالي _T3alaly',
        debugShowCheckedModeBanner: false,
        theme: user_theme.AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => const user_splash.SplashScreen(),
          '/login': (context) => const user_login.LoginScreen(),
          '/signup': (context) => const user_signup.SignupScreen(),
          '/main': (context) => const user_main.MainScreen(),
          '/dashboard': (context) => const user_main.MainScreen(),
        },
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    );
  }
}
