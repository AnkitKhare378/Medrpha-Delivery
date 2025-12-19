import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoDataFoundScreen extends StatelessWidget {
  const NoDataFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/no_data_found.png', height: 150,),
                const SizedBox(height: 16),
                Text('Result Not Found',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('This info is not available',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center),
                SizedBox(height: 150,)
              ],
            ),
          ),
        )
    );
  }
}
