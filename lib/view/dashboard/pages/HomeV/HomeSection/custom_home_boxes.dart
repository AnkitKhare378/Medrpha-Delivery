import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomHomeBoxes extends StatelessWidget {
  const CustomHomeBoxes({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> boxData = [
      {
        'label': 'Test',
        'image': 'assets/images/blood_test.png',
        'color': Colors.blue.shade50,
      },
      {
        'label': 'Report',
        'image': 'assets/images/img.png',
        'color': Colors.green.shade50,
      },
      {
        'label': 'Book',
        'image': 'assets/images/img.png',
        'color': Colors.orange.shade50,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(boxData.length, (index) {
        final box = boxData[index];
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 120,
            decoration: BoxDecoration(
              color: box['color'],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      box['image'],
                      height: 70,
                      width: 70,
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Upto 60% off',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  box['label'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
