import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Default fallback URL in case Firestore request fails
  static const String _defaultBaseUrl =
      'https://delivery-sadatcity.duckdns.org/api';

  // Firebase configuration for fetching base URL
  static const Map<String, String> firebaseConfig = {
    'apiKey': "AIzaSyAmMuMfOZzFJYZ2FpNIGN3f3C2Pug5cBHc",
    'authDomain': "buss-3c283.firebaseapp.com",
    'projectId': "buss-3c283",
    'storageBucket': "buss-3c283.firebasestorage.app",
    'messagingSenderId': "793738063888",
    'appId': "1:793738063888:web:a371b6c0aff3ca6e135a95",
    'measurementId': "G-G5XZ20LLGH"
  };

  // Collection and document details
  static const String _collectionName = 'delivery_app_config';
  static const String _documentName = 'base_url';
  static const String _fieldName = 'value';
  static const String _versionFieldName = 'version_vendor';

  static String? _cachedBaseUrl;
  static bool _initialized = false;

  /// Returns true if [required] version is strictly greater than [current].
  static bool _isUpdateRequired(String current, String required) {
    final currentParts = current.trim().split('.').map(int.tryParse).toList();
    final requiredParts = required.trim().split('.').map(int.tryParse).toList();
    while (currentParts.length < 3) currentParts.add(0);
    while (requiredParts.length < 3) requiredParts.add(0);
    for (int i = 0; i < 3; i++) {
      final c = currentParts[i] ?? 0;
      final r = requiredParts[i] ?? 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }

  /// Returns required version string if force update needed, null otherwise.
  static Future<String?> checkForceUpdate() async {
    try {
      await _initializeFirebaseApp();
      final docSnapshot = await getFirestoreInstance()
          .collection(_collectionName)
          .doc(_documentName)
          .get()
          .timeout(const Duration(seconds: 8), onTimeout: () => throw Exception('timeout'));
      if (!docSnapshot.exists) return null;
      final requiredVersion =
          docSnapshot.data()?[_versionFieldName] as String?;
      if (requiredVersion == null || requiredVersion.isEmpty) return null;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      if (kDebugMode) {
        print(
            'Force update check — current: $currentVersion, required: $requiredVersion');
      }
      if (_isUpdateRequired(currentVersion, requiredVersion)) {
        return requiredVersion;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Force update check failed (non-blocking): $e');
      }
    }
    return null;
  }

  // Fetch base URL from Firestore
  static Future<String?> fetchBaseUrl() async {
    // return "http://DELL-AYMAN:3004/api"; for testing only
    try {
      // Initialize Firebase with the specific config (without interfering with main Firebase app)
      await _initializeFirebaseApp();

      print('Fetching IP/URL from Firebase Firestore...');

      // Fetch from Firestore
      final docSnapshot = await getFirestoreInstance()
          .collection(_collectionName)
          .doc(_documentName)
          .get()
          .timeout(const Duration(seconds: 8), onTimeout: () => throw Exception('timeout'));

      if (docSnapshot.exists) {
        final docData = docSnapshot.data();
        if (docData != null) {
          final baseUrl = docData[_fieldName] as String?;

          if (baseUrl != null && baseUrl.isNotEmpty) {
            print('Successfully fetched IP/URL from Firebase: $baseUrl');
            // Cache and save to local storage
            _cachedBaseUrl = baseUrl;
            await _saveBaseUrlToLocal(baseUrl);
            return baseUrl;
          }
        }
      }

      // If Firestore fetch fails, return cached value or default
      print(
          'Firebase fetch failed or returned empty result. Using cached/default URL.');
      return await _getCachedBaseUrl();
    } catch (e) {
      print('Error fetching IP/URL from Firebase: $e');
      return await _getCachedBaseUrl();
    }
  }

  // Initialize Firebase app with specific name to avoid conflicts
  static Future<void> _initializeFirebaseApp() async {
    if (!_initialized) {
      try {
        // Initialize Firebase app with custom name to avoid conflict with existing app
        await Firebase.initializeApp(
          name: 'api_fetcher',
          options: const FirebaseOptions(
              apiKey: "AIzaSyAmMuMfOZzFJYZ2FpNIGN3f3C2Pug5cBHc",
              authDomain: "buss-3c283.firebaseapp.com",
              projectId: "buss-3c283",
              storageBucket: "buss-3c283.firebasestorage.app",
              messagingSenderId: "793738063888",
              appId: "1:793738063888:web:a371b6c0aff3ca6e135a95",
              measurementId: "G-G5XZ20LLGH"),
        );
        _initialized = true;
      } catch (e) {
        // App might already be initialized, which is fine

        _initialized = true;
      }
    }
  }

  // Get Firestore instance for the specific app
  static FirebaseFirestore getFirestoreInstance() {
    return _initialized
        ? FirebaseFirestore.instanceFor(
            app: Firebase.apps.firstWhere((app) => app.name == 'api_fetcher'))
        : FirebaseFirestore.instance;
  }

  // Save base URL to local storage
  static Future<void> _saveBaseUrlToLocal(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', baseUrl);
  }

  // Get cached base URL from local storage
  static Future<String?> _getCachedBaseUrl() async {
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl;
    }

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('base_url');

    if (cached != null && cached.isNotEmpty) {
      _cachedBaseUrl = cached;
    } else {
      _cachedBaseUrl = _defaultBaseUrl;
    }

    return _cachedBaseUrl;
  }

  // Clear cached base URL
  static Future<void> clearCachedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('base_url');
    _cachedBaseUrl = null;
  }
}
