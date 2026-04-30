import 'package:flutter/material.dart';
import 'package:petixfy/utils/animations.dart';

/// Widget reutilizable para ilustraciones animadas en pantallas de auth
class AnimatedIllustration extends StatelessWidget {
  const AnimatedIllustration({
    super.key,
    required this.imagePath,
    this.height = 120,
    this.delay,
  });

  final String imagePath;
  final double height;
  final Duration? delay;

  @override
  Widget build(BuildContext context) {
    return AppAnimations.scaleIn(
      delay: delay ?? const Duration(milliseconds: 300),
      duration: AppAnimations.slow,
      from: 0.7,
      child: Center(
        child: Image.asset(
          imagePath,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
