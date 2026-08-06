import 'package:json_annotation/json_annotation.dart';

part 'captain_model.g.dart';

@JsonSerializable()
class CaptainModel {
  final String id;
  final String userName;
  final String email;
  final double? longitude;
  final double? latitude;
  final String phoneNumber;
  final String? workingHoursStart;
  final String? workingHoursEnd;
  final bool? isAvailable;
  final bool? isLocked;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? lastActivated;
  final double? ratingSum;
  final int? ratingCount;
  @JsonKey(fromJson: _dateTimeFromJsonRequired, toJson: _dateTimeToJsonRequired)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJsonRequired, toJson: _dateTimeToJsonRequired)
  final DateTime updatedAt;
  final String? photo;
  final String? photoUrl;
  final String? nationalId;
  final int? maxCurrentOrders;
  final int? currentNumberOfOrders;
  final double? earningSinceLastActivation;
  final double? maxEarningsSinceLastActivation;

  CaptainModel({
    required this.id,
    required this.userName,
    required this.email,
    this.longitude,
    this.latitude,
    required this.phoneNumber,
    this.workingHoursStart,
    this.workingHoursEnd,
    this.isAvailable,
    this.isLocked,
    this.lastActivated,
    this.ratingSum,
    this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
    this.photo,
    this.photoUrl,
    this.nationalId,
    this.maxCurrentOrders,
    this.currentNumberOfOrders,
    this.earningSinceLastActivation,
    this.maxEarningsSinceLastActivation,
  });

  double get averageRating {
    if ((ratingCount ?? 0) > 0 && ratingSum != null) {
      return ratingSum! / ratingCount!;
    }
    return 0.0;
  }

  factory CaptainModel.fromJson(Map<String, dynamic> json) =>
      _$CaptainModelFromJson(json);

  Map<String, dynamic> toJson() => _$CaptainModelToJson(this);

  CaptainModel copyWith({
    String? id,
    String? userName,
    String? email,
    double? longitude,
    double? latitude,
    String? phoneNumber,
    String? workingHoursStart,
    String? workingHoursEnd,
    bool? isAvailable,
    bool? isLocked,
    DateTime? lastActivated,
    double? ratingSum,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photo,
    String? photoUrl,
    String? nationalId,
    int? maxCurrentOrders,
    int? currentNumberOfOrders,
    double? earningSinceLastActivation,
    double? maxEarningsSinceLastActivation,
  }) {
    return CaptainModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      isAvailable: isAvailable ?? this.isAvailable,
      isLocked: isLocked ?? this.isLocked,
      lastActivated: lastActivated ?? this.lastActivated,
      ratingSum: ratingSum ?? this.ratingSum,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photo: photo ?? this.photo,
      photoUrl: photoUrl ?? this.photoUrl,
      nationalId: nationalId ?? this.nationalId,
      maxCurrentOrders: maxCurrentOrders ?? this.maxCurrentOrders,
      currentNumberOfOrders: currentNumberOfOrders ?? this.currentNumberOfOrders,
      earningSinceLastActivation: earningSinceLastActivation ?? this.earningSinceLastActivation,
      maxEarningsSinceLastActivation: maxEarningsSinceLastActivation ?? this.maxEarningsSinceLastActivation,
    );
  }

  static DateTime? _dateTimeFromJson(String? json) {
    return json != null ? DateTime.parse(json) : null;
  }

  static String? _dateTimeToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  static DateTime _dateTimeFromJsonRequired(String json) {
    return DateTime.parse(json);
  }

  static String _dateTimeToJsonRequired(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
