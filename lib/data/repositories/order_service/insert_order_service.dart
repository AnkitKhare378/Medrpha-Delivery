import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/insert_order_model.dart';

class InsertOrderService {
  final String _apiUrl = "${ApiConstants.baseUrl}Order/InsertOrderItem";

  Future<InsertOrderItemResponse> insertOrderItem(
      InsertOrderItemRequest request) async {
    try {
      final responseData = await ApiCall.post(_apiUrl, request.toJson());

      return InsertOrderItemResponse.fromJson(responseData);
    } catch (e) {
      // Re-throw the exception to be caught by the BLoC
      rethrow;
    }
  }
}