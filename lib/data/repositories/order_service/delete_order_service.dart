

import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/delete_order_model.dart';

class DeleteOrderService {
  // Define the base API URL for the delete operation
  static const String _apiUrl = "${ApiConstants.baseUrl}Order/DeleteOrderItem";

  /// Deletes an order item by its ID.
  /// The API uses a GET request with the ID as a query parameter.
  Future<DeleteOrderResponseModel> deleteOrderItem(int itemId) async {
    final String url = "$_apiUrl?id=$itemId";

    try {
      final responseData = await ApiCall.get(url);

      // The API response is parsed into the model
      return DeleteOrderResponseModel.fromJson(responseData);
    } catch (e) {
      // Re-throw the exception for the BLoC to handle
      throw Exception('Failed to delete order item: $e');
    }
  }
}