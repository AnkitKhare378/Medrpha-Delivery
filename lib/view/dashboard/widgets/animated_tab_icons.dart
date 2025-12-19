import 'package:flutter/material.dart';

class AnimatedTabIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const AnimatedTabIcon({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(
        begin: 1.0,
        end: isSelected ? 1.2 : 1.0,
      ),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Icon(
            icon,
            color: isSelected ? Colors.blueAccent : Colors.grey,
          ),
        );
      },
    );
  }
}
