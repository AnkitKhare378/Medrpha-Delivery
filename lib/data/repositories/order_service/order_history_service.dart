import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/order_history_model.dart';

class SharedPreferencesUtil {
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 55;
  }
}

class OrderHistoryService {
  final String _showOrderEndpoint = "${ApiConstants.baseUrl}Order/ShowOrder";
  Future<List<OrderHistoryModel>> fetchOrderHistory({
    required int userId,
    int? orderId,
  }) async {
    try {

      final apiOrderId = orderId ?? 0;

      final url = '$_showOrderEndpoint?userId=$userId&orderId=$apiOrderId';

      final responseData = await ApiCall.get(url);

      if (responseData != null && responseData['data'] is List) {
        final List<dynamic> ordersJson = responseData['data'];
        return ordersJson
            .map((json) => OrderHistoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception("Invalid response format from API.");
      }
    } catch (e) {
      print("Error fetching orders: $e");
      rethrow;
    }
  }
}