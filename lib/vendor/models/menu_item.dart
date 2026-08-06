class MenuItem {
  final String id;
  final String vendorId;
  final String? photoUrl;

  MenuItem({
    required this.id,
    required this.vendorId,
    this.photoUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: (json['id'] is num
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? '0') ?? 0)
          .toString(),
      vendorId: (json['vendorId'] is num
              ? json['vendorId']
              : int.tryParse(json['vendorId']?.toString() ?? '0') ?? 0)
          .toString(),
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'photoUrl': photoUrl,
    };
  }

  MenuItem copyWith({
    String? id,
    String? vendorId,
    String? photoUrl,
  }) {
    return MenuItem(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  String toString() {
    return 'MenuItem{id: $id, vendorId: $vendorId, photoUrl: $photoUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

