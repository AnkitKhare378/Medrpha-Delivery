import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medrpha_delivery/config/color/colors.dart';
import '../../../../data/repositories/lab_service/get_package_by_lab_service.dart';
import '../../../../data/repositories/lab_service/lab_test_service.dart';
import '../../../../data/repositories/order_service/insert_order_service.dart'; // Import service
import '../../../../models/LabM/lab_test_model.dart';
import '../../../../models/OrderM/insert_order_model.dart'; // Import model
import '../../../../view_models/LabVM/lab_package_bloc.dart';
import '../../../../view_models/LabVM/lab_test_view_model.dart';
import '../../../../view_models/OrderVM/insert_order_view_model.dart';
import '../../../app_widgets/no_data_found.dart';
import '../../widgets/lab_package_card.dart';
import '../../widgets/lab_test_card.dart';

class LabTestScreen extends StatelessWidget {
  final bool? isInsert;
  final int? orderId;
  const LabTestScreen({super.key, this.isInsert, this.orderId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LabTestBloc(service: LabTestService())
            ..add(const LoadLabTests()), // Should use sharedPrefs logic too
        ),
        BlocProvider(
          create: (context) => LabPackageBloc(LabPackageService())
            ..add(LoadLabPackages()),
        ),
        BlocProvider(
          create: (context) => InsertOrderBloc(InsertOrderService()),
        ),
      ],
      child: DefaultTabController(
        length: 2,
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
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: Text('Diagnostics', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              bottom: TabBar(
                // The color of the line under the selected tab
                indicatorColor: Colors.white,
                indicatorWeight: 3,

                // ✅ Sets the color for the selected tab text/icon
                labelColor: Colors.white,

                // ✅ Sets the color for the unselected tabs (with some transparency for contrast)
                unselectedLabelColor: Colors.white.withOpacity(0.7),

                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: "Individual Tests"),
                  Tab(text: "Health Packages"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildTestList(isInsert, orderId),
                _buildPackageList(isInsert, orderId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Tests List View ---
  Widget _buildTestList(bool? isInsert, int? orderId) {
    return BlocBuilder<LabTestBloc, LabTestState>(
      builder: (context, state) {
        if (state is LabTestLoading) return const Center(child: CircularProgressIndicator());
        if (state is LabTestLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.tests.length,
            itemBuilder: (context, index) => LabTestCard(
                test: state.tests[index],
                isInsert: isInsert,
                orderId: orderId
            ),
          );
        }
        return const NoDataFoundScreen();
      },
    );
  }

  // --- Packages List View ---
  Widget _buildPackageList(bool? isInsert, int? orderId) {
    return BlocBuilder<LabPackageBloc, LabPackageState>(
      builder: (context, state) {
        if (state is LabPackageLoading) return const Center(child: CircularProgressIndicator());
        if (state is LabPackageLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.packages.length,
            itemBuilder: (context, index) {
              final package = state.packages[index];
              return LabPackageCard( // You will need to create this widget
                package: package,
                isInsert: isInsert,
                orderId: orderId,
              );
            },
          );
        }
        return const NoDataFoundScreen();
      },
    );
  }
}

