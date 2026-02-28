class StoreHolidayModel {
  final int holidayId;
  final int storeId;
  final String startDate;
  final String endDate;
  final String holidayName;
  final bool isFullDay;
  final bool isRecurring;
  final String? createdBy;

  StoreHolidayModel({
    required this.holidayId,
    required this.storeId,
    required this.startDate,
    required this.endDate,
    required this.holidayName,
    required this.isFullDay,
    required this.isRecurring,
    this.createdBy,
  });

  factory StoreHolidayModel.fromJson(Map<String, dynamic> json) {
    return StoreHolidayModel(
      holidayId: json['holidayId'] as int? ?? 0,
      storeId: json['storeId'] as int? ?? 0,
      // API returns 'startDate', not 'holidayDate'
      startDate: json['startDate'] as String? ?? "",
      endDate: json['endDate'] as String? ?? "",
      holidayName: json['holidayName']?.toString().trim() ?? "Holiday",
      isFullDay: json['isFullDay'] as bool? ?? true,
      isRecurring: json['isRecurring'] as bool? ?? false,
      createdBy: json['created_by'],
    );
  }

  // Helper to get DateTime object directly
  DateTime get startDateTime => DateTime.tryParse(startDate) ?? DateTime(2000);
  DateTime get endDateTime => DateTime.tryParse(endDate) ?? DateTime(2000);
}