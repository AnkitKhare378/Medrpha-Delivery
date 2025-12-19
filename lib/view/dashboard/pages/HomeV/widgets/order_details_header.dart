import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../models/OrderM/order_history_model.dart';

class OrderDetailsHeader extends StatelessWidget {
  final OrderHistoryModel order;

  const OrderDetailsHeader({super.key, required this.order});

  String _formatOrderDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  String _formatCurrency(double amount) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);

  String _getStatus(int id) {
    return id == 1
        ? "Ordered"
        : id == 2
        ? "Shipped"
        : id == 3
        ? "Cancelled"
        : "Processing";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ${order.orderNumber}",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _row("Status:", "${order.status}",
                color: Colors.green),
            _row("Order Date:", _formatOrderDate(order.orderDate)),
            _row("Total Amount:", _formatCurrency(order.finalAmount),
                color: Colors.blueAccent, isLarge: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value,
      {Color color = Colors.black87, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade600)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: isLarge ? 16 : 14,
                  fontWeight:
                  isLarge ? FontWeight.w700 : FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}
