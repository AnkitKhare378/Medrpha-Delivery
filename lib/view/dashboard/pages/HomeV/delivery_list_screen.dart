// delivery_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/color/colors.dart';
import '../../../../models/OrderM/get_order_model.dart';
import '../../../../view_models/OrderVM/get_order_view_model.dart';
import 'order_detail_screen.dart';

class DeliveryDetailScreen extends StatelessWidget {
  final AssignedOrder delivery;
  const DeliveryDetailScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(delivery.orderNumber)));
}

class DeliveryListScreen extends StatefulWidget {
  final String status;
  final isCompleted;

  const DeliveryListScreen({super.key, required this.status, required this.isCompleted});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the BLoC to fetch data when the screen initializes
    context.read<GetOrderBloc>().add(FetchAssignedOrders());
  }

  // --- CORRECTED FILTER LOGIC ---
  List<AssignedOrder> _filterOrders(List<AssignedOrder> allOrders, String status) {
    if (status == 'All') {
      // Show all data when status is 'All'
      return allOrders;
    }

    // 🎯 FIX: Filter based on the explicit 'status' field from the model,
    // ignoring the old boolean flags (isComplete, isCanceled, isActive).
    final filterStatus = status.toLowerCase();

    return allOrders
        .where((o) => o.status.toLowerCase() == filterStatus)
        .toList();
  }

  // --- UPDATED: Use the new 'status' field for color/icon logic ---
  Color _getOrderStatusColor(AssignedOrder order) {
    final String status = order.status.toLowerCase();
    if (status.contains('complete')) return Colors.green.shade700;
    if (status.contains('cancel')) return Colors.grey.shade600;
    if (status.contains('reschedule')) return Colors.orange.shade700; // Added Rescheduled color
    if (status.contains('schedule')) return Colors.blue.shade700;
    return Colors.red.shade700; // Default for Pending/Active/Unknown
  }

  IconData _getOrderStatusIcon(AssignedOrder order) {
    final String status = order.status.toLowerCase();
    if (status.contains('complete')) return Icons.check_circle;
    if (status.contains('cancel')) return Icons.cancel;
    if (status.contains('reschedule')) return Icons.schedule; // Icon for Rescheduled
    if (status.contains('schedule')) return Icons.calendar_today;
    return Icons.access_time; // Default for Pending/Active
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.status == 'All' ? 'All Assigned Orders' : '${widget.status} Orders';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(titleText,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(onPressed: (){ Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, color: Colors.white,)),
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
            // Filter orders based on the widget's status property
            final List<AssignedOrder> deliveries = _filterOrders(state.orders, widget.status);

            if (deliveries.isEmpty) {
              return Center(
                child: Text('No $titleText found.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final item = deliveries[index];
                return Card(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    leading: Icon(
                      _getOrderStatusIcon(item),
                      color: _getOrderStatusColor(item),
                      size: 32,
                    ),
                    title: Text(
                      item.orderNumber,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Using userName as Customer Name
                        Text('Customer: ${item.userName}', style: GoogleFonts.poppins(),),
                        // Displaying the new 'item.status' directly
                        Text(
                          'Status: ${item.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getOrderStatusColor(item),
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.primaryColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(orderId: item.orderId, isCompleted: widget.isCompleted,),
                        ),
                      );
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