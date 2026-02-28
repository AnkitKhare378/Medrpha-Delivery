class LabPackageModel {
  final int packageId;
  final String packageName;
  final double packagePrice;
  final double discountPrice;
  final List<PackageDetail> details;

  LabPackageModel({
    required this.packageId,
    required this.packageName,
    required this.packagePrice,
    required this.discountPrice,
    required this.details,
  });

  factory LabPackageModel.fromJson(Map<String, dynamic> json) {
    return LabPackageModel(
      packageId: json['packageId'] ?? 0,
      packageName: json['packageName'] ?? "",
      packagePrice: (json['packagePrice'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num).toDouble(),
      details: (json['details'] as List)
          .map((i) => PackageDetail.fromJson(i))
          .toList(),
    );
  }
}

class PackageDetail {
  final int id;
  final int testId;
  final String testName;
  final double testPrice;

  PackageDetail({
    required this.id,
    required this.testId,
    required this.testName,
    required this.testPrice,
  });

  factory PackageDetail.fromJson(Map<String, dynamic> json) {
    return PackageDetail(
      id: json['id'] ?? 0,
      testId: json['testId'] ?? 0,
      testName: json['testName'] ?? "",
      testPrice: (json['testPrice'] as num).toDouble(),
    );
  }
}