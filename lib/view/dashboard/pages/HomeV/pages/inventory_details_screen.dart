import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medrpha_delivery/config/color/colors.dart';
import '../../../../../models/OrderM/get_user_inventory_model.dart';

class InventoryDetailsScreen extends StatelessWidget {
  final List<InventoryData> items;
  const InventoryDetailsScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Inventory Stock",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Calculate percentage for the progress bar
          double availabilityRatio = 0.0;
          if (item.totalQuantity != null && item.totalQuantity! > 0) {
            availabilityRatio = (item.availbalQuantity ?? 0) / item.totalQuantity!;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName ?? "Unknown Item",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoColumn("Available", "${item.availbalQuantity}", Colors.green),
                      const Spacer(),
                      _buildInfoColumn("Total Stock", "${item.totalQuantity}", Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Linear Progress Indicator to visualize stock
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: availabilityRatio,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        availabilityRatio < 0.2 ? Colors.red : AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No Inventory Found",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}