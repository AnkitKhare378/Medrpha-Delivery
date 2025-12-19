import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:medrpha_delivery/view/dashboard/pages/ProfileV/profile_screen.dart';
import '../../core/services/navigation_service.dart';
import '../../view_models/DashboardVM/bloc/dashboard_bloc.dart';
import '../../view_models/DashboardVM/bloc/dashboard_event.dart';
import '../../view_models/DashboardVM/bloc/dashboard_state.dart';
import 'pages/HomeV/home_screen.dart';
import 'pages/LabTestV/lab_test_screen.dart';
import 'widgets/animated_tab_icons.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({this.initialIndex = 0, super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;
  final int _labVersion = 0;
  final Key _homeKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(DashboardTabChanged(_selectedIndex));
    });

    final notificationService = NotificationService();

    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // handle if needed
    });

    // Background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Your UI is driven by bloc's state.currentIndex, so drive the bloc:
    context.read<DashboardBloc>().add( DashboardTabChanged(1));
    setState(() {
      _selectedIndex = 1;
    });
  }


  // Build current tab on demand (no cached const list)
  Widget _buildCurrentTab(int index) {
    switch (index) {
      case 0:
      // KeyedSubtree guarantees a remount of the entire Home tab subtree when _homeKey changes.
        return KeyedSubtree(
          key: _homeKey,
          child: const HomeScreen(),
        );
      case 1:
        return LabTestScreen();
      case 2:
        return ProfileScreen();
      // case 3:
      //   return const HomeScreen();
      // case 4:
      //   return const HomeScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) =>
      previous.showLabsDialog != current.showLabsDialog &&
          current.showLabsDialog,
      listener: (context, state) async {
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              // Rebuilds correct tab each time; Home tab remounts when _homeKey changes.
              child: _buildCurrentTab(state.currentIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.blue.shade50,
              currentIndex: state.currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w600),
              unselectedLabelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w400),
              onTap: (index) {
                context.read<DashboardBloc>().add(DashboardTabChanged(index));
              },
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedTabIcon(
                    icon: CupertinoIcons.house,
                    isSelected: state.currentIndex == 0,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: AnimatedTabIcon(
                    icon: Iconsax.health,
                    isSelected: state.currentIndex == 1,
                  ),
                  label: "Lab Test",
                ),
                BottomNavigationBarItem(
                  icon: AnimatedTabIcon(
                    icon: Iconsax.user,
                    isSelected: state.currentIndex == 2,
                  ),
                  label: "Profile",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


