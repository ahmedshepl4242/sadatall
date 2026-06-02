// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captain_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptainRequestModel _$CaptainRequestModelFromJson(Map<String, dynamic> json) =>
    CaptainRequestModel(
      id: json['id'] as String,
      captainId: json['captainId'] as String,
      description: json['description'] as String,
      status: CaptainRequestModel._requestStatusFromJson(
        json['status'] as String,
      ),
      reply: json['reply'] as String?,
      submittedAt: CaptainRequestModel._dateTimeFromJsonRequired(
        json['submittedAt'] as String,
      ),
      repliedAt: CaptainRequestModel._dateTimeFromJson(
        json['repliedAt'] as String?,
      ),
    );

Map<String, dynamic> _$CaptainRequestModelToJson(
  CaptainRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'captainId': instance.captainId,
  'description': instance.description,
  'status': CaptainRequestModel._requestStatusToJson(instance.status),
  'reply': instance.reply,
  'submittedAt': CaptainRequestModel._dateTimeToJsonRequired(
    instance.submittedAt,
  ),
  'repliedAt': CaptainRequestModel._dateTimeToJson(instance.repliedAt),
};
