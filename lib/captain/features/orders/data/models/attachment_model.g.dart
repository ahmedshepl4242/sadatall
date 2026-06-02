// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachmentModel _$AttachmentModelFromJson(Map<String, dynamic> json) =>
    AttachmentModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String?,
      orderId: json['orderId'] as String,
      type: AttachmentModel._attachmentTypeFromJson(json['type'] as String),
      link: json['link'] as String,
      linkUrl: json['linkUrl'] as String?,
      createdAt: AttachmentModel._dateTimeFromJsonRequired(
        json['createdAt'] as String,
      ),
    );

Map<String, dynamic> _$AttachmentModelToJson(AttachmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'orderId': instance.orderId,
      'type': AttachmentModel._attachmentTypeToJson(instance.type),
      'link': instance.link,
      'linkUrl': instance.linkUrl,
      'createdAt': AttachmentModel._dateTimeToJsonRequired(instance.createdAt),
    };
