// lib/models/order_status_model.dart

class OrderStatusUpdateResponse {
  final bool status;
  final String message;

  OrderStatusUpdateResponse({required this.status, required this.message});

  factory OrderStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdateResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
    );
  }
}