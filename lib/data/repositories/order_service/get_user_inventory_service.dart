import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/get_user_inventory_model.dart';

class InventoryService {
  Future<UserInventoryModel> fetchInventory(int userId) async {
    try {
      final response = await ApiCall.get("${ApiConstants.baseUrl}InvetoryApi/GetUserInventory?UserId=$userId");
      return UserInventoryModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}