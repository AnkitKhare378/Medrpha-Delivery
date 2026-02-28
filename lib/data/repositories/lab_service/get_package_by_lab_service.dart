import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/LabM/lab_package_model.dart';

class LabPackageService {
  Future<List<LabPackageModel>> fetchPackagesByLab() async {
    final prefs = await SharedPreferences.getInstance();
    final int labId = prefs.getInt('lab_id') ?? 1; // Default to 1 if null

    final String url = "${ApiConstants.baseUrl}Package?id=$labId";

    final response = await ApiCall.get(url);

    if (response is List) {
      return response.map((json) => LabPackageModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format");
    }
  }
}