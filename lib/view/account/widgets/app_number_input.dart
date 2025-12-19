import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppContactInput extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const AppContactInput({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  State<AppContactInput> createState() => _AppContactInputState();
}

class _AppContactInputState extends State<AppContactInput> {
  bool isPhone = false; // 👈 default is email

  void _updateInputType(String value) {
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(value);
    setState(() {
      isPhone = isNumeric && value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType:
      isPhone ? TextInputType.phone : TextInputType.emailAddress,
      onChanged: (value) {
        _updateInputType(value);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Form.of(context)?.validate(); // live validation
        });
      },
      validator: widget.validator,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: isPhone
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            Image.asset('assets/images/flag.png', height: 24, width: 24),
            const SizedBox(width: 6),
            Text(
              "+91",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 28,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
          ],
        )
            : const Icon(Icons.email_outlined, color: Colors.grey),
        hintText: isPhone ? "Enter phone number" : "Enter email address or phone number", // 👈 default email
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
