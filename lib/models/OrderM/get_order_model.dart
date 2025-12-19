// get_order_model.dart

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
  // New Fields
  final bool isReScheduled;
  final String status;

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
    // New Fields in constructor
    required this.isReScheduled,
    required this.status,
  });

  factory AssignedOrder.fromJson(Map<String, dynamic> json) {
    return AssignedOrder(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      orderNumber: json['orderNumber'] as String,
      isActive: json['isActive'] as bool,
      isComplete: json['isComplete'] as bool,
      isCanceled: json['isCanceled'] as bool,
      isScheduled: json['isScheduled'] as bool,
      // New Fields in fromJson
      isReScheduled: json['isReScheduled'] as bool,
      status: json['status'] as String,
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
    var list = json['data'] as List;
    List<AssignedOrder> orderList = list.map((i) => AssignedOrder.fromJson(i)).toList();

    return GetOrderResponse(
      status: json['status'] as bool,
      data: orderList,
    );
  }
}