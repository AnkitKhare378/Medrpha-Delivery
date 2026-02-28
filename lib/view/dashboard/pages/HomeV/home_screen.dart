import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medrpha_delivery/config/color/colors.dart';
import '../../../../models/OrderM/get_order_model.dart';
import '../../../../models/OrderM/get_user_inventory_model.dart';
import '../../../../view_models/OrderVM/get_order_view_model.dart';
import '../../../../view_models/OrderVM/inventory_bloc.dart';
import 'delivery_list_screen.dart';
import 'pages/inventory_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetch();
  }

  /// 🎯 Fetches userId from SharedPreferences using getInt
  Future<void> _loadUserDataAndFetch() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // ✅ Using getInt('user_id') as per your requirement
      // Falling back to 3 if the stored value is null
      userId = prefs.getInt('user_id') ?? 3;

      if (mounted) {
        context.read<GetOrderBloc>().add(FetchAssignedOrders());
        context.read<InventoryBloc>().add(FetchInventory(userId!));
      }
    } catch (e) {
      debugPrint("❌ Error loading local storage: $e");
    }
  }

  Map<String, int> _getOrderCounts(List<AssignedOrder> orders) {
    final Map<String, int> counts = {
      'Cancelled': 0,
      'Scheduled': 0,
      'IsCollected ': 0,
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

  Widget _buildShimmerCard({bool isFullWidth = false}) {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: 95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required Color color,
    String? status,
    bool isCompleted = false,
    bool isCollected = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? () async {
          if (status == null) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeliveryListScreen(
                status: status,
                isCompleted: isCompleted, isCollected: isCollected,
              ),
            ),
          );
          if (context.mounted) {
            context.read<GetOrderBloc>().add(FetchAssignedOrders());
          }
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
        title: Text('Medrpha Delivery',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserDataAndFetch,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- 1. ORDERS SECTION ---
            BlocBuilder<GetOrderBloc, GetOrderState>(
              builder: (context, state) {
                if (state is GetOrderLoading) {
                  return Column(
                    children: [
                      Row(children: [_buildShimmerCard(isFullWidth: true)]),
                      const SizedBox(height: 10),
                      Row(children: [_buildShimmerCard(), _buildShimmerCard()]),
                    ],
                  );
                }

                List<AssignedOrder> allOrders = (state is GetOrderSuccess) ? state.orders : [];
                final counts = _getOrderCounts(allOrders);

                return Column(
                  children: [
                    Row(
                      children: [
                        _buildStatusCard(
                          title: 'Scheduled',
                          count: counts['Scheduled'] ?? 0,
                          color: Colors.blue.shade50,
                          status: 'Scheduled',
                        ),
                        _buildStatusCard(
                          title: 'Collected', // Display title
                          count: counts['IsCollected '] ?? 0, // Access key with trailing space
                          color: Colors.orange.shade50, // Changed color for visual difference
                          status: 'IsCollected ',
                          isCollected: true,// Pass the exact status to the next screen
                        ),
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
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // --- 2. INVENTORY SECTION ---
            BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return Row(children: [_buildShimmerCard(isFullWidth: true)]);
                }

                int totalItems = 0;
                List<InventoryData> items = [];

                if (state is InventoryLoaded) {
                  items = state.items;
                  totalItems = items.length;
                }

                return Row(
                  children: [
                    _buildStatusCard(
                      title: 'Total Inventory Items',
                      count: totalItems,
                      color: Colors.purple.shade50,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryDetailsScreen(items: items),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}