import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SlotCardShimmer extends StatelessWidget {
  const SlotCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shimmer for Date Picker bar
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 15),
              // Shimmer for "Available Slots" title
              Row(
                children: [
                  Container(height: 22, width: 22, color: Colors.white),
                  const SizedBox(width: 10),
                  Container(height: 18, width: 120, color: Colors.white),
                ],
              ),
              const SizedBox(height: 15),
              // Shimmer for Slot Grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(6, (index) => Container(
                  height: 35,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}