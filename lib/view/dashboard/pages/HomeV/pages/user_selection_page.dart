import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/color/colors.dart';
import '../../../../../models/OrderM/user_by_lab_model.dart';
import '../../../../../view_models/OrderVM/order_status_view_model.dart';
import '../../../../../view_models/OrderVM/user_selection_bloc.dart';

class UserSelectionPage extends StatefulWidget {
  final int orderId;
  final DateTime orderDate;

  const UserSelectionPage({
    super.key,
    required this.orderId,
    required this.orderDate
  });

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  UserByLabModel? selectedUser;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load users on init
    context.read<UserSelectionBloc>().add(FetchUsersEvent());
  }

  void _showSearchBottomSheet(List<UserByLabModel> users) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<UserByLabModel> filteredUsers = users
                .where((u) => u.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Select Delivery Partner",
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: searchController,
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      hintText: "Search by name...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => setModalState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                            child: Text(user.name[0],
                                style: TextStyle(color: AppColors.primaryColor)),
                          ),
                          title: Text(user.name, style: GoogleFonts.poppins()),
                          subtitle: Text(user.email,
                              style: GoogleFonts.poppins(fontSize: 12)),
                          onTap: () {
                            setState(() => selectedUser = user);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Assign Partner',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<UserSelectionBloc, UserSelectionState>(
        builder: (context, state) {
          if (state is UserLoading) return const Center(child: CircularProgressIndicator());
          if (state is UserError) return Center(child: Text(state.message));

          if (state is UserLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Delivery Partner",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),

                  // Partner Selector
                  InkWell(
                    onTap: () => _showSearchBottomSheet(state.users),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedUser?.name ?? "Choose Partner",
                            style: GoogleFonts.poppins(
                                color: selectedUser == null ? Colors.grey : Colors.black),
                          ),
                          Icon(Icons.person_search, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                  ),

                  if (selectedUser != null) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "Contact: ${selectedUser!.phone} | ${selectedUser!.email}",
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  Text("Remarks",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: remarksController,
                    maxLines: 4,
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      hintText: "Enter remark here...",
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- SUBMISSION BLOCK ---
                  BlocConsumer<OrderStatusBloc, OrderStatusState>(
                    listener: (context, statusState) {
                      if (statusState is OrderStatusSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Partner assigned successfully!"),
                              backgroundColor: Colors.green),
                        );
                        // Return true so the previous page knows to refresh
                        Navigator.pop(context, true);
                      } else if (statusState is OrderStatusFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(statusState.error),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
                    builder: (context, statusState) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (selectedUser == null || statusState is OrderStatusLoading)
                              ? null
                              : () {
                            // Close keyboard before submitting
                            FocusScope.of(context).unfocus();

                            // Dispatch the API event
                            context.read<OrderStatusBloc>().add(
                              UpdateOrderStatusRequested(
                                orderId: widget.orderId,
                                statusType: 2, // Hardcoded per your request
                                sumbitUserId: selectedUser!.id, // Null/Empty placeholder
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: (statusState is OrderStatusLoading)
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                              : Text(
                            "Submit",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}