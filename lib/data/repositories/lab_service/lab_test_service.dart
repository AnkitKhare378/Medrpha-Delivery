import 'package:shared_preferences/shared_preferences.dart'; // ✅ Add this
import '../../../core/network/api_call.dart';
import '../../../models/LabM/lab_test_model.dart';

class LabTestService {
  static const String _baseUrl = "https://online-tech.in/api/Lab/";
  static const String _testSearchEndpoint = "${_baseUrl}TestSearch";
  static const String _testImageBaseUrl = "https://online-tech.in/TestMasterImage/";

  Future<List<LabTest>> searchTests({
    String name = "",
    int? labId, // ✅ Changed to optional
    int symptomId = 0,
  }) async {

    // ✅ Logic to fetch from SharedPreferences if labId is not passed
    int finalLabId = labId ?? 1; // Default fallback
    if (labId == null) {
      final prefs = await SharedPreferences.getInstance();
      finalLabId = prefs.getInt('lab_id') ?? 1;
      print("📡 Service: Fetched lab_id from local storage: $finalLabId");
    }

    final body = {
      "name": name,
      "labId": finalLabId,
      "symptomId": symptomId,
    };

    try {
      final response = await ApiCall.post(_testSearchEndpoint, body);

      if (response is List) {
        return response
            .map((json) => LabTest.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("API returned an unexpected format.");
      }
    } catch (e) {
      rethrow;
    }
  }

  static String getFullImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      return "https://online-tech.in/TestMasterImage/";
    }
    return "$_testImageBaseUrl$imageName";
  }
}