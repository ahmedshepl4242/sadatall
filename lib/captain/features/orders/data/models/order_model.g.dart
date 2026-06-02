// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  userId: json['userId'] as String?,
  captainId: json['captainId'] as String?,
  vendorId: json['vendorId'] as String?,
  neighborhoodId: json['neighborhoodId'] as String,
  status: OrderModel._orderStatusFromJson(json['status'] as String),
  description: json['description'] as String,
  additionalNotes: json['additionalNotes'] as String?,
  userAddress: json['userAddress'] as String,
  userLongitude: (json['userLongitude'] as num?)?.toDouble(),
  userLatitude: (json['userLatitude'] as num?)?.toDouble(),
  phoneNumber: json['phoneNumber'] as String,
  price: (json['price'] as num?)?.toDouble(),
  deliveryPrice: (json['deliveryPrice'] as num?)?.toDouble(),
  createdAt: OrderModel._dateTimeFromJsonRequired(json['createdAt'] as String),
  counterOfferSentAt: OrderModel._dateTimeFromJson(
    json['counterOfferSentAt'] as String?,
  ),
  acceptedByVend: OrderModel._dateTimeFromJson(
    json['acceptedByVend'] as String?,
  ),
  acceptedByCapta: OrderModel._dateTimeFromJson(
    json['acceptedByCapta'] as String?,
  ),
  deliveredAt: OrderModel._dateTimeFromJson(json['deliveredAt'] as String?),
  finalizedAt: OrderModel._dateTimeFromJson(json['finalizedAt'] as String?),
  user: json['user'] == null
      ? null
      : UserInfo.fromJson(json['user'] as Map<String, dynamic>),
  vendor: json['vendor'] == null
      ? null
      : VendorInfo.fromJson(json['vendor'] as Map<String, dynamic>),
  neighborhood: json['neighborhood'] == null
      ? null
      : NeighborhoodInfo.fromJson(json['neighborhood'] as Map<String, dynamic>),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderModelToJson(
  OrderModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'captainId': instance.captainId,
  'vendorId': instance.vendorId,
  'neighborhoodId': instance.neighborhoodId,
  'status': OrderModel._orderStatusToJson(instance.status),
  'description': instance.description,
  'additionalNotes': instance.additionalNotes,
  'userAddress': instance.userAddress,
  'userLongitude': instance.userLongitude,
  'userLatitude': instance.userLatitude,
  'phoneNumber': instance.phoneNumber,
  'price': instance.price,
  'deliveryPrice': instance.deliveryPrice,
  'createdAt': OrderModel._dateTimeToJsonRequired(instance.createdAt),
  'counterOfferSentAt': OrderModel._dateTimeToJson(instance.counterOfferSentAt),
  'acceptedByVend': OrderModel._dateTimeToJson(instance.acceptedByVend),
  'acceptedByCapta': OrderModel._dateTimeToJson(instance.acceptedByCapta),
  'deliveredAt': OrderModel._dateTimeToJson(instance.deliveredAt),
  'finalizedAt': OrderModel._dateTimeToJson(instance.finalizedAt),
  'user': instance.user,
  'vendor': instance.vendor,
  'neighborhood': instance.neighborhood,
  'attachments': instance.attachments,
};

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  id: json['id'] as String,
  userName: json['userName'] as String,
  email: json['email'] as String?,
  address: json['address'] as String?,
  phoneNumber: json['phoneNumber'] as String,
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'userName': instance.userName,
  'email': instance.email,
  'address': instance.address,
  'phoneNumber': instance.phoneNumber,
};

VendorInfo _$VendorInfoFromJson(Map<String, dynamic> json) => VendorInfo(
  id: json['id'] as String,
  vendorName: json['vendorName'] as String,
  contactNumber: json['contactNumber'] as String,
  address: json['address'] as String,
  longitude: (json['longitude'] as num?)?.toDouble(),
  latitude: (json['latitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$VendorInfoToJson(VendorInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendorName': instance.vendorName,
      'contactNumber': instance.contactNumber,
      'address': instance.address,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
    };

NeighborhoodInfo _$NeighborhoodInfoFromJson(Map<String, dynamic> json) =>
    NeighborhoodInfo(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$NeighborhoodInfoToJson(NeighborhoodInfo instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
