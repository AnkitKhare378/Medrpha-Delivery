// lib/widgets/order/order_items_list.dart (Modified)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../models/OrderM/order_history_model.dart';
// NOTE: Adjust path based on your project structure

class OrderItemsList extends StatelessWidget {
  final List<OrderItemModel> items;
  // New callback function to handle the delete action
  final Function(int itemId) onDeleteItem;
  final bool isCompleted;

  const OrderItemsList({
    super.key,
    required this.isCompleted,
    required this.items,
    required this.onDeleteItem, // Required for delete action
  });

  String _formatCurrency(double amount) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => _itemRow(item))
          .toList(),
    );
  }

  Widget _itemRow(OrderItemModel item) {
    // Assuming OrderItemModel has an 'id' field for deletion
    final int itemId = item.orderItemId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(item.itemName.substring(0, 1),
                  style: GoogleFonts.poppins(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),

          // Name + Price (Expanded)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text("${item.quantity} x ${_formatCurrency(item.unitPrice)}",
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),

          // Total Price
          Text(_formatCurrency(item.quantity * item.unitPrice),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),

          const SizedBox(width: 8),
          if(isCompleted == false) ...[
            // DELETE ICON
            GestureDetector(
              onTap: () => onDeleteItem(itemId),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ),
            ),
          ]

        ],
      ),
    );
  }
}