import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:medrpha_delivery/view/dashboard/pages/HomeV/widgets/order_completed_status.dart';
import '../../../../../config/color/colors.dart';
import '../../../../../view_models/OrderVM/delete_order_view_model.dart';
import '../../../../../view_models/OrderVM/order_history_view_model.dart';
import '../../../../../view_models/OrderVM/order_start_bloc.dart';
import '../../../../../view_models/OrderVM/order_status_view_model.dart';
import '../../../widgets/slide_page_route.dart';
import '../../LabTestV/lab_test_screen.dart';
import '../pages/location_picker_screen.dart';
import 'order_details_header.dart';
import 'order_items_list.dart';
import 'order_pricing_section.dart';
import 'slot_card.dart';

class OrderDetailView extends StatefulWidget {
  final int orderId;
  final int userId;
  final bool isCompleted;
  final bool isCollected;
  final String lat;
  final String long;

  OrderDetailView({
    super.key,
    required this.orderId,
    required this.userId,
    required this.isCompleted,
    required this.isCollected,
    required this.lat,
    required this.long,
  });

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  bool _localStarted = false;
  bool _localEnded = false;

  void _refreshOrder(BuildContext context) {
    context.read<OrderHistoryBloc>().add(
      FetchOrderHistoryEvent(
        userId: widget.userId,
        orderId: widget.orderId,
      ),
    );
  }

  void _deleteItem(BuildContext context, int itemId) async {
    // 1. Wait for the user's confirmation
    final bool confirmed = await _confirmDelete(context);

    // 2. Only trigger the Bloc if they pressed "Delete"
    if (confirmed && context.mounted) {
      context.read<DeleteOrderBloc>().add(
        DeleteOrderItemRequested(itemId: itemId),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white, // Prevents Material 3 tinting
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Confirm Deletion',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          content: Text(
            'Are you sure you want to remove this from your order?',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // --- START OF RESCHEDULE LOGIC ---
  void _showStatusBottomSheet(BuildContext context) async {
    final int? statusType = await showModalBottomSheet<int>(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Update Order Status',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel Order'),
              onTap: () => Navigator.pop(context, 1),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.orange),
              title: const Text('Reschedule'),
              onTap: () => Navigator.pop(context, 5),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Mark as Completed'),
              onTap: () => Navigator.pop(context, 2),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );

    if (statusType == null || !context.mounted) return;

    // 1. Handle Rescheduling (No confirmation usually needed for picking a date)
    if (statusType == 5) {
      _selectDateTime(context);
      return;
    }

    // 2. Map status ID to a readable name for the dialog
    String statusName = statusType == 1 ? "Cancel" : "Complete";

    // 3. Trigger Confirmation Dialog
    bool confirmed = await _confirmStatusChange(context, statusName);

    // 4. Fire Bloc event if confirmed
    if (confirmed && context.mounted) {
      context.read<OrderStatusBloc>().add(
        UpdateOrderStatusRequested(
          orderId: widget.orderId,
          statusType: statusType, orderDate: '', orderTime: '', sumbitUserId: 0,
        ),
      );
    }
  }

  Future<void> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onConfirm(); // Trigger action
            },
            child: Text("Confirm", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmStatusChange(BuildContext context, String action) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Confirm Action',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          content: Text(
            'Are you sure you want to $action this order? This action may be permanent.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Back', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(
                  color: action == "Cancel" ? Colors.redAccent : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // 1. Get the storeId and order details from the current state
    final historyState = context.read<OrderHistoryBloc>().state;
    if (historyState is! OrderHistoryLoaded || historyState.orders.isEmpty) return;

    final order = historyState.orders.first;
    // Assuming the first item has the labId/storeId needed for shifts
    final int storeId = order.items.isNotEmpty ? order.items.first.labId : 0;

    if (storeId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lab information missing for this order.")),
      );
      return;
    }

    // 2. Variables to capture data from SlotCard
    String? finalFormattedDate;
    String? finalFormattedTime;

    // 3. Show Dialog containing the SlotCard
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Reschedule Order',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            child: SlotCard(
              storeId: storeId,
              forOrder: true, // Uses the clean UI version
              onDateSelected: (isoDate) {
                finalFormattedDate = isoDate;
              },
              onTimeSelected: (formattedTime) {
                finalFormattedTime = formattedTime;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                // Validate that a time was selected
                if (finalFormattedTime != null) {
                  Navigator.pop(dialogContext, true);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text("Please select a time slot")),
                  );
                }
              },
              child: Text('Confirm', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && finalFormattedTime != null && context.mounted) {
        // Use the picked date or fallback to now if not changed
        final String dateToSend = finalFormattedDate ?? DateTime.now().toIso8601String();

        context.read<OrderStatusBloc>().add(
          UpdateOrderStatusRequested(
            orderId: widget.orderId,
            statusType: 5,
            orderDate: dateToSend,
            orderTime: finalFormattedTime!, sumbitUserId: 0, // Format: "HH:mm:ss"
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.isCollected);
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteOrderBloc, DeleteOrderState>(
          listener: (context, state) {
            if (state is DeleteOrderSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.response.successMessage)),
              );
              _refreshOrder(context);
            } else if (state is DeleteOrderFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
        ),
        BlocListener<OrderStatusBloc, OrderStatusState>(
          listener: (context, state) {
            if (state is OrderStatusLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Updating status...')),
              );
            } else if (state is OrderStatusSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.response.message)),
              );
              _refreshOrder(context);
            } else if (state is OrderStatusFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status update failed: ${state.error}')),
              );
            }
          },
        ),
        BlocListener<OrderStartBloc, OrderStartState>(
          listener: (context, state) {
            if (state is OrderStartSuccess) {
              // Check for specific success message to toggle End button
              if (state.response.message == "Status updated successfully.") {
                setState(() {
                  _localStarted = true;
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.response.message), backgroundColor: Colors.green),
              );
              // Move to location picker
              Navigator.of(context).push(
                SlidePageRoute(page: LocationPickerScreen(latitude: widget.lat, longitude: widget.long)),
              );
            } else if (state is OrderStartFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
        ),
        BlocListener<OrderEndBloc, OrderEndState>(
          listener: (context, state) {
            if (state is OrderEndSuccess) {
              if (state.response.message == "Status updated successfully.") {
                setState(() {
                  _localEnded = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Completed"), backgroundColor: Colors.green),
                );

                // Wait a moment to show "Completed" then go back and reload
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) Navigator.pop(context, true);
                });
              }
            } else if (state is OrderEndFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Order Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          actions: [
            if (!widget.isCompleted && !_localEnded) ...[
              IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: () => _showStatusBottomSheet(context),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outlined),
                onPressed: () async {
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LabTestScreen(isInsert: true, orderId: widget.orderId)),
                  );
                  if (result == true) _refreshOrder(context);
                },
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        body: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
          builder: (context, state) {
            if (state is OrderHistoryLoading) return const Center(child: CircularProgressIndicator());
            if (state is OrderHistoryError) return Center(child: Text('Error: ${state.message}'));
            if (state is OrderHistoryLoaded) {
              if (state.orders.isEmpty) return const Center(child: Text('Order not found.'));

              final order = state.orders.first;

              // Logic to determine which button or status to show
              final bool isStarted = _localStarted || order.status == 6;
              final bool isEnded = _localEnded || order.status == 2 || widget.isCompleted;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderDetailsHeader(order: order),
                    const SizedBox(height: 20),
                    Text("Items (${order.items.length})",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    OrderItemsList(
                      items: order.items,
                      onDeleteItem: (itemId) => _deleteItem(context, itemId),
                      isCompleted: isEnded,
                    ),
                    const SizedBox(height: 20),
                    OrderPricingSection(totalAmount: order.finalAmount),
                    const SizedBox(height: 30),

                    // --- DYNAMIC BUTTON SECTION ---
                    Center(
                      child: (isEnded || widget.isCollected || order.status.toString().trim().toLowerCase() == "iscollected")
                          ? OrderCompletedStatus(
                        orderId: order.orderId,
                        orderDate: order.orderDate,
                        status: order.status,
                        isCollected: widget.isCollected// Pass the actual status string here
                      )
                          : Row(
                        children: [
                          if (!isStarted)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showConfirmDialog(
                                    context: context,
                                    title: "Start Order?",
                                    message: "Are you sure you want to start this order?",
                                    onConfirm: () {
                                      context.read<OrderStartBloc>().add(
                                        StartOrderRequested(widget.orderId, 6, 0),
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    shape: const StadiumBorder()),
                                child: BlocBuilder<OrderStartBloc, OrderStartState>(
                                  builder: (context, state) {
                                    if (state is OrderStartLoading) {
                                      return const SizedBox(
                                        height: 20, width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      );
                                    }
                                    return Text("Pickup", style: GoogleFonts.poppins(color: Colors.white));
                                  },
                                ),
                              ),
                            ),
                          if (isStarted)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showConfirmDialog(
                                    context: context,
                                    title: "End Order?",
                                    message: "Do you want to complete and end this order?",
                                    onConfirm: () {
                                      context.read<OrderEndBloc>().add(
                                        EndOrderRequested(widget.orderId, 7, 1),
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.endColor,
                                    shape: const StadiumBorder()),
                                child: BlocBuilder<OrderEndBloc, OrderEndState>(
                                  builder: (context, state) {
                                    if (state is OrderEndLoading) {
                                      return const SizedBox(
                                        height: 20, width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      );
                                    }
                                    return Text("Collected", style: GoogleFonts.poppins(color: Colors.white));
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}