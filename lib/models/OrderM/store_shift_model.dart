class StoreShiftModel {
  final int shiftId;
  final int storeId;
  final int dayOfWeek; // 1 = Mon, 7 = Sun
  final String openTime;
  final String closeTime;
  final bool is24Hours;

  StoreShiftModel({
    required this.shiftId,
    required this.storeId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.is24Hours,
  });

  factory StoreShiftModel.fromJson(Map<String, dynamic> json) {
    return StoreShiftModel(
      shiftId: json['shiftId'] as int? ?? 0,
      storeId: json['storeId'] as int? ?? 0,
      dayOfWeek: json['dayOfWeek'] as int? ?? 0,
      openTime: json['openTime'] as String? ?? "00:00:00",
      closeTime: json['closeTime'] as String? ?? "00:00:00",
      is24Hours: json['is24Hours'] as bool? ?? false,
    );
  }
}