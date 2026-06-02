// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captain_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptainStats _$CaptainStatsFromJson(Map<String, dynamic> json) => CaptainStats(
  totalOrders: (json['totalOrders'] as num).toInt(),
  totalEarnings: (json['totalEarnings'] as num).toDouble(),
);

Map<String, dynamic> _$CaptainStatsToJson(CaptainStats instance) =>
    <String, dynamic>{
      'totalOrders': instance.totalOrders,
      'totalEarnings': instance.totalEarnings,
    };
