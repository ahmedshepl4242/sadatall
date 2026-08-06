import 'vendor.dart';

class AuthResult {
  final bool success;
  final Vendor? vendor;
  final String? message;
  final String? error;

  AuthResult({
    required this.success,
    this.vendor,
    this.message,
    this.error,
  });

  @override
  String toString() {
    return 'AuthResult{success: $success, message: $message, error: $error}';
  }
}

class LoginRequest {
  final String contactNumber;
  final String password;

  LoginRequest({
    required this.contactNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'contactNumber': contactNumber,
      'password': password,
    };
  }
}

class SignupRequest {
  final String vendorName;
  final String contactNumber;
  final String password;
  final String address;
  final String description;
  final double latitude;
  final double longitude;
  final int neighborhoodId;
  final String? imagePath;

  SignupRequest({
    required this.vendorName,
    required this.contactNumber,
    required this.password,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.neighborhoodId,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorName': vendorName,
      'contactNumber': contactNumber,
      'password': password,
      'address': address,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'neighborhoodId': neighborhoodId,
    };
  }
}

class Neighborhood {
  final int id;
  final String name;
  final String nameAr;

  Neighborhood({
    required this.id,
    required this.name,
    required this.nameAr,
  });

  factory Neighborhood.fromJson(Map<String, dynamic> json) {
    return Neighborhood(
      id: json['id'],
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
    };
  }

  @override
  String toString() {
    return nameAr.isNotEmpty ? nameAr : name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Neighborhood &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}