import "package:json_annotation/json_annotation.dart";

part "captain_request_model.g.dart";

@JsonSerializable()
class CaptainRequestModel {
  final String id;
  final String captainId;
  final String description;
  @JsonKey(fromJson: _requestStatusFromJson, toJson: _requestStatusToJson)
  final RequestStatus status;
  final String? reply;
  @JsonKey(fromJson: _dateTimeFromJsonRequired, toJson: _dateTimeToJsonRequired)
  final DateTime submittedAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? repliedAt;

  CaptainRequestModel({
    required this.id,
    required this.captainId,
    required this.description,
    required this.status,
    this.reply,
    required this.submittedAt,
    this.repliedAt,
  });

  factory CaptainRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CaptainRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$CaptainRequestModelToJson(this);

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

  static RequestStatus _requestStatusFromJson(String json) {
    return RequestStatus.fromString(json);
  }

  static String _requestStatusToJson(RequestStatus status) {
    return status.value;
  }
}

enum RequestStatus {
  pending("PENDING"),
  approved("APPROVED"),
  rejected("REJECTED");

  const RequestStatus(this.value);
  final String value;

  static RequestStatus fromString(String status) {
    return RequestStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => RequestStatus.pending,
    );
  }
}
