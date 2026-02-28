class UserInventoryModel {
  List<InventoryData>? data;
  List<dynamic>? messages;
  String? message;
  bool? succeeded;
  int? totalCount;
  int? totalPages;

  UserInventoryModel({this.data, this.messages, this.message, this.succeeded, this.totalCount, this.totalPages});

  UserInventoryModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <InventoryData>[];
      json['data'].forEach((v) {
        data!.add(InventoryData.fromJson(v));
      });
    }
    succeeded = json['succeeded'];
    message = json['message'];
  }
}

class InventoryData {
  int? itemId;
  String? itemName;
  int? totalQuantity;
  int? availbalQuantity; // Note: spelling matches your API response

  InventoryData({this.itemId, this.itemName, this.totalQuantity, this.availbalQuantity});

  InventoryData.fromJson(Map<String, dynamic> json) {
    itemId = json['itemId'];
    itemName = json['itemName'];
    totalQuantity = json['totalQuantity'];
    availbalQuantity = json['availbalQuantity'];
  }
}