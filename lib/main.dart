// file: main.dart

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medrpha_delivery/data/repositories/order_service/get_user_by_lab_service.dart';
import 'package:medrpha_delivery/data/repositories/order_service/get_user_inventory_service.dart';
import 'package:medrpha_delivery/data/repositories/order_service/order_start_service.dart';
import 'package:medrpha_delivery/data/repositories/order_service/order_status_service.dart';
import 'package:medrpha_delivery/data/repositories/order_service/store_shift_service.dart';
import 'package:medrpha_delivery/view_models/OrderVM/get_order_view_model.dart';
import 'package:medrpha_delivery/view_models/OrderVM/inventory_bloc.dart';
import 'package:medrpha_delivery/view_models/OrderVM/order_start_bloc.dart';
import 'package:medrpha_delivery/view_models/OrderVM/order_status_view_model.dart';
import 'package:medrpha_delivery/view_models/OrderVM/store_shift_view_model.dart';
import 'package:medrpha_delivery/view_models/OrderVM/user_selection_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/firebase_options.dart';
import 'config/routes/routes.dart';
import 'config/routes/routes_name.dart';
import 'core/network/custom_http_overrides.dart';
import 'data/repositories/order_service/order_history_service.dart';
import 'view_models/AccountVM/company_login_view_model.dart';
import 'view_models/DashboardVM/bloc/dashboard_bloc.dart';
import 'view_models/DashboardVM/bloc/dashboard_event.dart';
import 'view_models/OrderVM/order_history_view_model.dart';

const String _kFirstTimeKey = 'is_first_time';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late String startRoute;
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  final isFirstTime = prefs.getBool(_kFirstTimeKey) ?? true;

  if (isFirstTime) {
    startRoute = RoutesName.splashScreen;
    await prefs.setBool(_kFirstTimeKey, false);
  } else if (userId != null) {
    startRoute = RoutesName.dashboardScreen;
  } else {
    startRoute = RoutesName.loginScreen;
  }

  HttpOverrides.global = CustomHttpOverrides();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } catch (e) {
    debugPrint('🔥 Firebase initialization error: $e');
  }

  // 🎯 FIX: Wrap the entire app with a MultiRepositoryProvider 
  // to make the services available globally.
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<OrderHistoryService>(
          create: (_) => OrderHistoryService(),
        ),
        RepositoryProvider<OrderStatusService>(
          create: (_) => OrderStatusService(),
        ),
        RepositoryProvider<OrderStartService>(
          create: (_) => OrderStartService(),
        ),
        RepositoryProvider<InventoryService>(
          create: (_) => InventoryService(),
        ),
        RepositoryProvider<GetUserByLabService>(
          create: (_) => GetUserByLabService(),
        ),
        RepositoryProvider<StoreShiftService>(
          create: (_) => StoreShiftService(),
        ),
      ],
      child: MyApp(initialRoute: startRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardBloc()..add(DashboardShowLabsDialog())),
        BlocProvider(create: (_) => CompanyLoginBloc()),
        BlocProvider(create: (_) => GetOrderBloc()),
        BlocProvider<OrderHistoryBloc>(create: (context) => OrderHistoryBloc(context.read<OrderHistoryService>(),),),
        BlocProvider<OrderStatusBloc>(create: (context) => OrderStatusBloc(context.read<OrderStatusService>(),),),
        BlocProvider<OrderStartBloc>(create: (context) => OrderStartBloc(context.read<OrderStartService>(),),),
        BlocProvider<OrderEndBloc>(create: (context) => OrderEndBloc(context.read<OrderStartService>(),),),
        BlocProvider<InventoryBloc>(create: (context) => InventoryBloc(context.read<InventoryService>(),),),
        BlocProvider<UserSelectionBloc>(create: (context) => UserSelectionBloc(context.read<GetUserByLabService>(),),),
        BlocProvider<StoreShiftBloc>(create: (context) => StoreShiftBloc(context.read<StoreShiftService>(),),),
      ],
      child: MaterialApp(
        title: 'Medrpha Delivery',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: initialRoute,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}