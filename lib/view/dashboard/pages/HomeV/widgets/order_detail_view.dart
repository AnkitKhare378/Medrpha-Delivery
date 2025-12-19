import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../view_models/OrderVM/delete_order_view_model.dart';
import '../../../../../view_models/OrderVM/order_history_view_model.dart';
import '../../../../../view_models/OrderVM/order_status_view_model.dart';
import '../../LabTestV/lab_test_screen.dart';
import 'order_details_header.dart';
import 'order_items_list.dart';
import 'order_pricing_section.dart';

class OrderDetailView extends StatelessWidget {
  final int orderId;
  final int userId;
  final bool isCompleted;

  const OrderDetailView({super.key, required this.orderId, required this.userId, required this.isCompleted});

  void _refreshOrder(BuildContext context) {
    context.read<OrderHistoryBloc>().add(
      FetchOrderHistoryEvent(
        userId: userId,
        orderId: orderId,
      ),
    );
  }

  void _deleteItem(BuildContext context, int itemId) {
    context.read<DeleteOrderBloc>().add(
      DeleteOrderItemRequested(itemId: itemId),
    );
  }

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet<int>(
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
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.pop(context, 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Rescheduled'),
              onTap: () {
                Navigator.pop(context, 5);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Completed'),
              onTap: () {
                Navigator.pop(context, 2);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    ).then((statusType) {
      if (statusType != null) {
        context.read<OrderStatusBloc>().add(
          UpdateOrderStatusRequested(
            orderId: orderId,
            statusType: statusType,
          ),
        );
        print('Selected Status Value: $statusType'); // Keep print for debugging
      }
    });
  }

  // 🎯 ACTIVATED FUNCTION: To handle picking a PDF file using file_picker
  Future<void> _pickPdfFile(BuildContext context) async {
    // Hide the bottom sheet before opening the file picker
    Navigator.pop(context);

    try {
      // Use file_picker to select a PDF file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        // 🎯 TODO: Implement your BLoC event or service call here
        // Example: context.read<UploadPdfBloc>().add(UploadPdf(filePath));

        print('Selected PDF path: $filePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected PDF: ${result.files.single.name} ready for upload.')),
        );
      } else {
        // User canceled the picker
        print('PDF picking cancelled.');
      }


    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  // 🎯 FUNCTION: To show the PDF upload option
  void _showPdfUploadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Upload Report',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.blueAccent),
              title: const Text('Upload PDF Report'),
              onTap: () {
                // Call the file picker handler
                _pickPdfFile(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
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

        // 2. 🚨 OrderStatusBloc Listener
        BlocListener<OrderStatusBloc, OrderStatusState>(
          listener: (context, state) {
            if (state is OrderStatusLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Updating status...')),
              );
            } else if (state is OrderStatusSuccess) {
              // Show success message from the API response
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.response.message)),
              );
              // Refresh order details to show the new status
              _refreshOrder(context);
            } else if (state is OrderStatusFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status update failed: ${state.error}')),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Order Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          actions: [
            if(isCompleted == false) ...[
              IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: () {
                  _showStatusBottomSheet(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outlined),
                onPressed: () async {
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LabTestScreen(isInsert: true, orderId: orderId,),
                    ),
                  );

                  if (result == true) {
                    _refreshOrder(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order data refreshed.')),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
            if(isCompleted == true) ...[
              // IconButton(
              //   icon: const Icon(Icons.picture_as_pdf),
              //   onPressed: () {
              //     // 🎯 Trigger the PDF upload bottom sheet
              //     _showPdfUploadBottomSheet(context);
              //   },
              // ),
              const SizedBox(width: 8),
            ]
          ],
        ),
        body: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
          builder: (context, state) {
            if (state is OrderHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderHistoryError) {
              return Center(child: Text('Failed to load order: ${state.message}'));
            }
            if (state is OrderHistoryLoaded) {
              if (state.orders.isEmpty) {
                return Center(child: Text('Order #$orderId not found.'));
              }

              final order = state.orders.first;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderDetailsHeader(order: order),
                    const SizedBox(height: 20),
                    Text(
                      "Items (${order.items.length})",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    OrderItemsList(
                      items: order.items,
                      onDeleteItem: (itemId) => _deleteItem(context, itemId), isCompleted: isCompleted,
                    ),
                    const SizedBox(height: 20),
                    OrderPricingSection(totalAmount: order.finalAmount),
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