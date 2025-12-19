// lib/models/order/delete_order_model.dart

class DeleteOrderResponseModel {
  final String? message;
  final List<String>? messages;
  final bool succeeded;

  DeleteOrderResponseModel({
    this.message,
    this.messages,
    required this.succeeded,
  });

  factory DeleteOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteOrderResponseModel(
      message: json['message'] as String?,
      messages: json['messages'] != null
          ? List<String>.from(json['messages'].map((x) => x as String))
          : null,
      succeeded: json['succeeded'] as bool,
    );
  }

  // Helper getter to get the primary success message
  String get successMessage {
    if (messages != null && messages!.isNotEmpty) {
      return messages!.first;
    }
    return message ?? "Order item deleted successfully.";
  }
}