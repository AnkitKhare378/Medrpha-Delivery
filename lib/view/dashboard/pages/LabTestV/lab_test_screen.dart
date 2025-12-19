import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medrpha_delivery/config/color/colors.dart';
import '../../../../data/repositories/lab_service/lab_test_service.dart';
import '../../../../data/repositories/order_service/insert_order_service.dart'; // Import service
import '../../../../models/LabM/lab_test_model.dart';
import '../../../../models/OrderM/insert_order_model.dart'; // Import model
import '../../../../view_models/LabVM/lab_test_view_model.dart';
import '../../../../view_models/OrderVM/insert_order_view_model.dart';

class LabTestScreen extends StatelessWidget {
  final bool? isInsert;
  final int? orderId;
  const LabTestScreen({super.key, this.isInsert, this.orderId});

  static const int _defaultLabId = 1;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LabTestBloc(service: LabTestService())
            ..add(const LoadLabTests(labId: _defaultLabId)),
        ),
        BlocProvider(
          create: (context) => InsertOrderBloc(InsertOrderService()),
        ),
      ],
      child: BlocListener<InsertOrderBloc, InsertOrderState>(
        listener: (context, state) {
          if (state is InsertOrderSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ ${state.message}')),
            );
          } else if (state is InsertOrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Failed: ${state.error}')),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Lab Tests',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<LabTestBloc, LabTestState>(
              builder: (context, state) {
                if (state is LabTestLoading || state is InsertOrderLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LabTestError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is LabTestLoaded) {
                  return ListView.builder(
                    itemCount: state.tests.length,
                    itemBuilder: (context, index) {
                      final test = state.tests[index];
                      // Pass orderId down to the card
                      return LabTestCard(
                          test: test, isInsert: isInsert, orderId: orderId);
                    },
                  );
                }
                return const Center(child: Text("Start searching for tests."));
              },
            ),
          ),
        ),
      ),
    );
  }
}

class LabTestCard extends StatelessWidget {
  final LabTest test;
  final bool? isInsert;
  final int? orderId;

  const LabTestCard(
      {super.key, required this.test, this.isInsert, this.orderId});

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
          title: Text('Add Test to Order?', style: GoogleFonts.poppins(fontSize: 20),),
          content: Text(
              'Do you want to add "${test.testName}" to Order List', style: GoogleFonts.poppins(),),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87),),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final request = InsertOrderItemRequest(
        orderId: orderId!,
        productId: test.testID,
        categoryId: test.categoryID,
        quantity: 1,
        unitPrice: test.testPrice,
        discount: 0,
      );

      context.read<InsertOrderBloc>().add(PerformInsertOrderItem(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = LabTestService.getFullImageUrl(test.testImage);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.medical_services_outlined, size: 60, color: Colors.blueGrey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        test.testName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Display Price
                Row(
                  children: [
                    Text("₹${test.testPrice}", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                if (test.isFasting)
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu, size: 14, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                      Text("Fasting Required", style: GoogleFonts.poppins(fontSize: 12, color: Colors.deepOrange[700])),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text("No Fasting Required", style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[700])),
                    ],
                  ),
                const SizedBox(height: 6),
                // Display Synonym (simulating "By Labb" text)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: "Synonym: ",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                          children: [
                            TextSpan(
                              text: test.testSynonym?.name ?? "N/A",
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
          if (isInsert == true)
            IconButton(
              onPressed: () => _confirmAndInsert(context), // Call the confirmation function
              icon: const Icon(Icons.add_box_outlined, color: Colors.blueAccent),
            )
        ],
      ),
    );
  }
}