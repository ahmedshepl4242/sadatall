import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ConfigService {
  static const String _configCollection = 'delivery_app_config';
  static const String _baseUrlDoc = 'base_url';

  static const String _versionFieldName = 'version_user';

  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

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
    const retries = 3;
    const retryDelay = Duration(seconds: 2);
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection(_configCollection)
            .doc(_baseUrlDoc)
            .get();
        if (!docSnapshot.exists) return null;
        final requiredVersion =
            docSnapshot.data()?[_versionFieldName] as String?;
        if (requiredVersion == null || requiredVersion.isEmpty) return null;
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        if (_isUpdateRequired(currentVersion, requiredVersion)) {
          return requiredVersion;
        }
        return null;
      } catch (_) {
        if (attempt < retries - 1) {
          await Future.delayed(retryDelay * (attempt + 1));
        }
      }
    }
    return null;
  }

  /// Fetches the base URL from Firestore
  Future<String?> fetchBaseUrl() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(_configCollection)
          .doc(_baseUrlDoc)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return data['value'] as String?;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching base URL from Firestore: $e');
      }
      rethrow;
    }
    return null;
  }

  /// Fetches a specific configuration value by key
  Future<String?> fetchConfigValue(String key) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(_configCollection)
          .doc(key)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return data['value'] as String?;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching config value for key $key from Firestore: $e');
      }
      // Don't rethrow here since this is a utility method that might be used in various contexts
    }
    return null;
  }
}
