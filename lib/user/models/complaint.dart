class Complaint {
  final String id;
  final String description;
  final String type;
  final String userId;
  final DateTime submittedAt;
  final String? reply;
  final DateTime? repliedAt;

  Complaint({
    required this.id,
    required this.description,
    required this.type,
    required this.userId,
    required this.submittedAt,
    this.reply,
    this.repliedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      userId: json['userId'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      reply: json['reply'] as String?,
      repliedAt: json['repliedAt'] != null
          ? DateTime.parse(json['repliedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type,
      'userId': userId,
      'submittedAt': submittedAt.toIso8601String(),
      'reply': reply,
      'repliedAt': repliedAt?.toIso8601String(),
    };
  }
}