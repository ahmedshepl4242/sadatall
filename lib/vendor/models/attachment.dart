enum AttachmentType { image, voice }

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
          ? AttachmentType.image
          : AttachmentType.voice,
      link: json['link']?.toString() ?? '',
      linkUrl: json['linkUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type == AttachmentType.image ? 'IMAGE' : 'VOICE',
      'link': link,
      if (linkUrl != null) 'linkUrl': linkUrl,
    };
  }

  @override
  String toString() {
    return 'Attachment(type: $type, link: $link, linkUrl: $linkUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attachment && other.type == type && other.link == link;
  }

  @override
  int get hashCode => type.hashCode ^ link.hashCode;
}
