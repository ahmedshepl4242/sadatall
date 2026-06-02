// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captain_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptainModel _$CaptainModelFromJson(Map<String, dynamic> json) => CaptainModel(
  id: json['id'] as String,
  userName: json['userName'] as String,
  email: json['email'] as String,
  longitude: (json['longitude'] as num?)?.toDouble(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  phoneNumber: json['phoneNumber'] as String,
  workingHoursStart: json['workingHoursStart'] as String?,
  workingHoursEnd: json['workingHoursEnd'] as String?,
  isAvailable: json['isAvailable'] as bool?,
  isLocked: json['isLocked'] as bool?,
  lastActivated: CaptainModel._dateTimeFromJson(
    json['lastActivated'] as String?,
  ),
  ratingSum: (json['ratingSum'] as num?)?.toDouble(),
  ratingCount: (json['ratingCount'] as num?)?.toInt(),
  createdAt: CaptainModel._dateTimeFromJsonRequired(
    json['createdAt'] as String,
  ),
  updatedAt: CaptainModel._dateTimeFromJsonRequired(
    json['updatedAt'] as String,
  ),
  photo: json['photo'] as String?,
  photoUrl: json['photoUrl'] as String?,
  nationalId: json['nationalId'] as String?,
  maxCurrentOrders: (json['maxCurrentOrders'] as num?)?.toInt(),
  currentNumberOfOrders: (json['currentNumberOfOrders'] as num?)?.toInt(),
  earningSinceLastActivation: (json['earningSinceLastActivation'] as num?)
      ?.toDouble(),
  maxEarningsSinceLastActivation:
      (json['maxEarningsSinceLastActivation'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CaptainModelToJson(CaptainModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'email': instance.email,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'phoneNumber': instance.phoneNumber,
      'workingHoursStart': instance.workingHoursStart,
      'workingHoursEnd': instance.workingHoursEnd,
      'isAvailable': instance.isAvailable,
      'isLocked': instance.isLocked,
      'lastActivated': CaptainModel._dateTimeToJson(instance.lastActivated),
      'ratingSum': instance.ratingSum,
      'ratingCount': instance.ratingCount,
      'createdAt': CaptainModel._dateTimeToJsonRequired(instance.createdAt),
      'updatedAt': CaptainModel._dateTimeToJsonRequired(instance.updatedAt),
      'photo': instance.photo,
      'photoUrl': instance.photoUrl,
      'nationalId': instance.nationalId,
      'maxCurrentOrders': instance.maxCurrentOrders,
      'currentNumberOfOrders': instance.currentNumberOfOrders,
      'earningSinceLastActivation': instance.earningSinceLastActivation,
      'maxEarningsSinceLastActivation': instance.maxEarningsSinceLastActivation,
    };
