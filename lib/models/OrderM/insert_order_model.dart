class InsertOrderItemRequest {
  final int orderId;
  final int productId;
  final int categoryId;
  final int quantity;
  final double unitPrice;
  final double discount;

  InsertOrderItemRequest({
    required this.orderId,
    required this.productId,
    required this.categoryId,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "productId": productId,
      "categoryId": categoryId,
      "quantity": quantity,
      "unitPrice": unitPrice,
      "discount": discount,
    };
  }
}

// ----------------------------------------------------
// RESPONSE MODEL
// ----------------------------------------------------
class InsertOrderItemResponse {
  final bool status;
  final String message;

  InsertOrderItemResponse({
    required this.status,
    required this.message,
  });

  factory InsertOrderItemResponse.fromJson(Map<String, dynamic> json) {
    return InsertOrderItemResponse(
      // Ensure safe parsing for status and message
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? 'An unknown response was received.',
    );
  }
}