class ProductItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageLink;
  final bool isAvailable;
  final String vendorId;
  final String? imageUrl;

  ProductItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageLink,
    required this.isAvailable,
    required this.vendorId,
    this.imageUrl,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageLink: json['imageLink']?.toString() ?? '',
      isAvailable: json['isAvailable'] == true ||
          json['isAvailable']?.toString().toLowerCase() == 'true',
      vendorId: json['vendorId']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageLink': imageLink,
      'isAvailable': isAvailable,
      'vendorId': vendorId,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'ProductItem{id: $id, name: $name, price: $price, isAvailable: $isAvailable}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
