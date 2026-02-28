import 'dart:convert';

class OrderHistoryResponseModel {
  final List<OrderHistoryModel> data;
  final int totalCount;
  final int totalPages;
  final bool succeeded;
  final String? message;

  OrderHistoryResponseModel({
    required this.data,
    required this.totalCount,
    required this.totalPages,
    required this.succeeded,
    this.message,
  });

  factory OrderHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle potential null/empty data list safely
    final dataList = json['data'] as List?;

    return OrderHistoryResponseModel(
      data: dataList
          ?.map((i) => OrderHistoryModel.fromJson(i as Map<String, dynamic>))
          .toList() ?? [], // Provide an empty list as a default
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] as int? ?? 0, // ⬅️ Parsed New Field
      succeeded: json['succeeded'] ?? false,
      message: json['message'] as String?, // Cast to nullable String
    );
  }
}

class OrderHistoryModel {
  final int orderId;
  final String orderNumber;
  final DateTime orderDate;

  final int orderStatus;
  final int paymentStatus;
  final int paymentMethod;

  final double subTotal;
  final double discountAmount;
  final double finalAmount;

  final String status;
  final List<OrderItemModel> items;

  OrderHistoryModel({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.subTotal,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.items,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    final String itemsJsonString = json['itemsJson'] as String? ?? '[]';
    final List<dynamic> itemsList = jsonDecode(itemsJsonString);

    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is int) return value;
      return 0;
    }

    return OrderHistoryModel(
      orderId: json['orderId'] as int? ?? 0,
      orderNumber: json['orderNumber'] as String? ?? 'N/A',
      orderDate: DateTime.tryParse(json['orderDate'] as String? ?? '') ?? DateTime(2000),
      orderStatus: safeParseInt(json['orderStatus']),
      paymentStatus: safeParseInt(json['paymentStatus']),
      paymentMethod: safeParseInt(json['paymentMethod']),

      subTotal: (json['subTotal'] as num? ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] as num? ?? 0.0).toDouble(),
      finalAmount: (json['finalAmount'] as num? ?? 0.0).toDouble(),

      status: json['status'] as String? ?? 'Unknown', // ⬅️ Parsed New Field

      items: itemsList
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderItemModel {
  final int productId;
  final int orderItemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int labId;

  OrderItemModel({
    required this.productId,
    required this.orderItemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.labId,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['ProductId'] as int? ?? 0,
      orderItemId: json['OrderItemId'] as int? ?? 0,
      itemName: json['itemName'] as String? ?? 'Item N/A', // Null safety for String
      quantity: json['Quantity'] as int? ?? 0,
      labId: json['LabId'] as int? ?? 0,
      unitPrice: (json['UnitPrice'] as num? ?? 0.0).toDouble(), // Null safety for double
      totalPrice: (json['TotalPrice'] as num? ?? 0.0).toDouble(), // Null safety for double
    );
  }
}