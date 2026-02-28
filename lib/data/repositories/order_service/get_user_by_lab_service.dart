import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/user_by_lab_model.dart';

class GetUserByLabService {
  Future<List<UserByLabModel>> fetchUsersByLab() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the stored lab_id
    final int? labId = prefs.getInt('lab_id');

    if (labId == null) {
      throw Exception("Lab ID not found in local storage.");
    }

    final String url = "${ApiConstants.baseUrl}CompanyAPI/GetUserByLabId?LabId=$labId";

    final response = await ApiCall.get(url);

    if (response['succeeded'] == true) {
      List<dynamic> data = response['data'];
      return data.map((json) => UserByLabModel.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? "Failed to load users");
    }
  }
}