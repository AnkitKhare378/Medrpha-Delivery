import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medrpha_labs/views/signup/signup_screen.dart';
import '../../Dashboard/widgets/slide_page_route.dart';

class SignUpTextSpan extends StatelessWidget {
  const SignUpTextSpan({super.key});

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
          const TextSpan(text: "Don't have an account? "),
          TextSpan(
            text: "Sign Up",
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).push(
                  SlidePageRoute(
                    page: SignUpScreen(),
                  ),
                );
              },
          ),
        ],
      ),
    );
  }
}
