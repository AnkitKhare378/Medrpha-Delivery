import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPrivacyText extends StatelessWidget {
  const TermsPrivacyText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: Colors.black87,
        ),
        children: [
          const TextSpan(text: "By signing in, you accept our "),
          TextSpan(
            text: "T&Cs",
            style: const TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Handle T&Cs tap
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("T&Cs tapped")),
                );
              },
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Handle Privacy Policy tap
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Privacy Policy tapped")),
                );
              },
          ),
        ],
      ),
    );
  }
}
