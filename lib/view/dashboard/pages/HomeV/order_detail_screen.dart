import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Your existing imports
import 'package:medrpha_delivery/view/dashboard/pages/LabTestV/lab_test_screen.dart';
import '../../../../data/repositories/order_service/delete_order_service.dart';
import '../../../../data/repositories/order_service/order_history_service.dart';
import '../../../../view_models/OrderVM/delete_order_view_model.dart';
import '../../../../view_models/OrderVM/order_history_view_model.dart';
import 'widgets/order_detail_view.dart';
import 'widgets/order_details_header.dart';
import 'widgets/order_items_list.dart';
import 'widgets/order_pricing_section.dart';
import '../../../../data/repositories/order_service/order_status_service.dart';
import '../../../../view_models/OrderVM/order_status_view_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final bool isCompleted;
  final bool isCollected;
  final String lat;
  final String long;
  const OrderDetailScreen({super.key, required this.orderId, required this.isCompleted,required this.isCollected, required this.lat, required this.long});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    try {
      const id = 1;
      setState(() {
        _userId = id;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching user ID: $e");
      setState(() {
        _userId = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Order #${widget.orderId}',)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final validUserId = _userId ?? 0;

    if (validUserId == 0) {
      return Scaffold(
        appBar: AppBar(title: Text('Order #${widget.orderId}')),
        body: const Center(child: Text('User ID not available.')),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OrderHistoryBloc(OrderHistoryService())
            ..add(
              FetchOrderHistoryEvent(
                userId: validUserId,
                orderId: widget.orderId,
              ),
            ),
        ),
        BlocProvider(
          create: (context) => DeleteOrderBloc(DeleteOrderService()),
        ),
        BlocProvider(
          create: (context) => OrderStatusBloc(OrderStatusService()),
        ),
      ],
      child: OrderDetailView(orderId: widget.orderId, userId: validUserId, isCompleted : widget.isCompleted, lat: widget.lat, long: widget.long, isCollected: widget.isCollected,),
    );
  }
}
