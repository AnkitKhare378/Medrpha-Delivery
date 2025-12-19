// home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:medrpha_delivery/config/color/colors.dart';
import 'package:medrpha_delivery/view/dashboard/pages/HomeV/HomeSection/custom_home_boxes.dart';
import '../../../../models/OrderM/get_order_model.dart'; // Import model
import '../../../../view_models/OrderVM/get_order_view_model.dart'; // Import BLoC
import 'delivery_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 🎯 FIX: Trigger the BLoC to fetch data when the screen initializes
    context.read<GetOrderBloc>().add(FetchAssignedOrders());
  }

  // Helper method to get counts from the list of orders
  Map<String, int> _getOrderCounts(List<AssignedOrder> orders) {
    final Map<String, int> counts = {
      'Cancelled': 0,
      'Scheduled': 0,
      'Completed': 0,
      'Rescheduled': 0,
      'Total': 0,
    };

    for (var order in orders) {
      final status = order.status;
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
      counts['Total'] = counts['Total']! + 1;
    }
    return counts;
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required Color color,
    required String status,
    required bool isCompleted,
  }) {
    // ... (same as before, no changes needed here)
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeliveryListScreen(
                status: status, isCompleted: isCompleted,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Medrpha Delivery', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<GetOrderBloc, GetOrderState>( // 🎯 Use BlocBuilder
        builder: (context, state) {
          if (state is GetOrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // if (state is GetOrderFailure) {
          //   return Center(
          //     child: Text('Error loading orders: ${state.error}'),
          //   );
          // }

          List<AssignedOrder> allOrders = [];
          if (state is GetOrderSuccess) {
            allOrders = state.orders;
          }

          // 🎯 Calculate counts based on the loaded data (or empty list)
          final counts = _getOrderCounts(allOrders);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 🎯 UPDATED: Four status cards
              Row(
                children: [
                  _buildStatusCard(
                    title: 'Scheduled',
                    count: counts['Scheduled'] ?? 0,
                    color: Colors.blue.shade50,
                    status: 'Scheduled',
                    isCompleted: false,
                  ),
                  // _buildStatusCard(
                  //   title: 'Rescheduled',
                  //   count: counts['Rescheduled'] ?? 0,
                  //   color: Colors.orange.shade50,
                  //   status: 'Rescheduled',
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatusCard(
                    title: 'Completed',
                    count: counts['Completed'] ?? 0,
                    color: Colors.green.shade50,
                    status: 'Completed',
                    isCompleted: true,
                  ),
                  _buildStatusCard(
                    title: 'Cancelled',
                    count: counts['Cancelled'] ?? 0,
                    color: Colors.red.shade50,
                    status: 'Cancelled',
                    isCompleted: false,
                  ),
                ],
              ),
              // const SizedBox(height: 20),
              // CustomHomeBoxes(),
            ],
          );
        },
      ),
    );
  }
}