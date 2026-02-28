import '../../../core/network/api_call.dart';
import '../../../models/OrderM/order_start_model.dart';

class OrderStartService {
  Future<OrderStartResponse> startOrder(int orderId, int statusType, int paymentType) async {
    // 1. Remove query params from the URL
    const String url = "https://online-tech.in/api/Order/OrderCancle";

    // 2. Prepare the Map for the Raw Body
    final Map<String, dynamic> body = {
      "orderId": orderId,
      "statusType": statusType,
      "status": true,
      "paymenttype": paymentType,
    };

    // 3. Call the .post method (which handles jsonEncode internally)
    final response = await ApiCall.post(url, body);
    return OrderStartResponse.fromJson(response);
  }
}