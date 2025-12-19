// File: lib/models/LabM/lab_test_model.dart (UPDATED)

class LabTest {
  final int testID;
  final String testCode;
  final String testName;
  final int categoryID; // Added
  final int departmentID; // Added
  final int sampleTypeID; // Added
  final int methodID; // Added
  final double testPrice; // Changed from int to double
  final String? description;
  final bool isPopular;
  final bool isFasting;
  final String? testImage;
  final String? normalRange;

  // Added/Corrected fields
  final int? unitID;
  final int? reportFormatID;
  final int? symptomId;

  final TestSynonym? testSynonym;

  LabTest({
    required this.testID,
    required this.testCode,
    required this.testName,
    required this.categoryID,
    required this.departmentID,
    required this.sampleTypeID,
    required this.methodID,
    required this.testPrice,
    this.description,
    required this.isPopular,
    required this.isFasting,
    this.testImage,
    this.normalRange,
    this.unitID,
    this.reportFormatID,
    this.symptomId,
    this.testSynonym,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      testID: json['testID'] as int? ?? 0,
      testCode: json['testCode'] as String? ?? 'N/A',
      testName: json['testName'] as String? ?? 'N/A',

      // Added fields from JSON log
      categoryID: json['categoryID'] as int? ?? 0,
      departmentID: json['departmentID'] as int? ?? 0,
      sampleTypeID: json['sampleTypeID'] as int? ?? 0,
      methodID: json['methodID'] as int? ?? 0,
      unitID: json['unitID'] as int?,
      reportFormatID: json['reportFormatID'] as int?,
      symptomId: json['symptomId'] as int?,

      // Changed type to double and added null safety
      testPrice: (json['testPrice'] as num? ?? 0.0).toDouble(),

      description: json['description'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      isFasting: json['isfasting'] as bool? ?? false, // API uses 'isfasting' (lowercase)
      testImage: json['testImage'] as String?,
      normalRange: json['normalRange'] as String?,

      // Safe parsing for nested object
      testSynonym: json['testSynonym'] != null
          ? TestSynonym.fromJson(json['testSynonym'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TestSynonym {
  final int id;
  final String name;

  // Additional fields from the synonym object, made nullable
  final String? createdBy;
  final DateTime? createdDate;

  TestSynonym({
    required this.id,
    required this.name,
    this.createdBy,
    this.createdDate,
  });

  factory TestSynonym.fromJson(Map<String, dynamic> json) {
    // Helper function for safe DateTime parsing
    DateTime? safeParseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return TestSynonym(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',

      // Added new fields
      createdBy: json['created_by'] as String?,
      createdDate: safeParseDate(json['created_date']),
    );
  }
}