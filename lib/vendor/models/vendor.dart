import 'package:timezone/timezone.dart' as tz;
import '../utils/time_utils.dart';
import 'category.dart';

class Vendor {
	final String id;
	final String vendorName;
	final String contactNumber;
	final String address;
	final String description;
	final double latitude;
	final double longitude;
	final String neighborhoodId;
	final String? imageUrl;
	final String isOpen;
	final bool? isLocked;
	final List<Category>? categories;
	final tz.TZDateTime createdAt;
	final tz.TZDateTime updatedAt;

	Vendor({
		required this.id,
		required this.vendorName,
		required this.contactNumber,
		required this.address,
		required this.description,
		required this.latitude,
		required this.longitude,
		required this.neighborhoodId,
		this.imageUrl,
		required this.isOpen,
		this.isLocked,
		this.categories,
		required this.createdAt,
		required this.updatedAt,
	});

	factory Vendor.fromJson(Map<String, dynamic> json) {
		List<Category>? categories;
		if (json['categories'] != null && json['categories'] is List) {
			categories = (json['categories'] as List)
					.map((cat) => Category.fromJson(cat as Map<String, dynamic>))
					.toList();
		}

		return Vendor(
			id: (json['id'] is num ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0).toString(),
			vendorName: json['vendorName']?.toString() ?? '',
			contactNumber: json['contactNumber']?.toString() ?? '',
			address: json['address']?.toString() ?? '',
			description: json['description']?.toString() ?? '',
			latitude: json['latitude'] is num
					? (json['latitude'] as num).toDouble()
					: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
			longitude: json['longitude'] is num
					? (json['longitude'] as num).toDouble()
					: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
			neighborhoodId: (json['neighborhoodId'] is num ? json['neighborhoodId'] : int.tryParse(json['neighborhoodId']?.toString() ?? '0') ?? 0).toString(),
			imageUrl: json['imageUrl']?.toString(),
			isOpen: json['isOpen'] == null
					? ''
					: json['isOpen'] is bool
							? (json['isOpen'] as bool).toString()
							: json['isOpen'].toString(),
			categories: categories,
			createdAt: json['createdAt'] != null
					? TimeUtils.toCairoTime(DateTime.parse(json['createdAt'].toString()))
					: TimeUtils.currentTimeInCairo,
			updatedAt: json['updatedAt'] != null
					? TimeUtils.toCairoTime(DateTime.parse(json['updatedAt'].toString()))
					: TimeUtils.currentTimeInCairo,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'vendorName': vendorName,
			'contactNumber': contactNumber,
			'address': address,
			'description': description,
			'latitude': latitude,
			'longitude': longitude,
			'neighborhoodId': neighborhoodId,
			'imageUrl': imageUrl,
			'isOpen': isOpen,
			'isLocked': isLocked,
			'categories': categories?.map((cat) => cat.toJson()).toList(),
			'createdAt': createdAt.toUtc().toIso8601String(),
			'updatedAt': updatedAt.toUtc().toIso8601String(),
		};
	}

	Vendor copyWith({
		String? id,
		String? vendorName,
		String? contactNumber,
		String? address,
		String? description,
		double? latitude,
		double? longitude,
		String? neighborhoodId,
		String? imageUrl,
		String? isOpen,
		bool? isLocked,
		List<Category>? categories,
		tz.TZDateTime? createdAt,
		tz.TZDateTime? updatedAt,
	}) {
		return Vendor(
			id: id ?? this.id,
			vendorName: vendorName ?? this.vendorName,
			contactNumber: contactNumber ?? this.contactNumber,
			address: address ?? this.address,
			description: description ?? this.description,
			latitude: latitude ?? this.latitude,
			longitude: longitude ?? this.longitude,
			neighborhoodId: neighborhoodId ?? this.neighborhoodId,
			imageUrl: imageUrl ?? this.imageUrl,
			isOpen: isOpen ?? this.isOpen,
			isLocked: isLocked ?? this.isLocked,
			categories: categories ?? this.categories,
			createdAt: createdAt ?? this.createdAt,
			updatedAt: updatedAt ?? this.updatedAt,
		);
	}

	@override
	String toString() {
		return 'Vendor{id: $id, vendorName: $vendorName, contactNumber: $contactNumber}';
	}

	@override
	bool operator ==(Object other) =>
			identical(this, other) ||
			other is Vendor && runtimeType == other.runtimeType && id == other.id;

	@override
	int get hashCode => id.hashCode;
}
