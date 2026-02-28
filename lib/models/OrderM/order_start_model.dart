class OrderStartResponse {
  final bool status;
  final String message;

  OrderStartResponse({required this.status, required this.message});

  factory OrderStartResponse.fromJson(Map<String, dynamic> json) {
    return OrderStartResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
    );
  }
}