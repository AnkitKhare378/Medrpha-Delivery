import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PillInputField extends StatefulWidget {
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
  State<PillInputField> createState() => _PillInputFieldState();
}

class _PillInputFieldState extends State<PillInputField> {
  // Local state to track visibility
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Initialize with the value passed from the parent
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText, // Controlled by local state
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          prefixIcon: Icon(widget.icon, color: Colors.grey.shade400, size: 20),

          // Logic for the suffix icon
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade400,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,

          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}