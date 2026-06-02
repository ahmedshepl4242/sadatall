import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:sadat_delivery_merged/user/services/storage_service.dart';

// Define a callback type for when the base URL changes
typedef OnBaseUrlChanged = void Function(String newBaseUrl);

class ApiConfigManager {
  static const String _baseUrlKey = 'base_url';
  static const String _fallbackBaseUrl =
      'https://delivery-sadatcity.duckdns.org/api'; // Fallback URL

  final StorageService _storageService = StorageService();
  String? _currentBaseUrl;
  OnBaseUrlChanged? _onBaseUrlChanged;

  // Configuration for the separate Firebase project that holds the base URL
  static const String _apiKey =
      'AIzaSyAmMuMfOZzFJYZ2FpNIGN3f3C2Pug5cBHc'; // Your API key
  static const String _projectId = 'buss-3c283'; // Your project ID
  static const String _documentPath =
      'delivery_app_config/base_url'; // Document path

  // Register a callback to be notified when the base URL changes
  void registerBaseUrlChangedCallback(OnBaseUrlChanged callback) {
    _onBaseUrlChanged = callback;
  }

  /// Initializes the API configuration by fetching the base URL from Firestore,
  /// then falls back to cached URL if Firestore fetch fails, or uses fallback value
  Future<void> initialize() async {
    String? newBaseUrl;

    try {
      // Always fetch from Firestore first (highest priority)
      final fetchedBaseUrl = await _fetchBaseUrlFromFirestore();

      if (fetchedBaseUrl != null && fetchedBaseUrl.isNotEmpty) {
        newBaseUrl = fetchedBaseUrl;
        // Cache the URL for future use
        await _storageService.saveString(_baseUrlKey, fetchedBaseUrl);
      } else {
        // If Firestore fetch fails or returns empty, try to get from local storage
        // but don't cache empty values from Firestore
        final cachedBaseUrl = await _getCachedBaseUrl();
        if (cachedBaseUrl != null && cachedBaseUrl.isNotEmpty) {
          newBaseUrl = cachedBaseUrl;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during base URL initialization: $e');
      }
      // If there's an exception, try to use cached value
      final cachedBaseUrl = await _getCachedBaseUrl();
      if (cachedBaseUrl != null && cachedBaseUrl.isNotEmpty) {
        newBaseUrl = cachedBaseUrl;
      }
    }

    // If we still don't have a URL, use the fallback
    newBaseUrl = newBaseUrl ?? _fallbackBaseUrl;

    // Check if the base URL is actually changing
    final shouldNotify =
        _currentBaseUrl != null && _currentBaseUrl != newBaseUrl;

    // Update the current base URL
    _currentBaseUrl = newBaseUrl;

    // If the base URL has changed from a previous value, notify the callback
    if (shouldNotify && _onBaseUrlChanged != null) {
      _onBaseUrlChanged!(newBaseUrl);
    }
  }

  /// Fetches the base URL from a different Firestore project using the REST API
  Future<String?> _fetchBaseUrlFromFirestore() async {
    try {
      // return "http://DELL-AYMAN:3004/api"; // Hardcoded for testing
      // Using Firebase REST API to access a document from a different project
      // Format: https://firestore.googleapis.com/v1/projects/{project-id}/databases/(default)/documents/{document-path}
      final url =
          'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$_documentPath?key=$_apiKey';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // The response format from Firestore REST API includes a 'fields' object
        // where each field has a type and value structure
        final fields = data['fields'] as Map<String, dynamic>?;
        if (fields != null) {
          final valueField = fields['value'];
          if (valueField != null) {
            // Extract the actual value based on its type
            if (valueField.containsKey('stringValue')) {
              final value = valueField['stringValue'] as String?;
              // Ensure the returned value is not empty
              if (value != null && value.isNotEmpty) {
                return value;
              }
            } else if (valueField.containsKey('integerValue')) {
              final value = valueField['integerValue'].toString();
              if (value.isNotEmpty) {
                return value;
              }
            } else if (valueField.containsKey('doubleValue')) {
              final value = valueField['doubleValue'].toString();
              if (value.isNotEmpty) {
                return value;
              }
            }
          }
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('Base URL document not found in Firestore: $_documentPath');
        }
      } else {
        if (kDebugMode) {
          print(
              'Error fetching base URL from Firestore: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching base URL from Firestore: $e');
      }
      // This might be a network error, return null to try cached value
      return null;
    }
    return null;
  }

  /// Gets the cached base URL from local storage
  Future<String?> _getCachedBaseUrl() async {
    try {
      final cachedUrl = await _storageService.getString(_baseUrlKey);
      return cachedUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached base URL: $e');
      }
      return null;
    }
  }

  /// Gets the current base URL
  String getBaseUrl() {
    return _currentBaseUrl ?? _fallbackBaseUrl;
  }

  /// Gets the base URL directly from storage (async)
  Future<String> getBaseUrlAsync() async {
    try {
      // First try to get directly from local storage
      final localBaseUrl = await _storageService.getString(_baseUrlKey);
      if (localBaseUrl != null && localBaseUrl.isNotEmpty) {
        // Update our internal cache with the value from storage
        _currentBaseUrl = localBaseUrl;
        return localBaseUrl;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting base URL from storage: $e');
      }
    }

    // If not in local storage, return our cached value or fallback
    return _currentBaseUrl ?? _fallbackBaseUrl;
  }

  /// Updates the base URL and caches it
  Future<void> updateBaseUrl(String newBaseUrl) async {
    _currentBaseUrl = newBaseUrl;
    await _storageService.saveString(_baseUrlKey, newBaseUrl);

    // Notify the callback that the base URL has changed
    if (_onBaseUrlChanged != null) {
      _onBaseUrlChanged!(newBaseUrl);
    }
  }

  /// Reloads the base URL from storage (useful when the base URL may have been updated externally)
  Future<void> reloadBaseUrlFromStorage() async {
    final localBaseUrl = await _storageService.getString(_baseUrlKey);
    if (localBaseUrl != null &&
        localBaseUrl.isNotEmpty &&
        localBaseUrl != _currentBaseUrl) {
      _currentBaseUrl = localBaseUrl;
      // Don't notify callback here since this is just reloading from storage
      // and not a change from within the app
    }
  }

  /// Reloads the base URL from Firestore (useful for manual refresh)
  Future<void> reloadBaseUrl() async {
    final baseUrl = await _fetchBaseUrlFromFirestore();

    if (baseUrl != null && baseUrl.isNotEmpty) {
      await updateBaseUrl(baseUrl);
    }
  }
}
