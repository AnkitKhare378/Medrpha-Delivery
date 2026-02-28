class AssignedOrder {
  final int id;
  final int orderId;
  final int userId;
  final String userName;
  final String orderNumber;
  final bool isActive;
  final bool isComplete;
  final bool isCanceled;
  final bool isScheduled;
  final bool isReScheduled;
  final String status;
  // New fields added below
  final String userPhone;
  final String? faltHousNumber;
  final String? pincode;
  final String? latitude;
  final String? longitude;
  final String? locality;
  final String? addressTitle;
  final String? deliveryBoy;

  AssignedOrder({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.orderNumber,
    required this.isActive,
    required this.isComplete,
    required this.isCanceled,
    required this.isScheduled,
    required this.isReScheduled,
    required this.status,
    required this.userPhone,
    this.faltHousNumber,
    this.pincode,
    this.latitude,
    this.longitude,
    this.locality,
    this.addressTitle,
    this.deliveryBoy,
  });

  factory AssignedOrder.fromJson(Map<String, dynamic> json) {
    return AssignedOrder(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      isActive: json['isActive'] ?? false,
      isComplete: json['isComplete'] ?? false,
      isCanceled: json['isCanceled'] ?? false,
      isScheduled: json['isScheduled'] ?? false,
      isReScheduled: json['isReScheduled'] ?? false,
      status: json['status'] ?? '',
      userPhone: json['userPhone'] ?? '',
      faltHousNumber: json['faltHousNumber'] as String?,
      pincode: json['pincode'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      locality: json['locality'] as String?,
      addressTitle: json['addressTitle'] as String?,
      deliveryBoy: json['deliveryBoy'] as String?,
    );
  }
}

class GetOrderResponse {
  final bool status;
  final List<AssignedOrder> data;

  GetOrderResponse({
    required this.status,
    required this.data,
  });

  factory GetOrderResponse.fromJson(Map<String, dynamic> json) {
    return GetOrderResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => AssignedOrder.fromJson(i))
          .toList(),
    );
  }
}