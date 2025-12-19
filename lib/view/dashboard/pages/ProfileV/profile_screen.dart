import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medrpha_delivery/config/color/colors.dart';
import 'package:medrpha_delivery/view/account/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/slide_page_route.dart';
import '../HomeV/pages/location_picker_screen.dart';
import 'widgets/profile_menu_widget.dart'; // Assuming this widget is defined elsewhere

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State variables to hold user data
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _companyName = 'Loading...';
  String _baseUrl = 'https://www.online-tech.in/CompanyUserImage/';
  String _userImage = 'assets/images/blood_test.png'; // Default asset fallback
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Guest User';
        _userEmail = prefs.getString('user_email') ?? 'no-email@example.com';
        _companyName = prefs.getString('user_company_name') ?? 'Company name';
        // Check if a user image path/URL is saved
        final savedImage = prefs.getString('user_image');
        if (savedImage != null && savedImage.isNotEmpty) {
          _userImage = savedImage;
        }
        _isLoading = false;
      });
    } catch (e) {
      // Handle potential errors during SharedPreferences access
      print('Error loading user data: $e');
      setState(() {
        _userName = 'Error';
        _userEmail = 'Failed to load data';
        _isLoading = false;
      });
    }
  }

  // Function to show the logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("LOGOUT", style: GoogleFonts.poppins(fontSize: 20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Are you sure, you want to Logout?", style: GoogleFonts.poppins()),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false), // Dismiss dialog
              child: Text("No", style: GoogleFonts.poppins(color: Colors.black87)),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                // Remove all essential user data keys
                await prefs.remove('user_id');
                await prefs.remove('lab_id');
                await prefs.remove('user_name');
                await prefs.remove('user_email');
                // Navigate to Login screen and remove all routes below it
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor, side: BorderSide.none),
              child: Text("Yes", style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
          actionsAlignment: MainAxisAlignment.end,
        );
      },
    );
  }

  // The base part of your network URL


  Widget _buildUserImage(String imagePath) {
    // 1. Construct the full network URL
    String fullNetworkPath = '$_baseUrl$imagePath';

    // 2. Check if the path looks like a network URL.
    // We'll use the full constructed path for the network check,
    // but if the function is meant to handle *both* local assets (by filename)
    // and network images (by filename), the logic below is slightly simplified.

    // Let's assume:
    // - If imagePath starts with 'http' or 'https', it's already a full URL.
    // - Otherwise, we append it to the base URL for the network check.

    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      // Use imagePath directly if it's already a full URL
      fullNetworkPath = imagePath;
    }

    // Since you provided the base URL, let's prioritize the network image logic using the combined path

    return Image.network(
      fullNetworkPath, // Use the full constructed or provided network path
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Fallback to local asset if network image fails
        return const Image(image: AssetImage("assets/images/blood_test.png"), fit: BoxFit.cover);
      },
    );

    // NOTE: I removed the 'else' block for local assets because the initial 'if'
    // check (if (imagePath.startsWith('http') || imagePath.startsWith('https')))
    // is now redundant since we are *always* constructing a network path
    // based on your requirement.

    // If you *must* retain the local asset fallback for non-http paths:
    /*
  // Re-introducing the original logic structure:
  if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
    // ... your original Image.network code ...
  } else {
    // Treat as local asset
    return Image(image: AssetImage(imagePath), fit: BoxFit.cover);
  }
  */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text("Profile",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              /// -- IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _buildUserImage(_userImage),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// -- USER DETAILS
              Text(_userName,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(_userEmail, style: GoogleFonts.poppins()),
              Text(_companyName, style: GoogleFonts.poppins()),
              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: Text("View Profile",
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// -- MENU
              ProfileMenuWidget(
                  title: "View Location",
                  icon: Icons.settings,
                  onPress: () {
                    Navigator.of(context).push(
                      SlidePageRoute(
                        page: const LocationPickerScreen(),
                      ),
                    );
                  }),
              // Removed commented-out widgets for clarity
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                  title: "Information",
                  icon: Icons.info,
                  onPress: () {}),
              ProfileMenuWidget(
                title: "Logout",
                icon: Icons.logout,
                textColor: Colors.red,
                endIcon: false,
                onPress: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}