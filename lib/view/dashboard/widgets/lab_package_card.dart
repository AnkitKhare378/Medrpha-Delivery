import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/color/colors.dart';
import '../../../models/LabM/lab_package_model.dart'; // Ensure correct path
import '../../../models/OrderM/insert_order_model.dart';
import '../../../view_models/OrderVM/insert_order_view_model.dart';

class LabPackageCard extends StatelessWidget {
  final LabPackageModel package;
  final bool? isInsert;
  final int? orderId;

  const LabPackageCard({
    super.key,
    required this.package,
    this.isInsert,
    this.orderId,
  });

  // Function to show confirmation dialog and dispatch BLoC event
  void _confirmAndInsert(BuildContext context) async {
    if (orderId == null || orderId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Order ID is missing or invalid.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Add Package to Order?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          content: Text(
            'Do you want to add "${package.packageName}" to this order?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Add Now', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Mapping Package to InsertOrderItemRequest
      final request = InsertOrderItemRequest(
        orderId: orderId!,
        productId: package.packageId, // Using packageId as productId
        categoryId: 3, // Packages usually have a default category or 0
        quantity: 1,
        unitPrice: package.packagePrice,
        discount: 0,
      );

      context.read<InsertOrderBloc>().add(PerformInsertOrderItem(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory_2_outlined, color: AppColors.primaryColor),
          ),
          title: Text(
            package.packageName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "Includes ${package.details.length} Tests",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                "₹${package.packagePrice}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          trailing: isInsert == true
              ? IconButton(
            onPressed: () => _confirmAndInsert(context),
            icon: Icon(Icons.add_circle, color: AppColors.primaryColor, size: 28),
          )
              : null,
          children: [
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tests Included:",
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  ...package.details.map((test) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            test.testName,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}