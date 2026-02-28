import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/order_status_model.dart';

class OrderStatusService {
  Future<OrderStatusUpdateResponse> updateOrderStatus({
    required int orderId,
    required int statusType,
    String? orderDate, // Optional: No longer 'required'
    String? orderTime, // Optional: No longer 'required'
    required int sumbitUserId,
  }) async {
    final url = "${ApiConstants.baseUrl}Order/OrderCancle";

    // Initialize the body with the mandatory fields
    final Map<String, dynamic> body = {
      "orderId": orderId,
      "statusType": statusType,
      "status": true,
      "sumbitUserId": sumbitUserId,
    };

    // Only add date and time to the body if they are not null
    // This allows the same service to be used for "Assign Partner"
    // (no date) and "Reschedule" (with date).
    if (orderDate != null) {
      body["orderDate"] = orderDate;
    }

    if (orderTime != null) {
      body["orderTime"] = orderTime;
    }

    try {
      // Execute the POST request with the dynamic body
      final jsonResponse = await ApiCall.post(url, body);

      return OrderStatusUpdateResponse.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}