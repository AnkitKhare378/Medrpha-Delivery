import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medrpha_delivery/config/color/colors.dart';
import 'package:medrpha_delivery/view/dashboard/pages/HomeV/pages/user_selection_page.dart';

class OrderCompletedStatus extends StatefulWidget {
  final int orderId;
  final DateTime orderDate;
  final String status;
  final bool isCollected;

  const OrderCompletedStatus({
    super.key,
    required this.orderId,
    required this.orderDate,
    required this.status,
    required this.isCollected,
  });

  @override
  State<OrderCompletedStatus> createState() => _OrderCompletedStatusState();
}

class _OrderCompletedStatusState extends State<OrderCompletedStatus> {
  @override
  Widget build(BuildContext context) {
    final String cleanStatus = widget.status.trim().toLowerCase();

    // Check if the order is currently in the 'Collected' phase (Status 7)
    final bool isCollectedState = widget.isCollected || cleanStatus == "iscollected";

    // Check if the order is already fully finished (Status 2)
    final bool isFullyCompleted = cleanStatus == "completed" || cleanStatus == "2";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- STATUS BADGE ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
              color: isCollectedState && !isFullyCompleted
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isCollectedState && !isFullyCompleted ? Colors.orange : Colors.green,
              )),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCollectedState && !isFullyCompleted ? Icons.inventory_2 : Icons.check_circle,
                color: isCollectedState && !isFullyCompleted ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                isCollectedState && !isFullyCompleted ? "Collected" : "Completed",
                style: GoogleFonts.poppins(
                    color: isCollectedState && !isFullyCompleted ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // --- SUBMISSION BUTTON ---
        // ONLY show Submission if it is Collected and NOT yet fully Completed
        if (isCollectedState && !isFullyCompleted) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserSelectionPage(
                      orderId: widget.orderId,
                      orderDate: widget.orderDate,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Submission",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}