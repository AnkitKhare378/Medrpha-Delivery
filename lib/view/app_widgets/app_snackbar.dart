import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAppSnackBar(
    BuildContext context,
    String message, {
      Duration duration = const Duration(seconds: 2),
    }) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.blueAccent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      duration: duration,
    ),
  );
}
