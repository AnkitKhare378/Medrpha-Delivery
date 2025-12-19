import 'package:flutter/material.dart';

import 'home_screen.dart';

class DeliveryHomeSystem extends StatelessWidget {
  const DeliveryHomeSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medrpha Delivery',
      theme: ThemeData(
        // Using a similar color scheme to the provided theme snippets
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Starting with the HomeScreen, since it's the focus of the request
      home: const HomeScreen(),
    );
  }
}