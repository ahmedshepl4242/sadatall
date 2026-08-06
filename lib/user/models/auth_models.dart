import 'user.dart';

class AuthResult {
  final bool success;
  final User? user;
  final String? message;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.message,
    this.error,
  });

  @override
  String toString() {
    return 'AuthResult{success: $success, message: $message, error: $error}';
  }
}


class Neighborhood {
  final String id;
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

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class SignupRequest {
  final String userName;
  final String email;
  final String phoneNumber;
  final String password;
  final String address;
  final String neighborhoodId;

  SignupRequest({
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.address,
    required this.neighborhoodId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'address': address,
      'neighborhoodId': neighborhoodId,
    };
  }
}
