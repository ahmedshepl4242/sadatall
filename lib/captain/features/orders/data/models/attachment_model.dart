import 'package:json_annotation/json_annotation.dart';

part 'attachment_model.g.dart';

enum AttachmentType {
  @JsonValue('IMAGE')
  image,
  @JsonValue('VOICE')
  voice;

  static AttachmentType fromString(String type) {
    switch (type) {
      case 'IMAGE':
        return AttachmentType.image;
      case 'VOICE':
        return AttachmentType.voice;
      default:
        return AttachmentType.image;
    }
  }
}

@JsonSerializable()
class AttachmentModel {
  final String id;
  final String? tenantId;
  final String orderId;
  @JsonKey(fromJson: _attachmentTypeFromJson, toJson: _attachmentTypeToJson)
  final AttachmentType type;
  final String link;
  final String? linkUrl;
  @JsonKey(fromJson: _dateTimeFromJsonRequired, toJson: _dateTimeToJsonRequired)
  final DateTime createdAt;

  AttachmentModel({
    required this.id,
    this.tenantId,
    required this.orderId,
    required this.type,
    required this.link,
    this.linkUrl,
    required this.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentModelToJson(this);

  static AttachmentType _attachmentTypeFromJson(String json) {
    return AttachmentType.fromString(json);
  }

  static String _attachmentTypeToJson(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return 'IMAGE';
      case AttachmentType.voice:
        return 'VOICE';
    }
  }

  static DateTime _dateTimeFromJsonRequired(String json) {
    return DateTime.parse(json);
  }

  static String _dateTimeToJsonRequired(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
