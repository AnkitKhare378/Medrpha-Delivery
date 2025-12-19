// get_order_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/get_order_model.dart';

class GetOrderService {
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      throw Exception("User ID not found in local storage. Please log in again.");
    }
    return userId;
  }

  Future<List<AssignedOrder>> getAssignedOrders() async {
    final int userId = await _getUserId();

    final String url =
        "${ApiConstants.baseUrl}Order/GetOrderAssignedByUserId?userId=$userId";

    try {
      final response = await ApiCall.get(url);

      if (response is Map<String, dynamic>) {
        final responseModel = GetOrderResponse.fromJson(response);
        if (responseModel.status) {
          return responseModel.data;
        } else {
          return [];
        }
      } else {
        throw Exception("Invalid response format from server.");
      }
    } catch (e) {
      rethrow;
    }
  }
}