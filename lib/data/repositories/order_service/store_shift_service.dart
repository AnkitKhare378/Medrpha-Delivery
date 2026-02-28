import '../../../config/apiConstant/api_constant.dart';
import '../../../core/network/api_call.dart';
import '../../../models/OrderM/store_holiday_model.dart';
import '../../../models/OrderM/store_shift_model.dart';

class StoreShiftService {
  Future<List<StoreShiftModel>> fetchStoreShifts(int storeId) async {
    try {
      final response = await ApiCall.get("${ApiConstants.baseUrl}Lab/StoreShift?storeId=$storeId");

      // Since response is a List, we map it
      List<dynamic> data = response as List;
      return data.map((json) => StoreShiftModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StoreHolidayModel>> fetchStoreHolidays(int storeId) async {
    final response = await ApiCall.get("${ApiConstants.baseUrl}Lab/StoreHoliday?storeId=$storeId");
    return (response as List).map((e) => StoreHolidayModel.fromJson(e)).toList();
  }
}