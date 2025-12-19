import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderPricingSection extends StatelessWidget {
  final double totalAmount;

  const OrderPricingSection({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    String format(double amt) =>
        "₹${amt.toStringAsFixed(2)}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Pricing",
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _priceRow("Subtotal", format(totalAmount)),
        _priceRow("Discount", "₹0.00", isDiscount: true),
        const Divider(),
        _priceRow("Total Paid", format(totalAmount), isTotal: true),
      ],
    );
  }

  Widget _priceRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    final color = isTotal
        ? Colors.blueAccent
        : isDiscount
        ? Colors.red
        : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight:
                  isTotal ? FontWeight.w700 : FontWeight.w500)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight:
                  isTotal ? FontWeight.w700 : FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}
