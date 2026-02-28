// delivery_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/color/colors.dart';
import '../../../../models/OrderM/get_order_model.dart';
import '../../../../view_models/OrderVM/get_order_view_model.dart';
import 'order_detail_screen.dart';

class DeliveryListScreen extends StatefulWidget {
  final String status;
  final bool isCompleted;
  final bool isCollected;

  const DeliveryListScreen({
    super.key,
    required this.status,
    required this.isCompleted,
    required this.isCollected,
  });

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetOrderBloc>().add(FetchAssignedOrders());
  }

  List<AssignedOrder> _filterOrders(List<AssignedOrder> allOrders, String status) {
    if (status == 'All') {
      return allOrders;
    }

    // Use trim() to handle "IsCollected " vs "IsCollected"
    final filterStatus = status.trim().toLowerCase();

    return allOrders
        .where((o) => o.status.trim().toLowerCase() == filterStatus)
        .toList();
  }

  Color _getOrderStatusColor(AssignedOrder order) {
    final String status = order.status.trim().toLowerCase();
    if (status.contains('complete')) return Colors.green.shade700;
    if (status.contains('cancel')) return Colors.grey.shade600;
    if (status.contains('iscollected')) return Colors.orange.shade700; // Distinct Orange for Collected
    if (status.contains('reschedule')) return Colors.orange.shade700;
    if (status.contains('schedule')) return Colors.blue.shade700;
    return Colors.red.shade700;
  }

  IconData _getOrderStatusIcon(AssignedOrder order) {
    final String status = order.status.trim().toLowerCase();
    if (status.contains('complete')) return Icons.check_circle;
    if (status.contains('cancel')) return Icons.cancel;
    if (status.contains('iscollected')) return Icons.inventory_2; // Package icon for Collected
    if (status.contains('reschedule')) return Icons.schedule;
    if (status.contains('schedule')) return Icons.calendar_today;
    return Icons.access_time;
  }

  @override
  Widget build(BuildContext context) {
    // Handle the display title for "IsCollected "
    final displayStatus = widget.status.trim() == "IsCollected" ? "Collected" : widget.status;
    final titleText = widget.status == 'All' ? 'All Assigned Orders' : '$displayStatus Orders';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(titleText,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
      ),
      body: BlocBuilder<GetOrderBloc, GetOrderState>(
        builder: (context, state) {
          if (state is GetOrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GetOrderFailure) {
            return Center(
              child: Text(
                'Failed to load orders: ${state.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is GetOrderSuccess) {
            final List<AssignedOrder> deliveries = _filterOrders(state.orders, widget.status);

            if (deliveries.isEmpty) {
              return Center(
                child: Text('No $displayStatus orders found.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final item = deliveries[index];
                final String status = item.status.trim().toLowerCase();

                // Hide call icon for Completed, Cancelled, or already Collected
                final bool shouldHideCall = status.contains('complete') ||
                    status.contains('cancel') ||
                    status.contains('iscollected');

                return Card(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    leading: Icon(
                      _getOrderStatusIcon(item),
                      color: _getOrderStatusColor(item),
                      size: 32,
                    ),
                    title: Text(
                      item.orderNumber,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Customer: ${item.userName}', style: GoogleFonts.poppins()),
                        Text(
                          'Status: ${item.status.trim()}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: _getOrderStatusColor(item),
                          ),
                        ),
                      ],
                    ),
                    trailing: shouldHideCall
                        ? null
                        : InkWell(
                      onTap: () async {
                        final String phone = item.userPhone.replaceAll(' ', '');
                        final Uri launchUri = Uri(scheme: 'tel', path: phone);

                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch dialer for $phone')),
                          );
                        }
                      },
                      child: Image.asset("assets/images/telephone-call.png", height: 40),
                    ),
                    onTap: () async {
                      // Navigate to Detail Screen
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(
                            orderId: item.orderId,
                            // If order is completed or we are in completed view, pass true
                            isCompleted: widget.isCompleted || status.contains('complete'),
                            lat: item.latitude ?? "",
                            long: item.longitude ?? "", isCollected: widget.isCollected,
                          ),
                        ),
                      );

                      // Refresh list when coming back
                      if (context.mounted) {
                        context.read<GetOrderBloc>().add(FetchAssignedOrders());
                      }
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Ready to load orders."));
        },
      ),
    );
  }
}