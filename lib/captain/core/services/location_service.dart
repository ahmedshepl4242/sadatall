import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../errors/app_exceptions.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled');
    }

    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw const LocationException('Location permissions are denied');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      throw LocationException('Failed to get current location: $e');
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  Future<bool> isWithinRange(
    double currentLat,
    double currentLng,
    double targetLat,
    double targetLng,
    double rangeInMeters,
  ) async {
    final distance = calculateDistance(currentLat, currentLng, targetLat, targetLng);
    return distance <= rangeInMeters;
  }
}