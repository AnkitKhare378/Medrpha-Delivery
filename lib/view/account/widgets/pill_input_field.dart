// Placeholder for imports and styles assumed to be in the original file context

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PillInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const PillInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          // Remove border visually inside the decoration
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}