import 'package:json_annotation/json_annotation.dart';

part 'captain_stats.g.dart';

@JsonSerializable()
class CaptainStats {
  final int totalOrders;
  final double totalEarnings;

  CaptainStats({required this.totalOrders, required this.totalEarnings});

  factory CaptainStats.fromJson(Map<String, dynamic> json) =>
      _$CaptainStatsFromJson(json);
  Map<String, dynamic> toJson() => _$CaptainStatsToJson(this);
}
