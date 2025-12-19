

import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/AccountM/company_login_model.dart';

class CompanyLoginService {
  Future<CompanyLoginModel> companyUserLogin({
    required String email,
    required String password,
  }) async {
    // URL Encode the parameters for safety
    final encodedEmail = Uri.encodeComponent(email);
    final encodedPassword = Uri.encodeComponent(password);

    final String url =
        "${ApiConstants.baseUrl}CompanyAPI/CompanyUserLogin?Email=$encodedEmail&Password=$encodedPassword";

    try {
      final response = await ApiCall.get(url);

      if (response is List && response.isNotEmpty) {
        final CompanyLoginModel? model = CompanyLoginModel.fromListJson(response);
        if (model != null) {
          return model;
        } else {
          // If response is an empty list, treat it as invalid credentials/not found
          throw Exception("Invalid email or password.");
        }
      } else {
        // Handle cases where the response is not a list or is unexpected
        throw Exception("Login failed. Unexpected response from server.");
      }
    } catch (e) {
      // Re-throw exceptions from ApiCall or custom exceptions
      rethrow;
    }
  }
}