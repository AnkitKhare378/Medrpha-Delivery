

import '../../../core/network/api_call.dart';
import '../../../models/LabM/lab_test_model.dart';

class LabTestService {
  static const String _baseUrl = "https://www.online-tech.in/api/Lab/";
  static const String _testSearchEndpoint = "${_baseUrl}TestSearch";

  // Base image URL, adjust this if the API returns relative paths
  static const String _testImageBaseUrl = "https://www.online-tech.in/TestMasterImage/";

  Future<List<LabTest>> searchTests({
    String name = "",
    required int labId,
    int symptomId = 0,
  }) async {
    final body = {
      "name": name,
      "labId": labId,
      "symptomId": symptomId,
    };

    try {
      final response = await ApiCall.post(_testSearchEndpoint, body);

      if (response is List) {
        return response
            .map((json) => LabTest.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Handle case where API might return an unexpected non-list response
        throw Exception("API returned an unexpected format.");
      }
    } catch (e) {
      // Re-throw the exception for the BLoC to handle
      rethrow;
    }
  }

  static String getFullImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      return "https://www.online-tech.in/TestMasterImage/"; // Placeholder URL
    }
    return "$_testImageBaseUrl$imageName";
  }
}