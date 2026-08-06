enum AttachmentType { IMAGE, VOICE }

class Attachment {
  final AttachmentType type;
  final String link;
  final String? localPath;
  final String? linkUrl; // Full signed URL for viewing

  Attachment({
    required this.type,
    required this.link,
    this.localPath,
    this.linkUrl,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      type: json['type']?.toString().toUpperCase() == 'IMAGE' 
          ? AttachmentType.IMAGE 
          : AttachmentType.VOICE,
      link: json['link']?.toString() ?? '',
      linkUrl: json['linkUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type == AttachmentType.IMAGE ? 'IMAGE' : 'VOICE',
      'link': link,
    };
  }

  @override
  String toString() {
    return 'Attachment(type: $type, link: $link)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attachment && other.type == type && other.link == link;
  }

  @override
  int get hashCode => type.hashCode ^ link.hashCode;
}
