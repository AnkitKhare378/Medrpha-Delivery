import 'package:flutter/material.dart';

import '../../view/account/login_screen.dart';
import '../../view/dashboard/dashboard_screen.dart';
import '../../view/splash_screen.dart';
import 'routes_name.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RoutesName.loginScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());

    //   case RoutesName.otpScreen:
    //     final phone = settings.arguments as String? ?? '';
    //     return MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: phone));
    //
      case RoutesName.dashboardScreen:
        return MaterialPageRoute(builder: (_) => DashboardScreen());

    // // ✅ NEW: cart page
    //   case RoutesName.cartScreen:
    //     return MaterialPageRoute(builder: (_) => const MyCartPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route found for this screen')),
          ),
        );
    }
  }
}
