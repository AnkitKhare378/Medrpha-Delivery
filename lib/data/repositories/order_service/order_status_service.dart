

import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/order_status_model.dart';

class OrderStatusService {
  /// Calls the API to update the order status.
  /// API: https://www.online-tech.in/api/Order/OrderCancle?orderId={orderId}&statusType={statusType}&status=true
  Future<OrderStatusUpdateResponse> updateOrderStatus({
    required int orderId,
    required int statusType,
  }) async {
    // Note: The API name 'OrderCancle' suggests cancellation,
    // but its function is to update status based on the statusType parameter.
    final url =
        "${ApiConstants.baseUrl}Order/OrderCancle?orderId=$orderId&statusType=$statusType&status=true";

    try {
      final jsonResponse = await ApiCall.get(url);

      return OrderStatusUpdateResponse.fromJson(jsonResponse);
    } catch (e) {
      // Re-throw the exception to be caught by the BLoC
      throw Exception('Failed to update order status: $e');
    }
  }
}