import 'package:flutter/material.dart';
import 'package:petixfy/theme/app_colors.dart';
import 'package:petixfy/widgets/onboarding/animated_builder.dart';

/// Widget para ilustraciones animadas del onboarding
class OnboardingIllustration extends StatefulWidget {
  final String imagePath;
  final double size;
  final bool enableFloating;

  const OnboardingIllustration({
    super.key,
    required this.imagePath,
    this.size = 280,
    this.enableFloating = true,
  });

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    if (widget.enableFloating) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.enableFloating ? _floatAnimation.value : 0),
          child: _buildIllustrationContainer(),
        );
      },
    );
  }

  Widget _buildIllustrationContainer() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.pets,
                size: widget.size * 0.5,
                color: Colors.white.withOpacity(0.5),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget de ilustración con icono para cuando no hay imagen
class OnboardingIconIllustration extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enableFloating;

  const OnboardingIconIllustration({
    super.key,
    required this.icon,
    this.size = 200,
    this.iconColor,
    this.backgroundColor,
    this.enableFloating = true,
  });

  @override
  State<OnboardingIconIllustration> createState() =>
      _OnboardingIconIllustrationState();
}

class _OnboardingIconIllustrationState extends State<OnboardingIconIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    if (widget.enableFloating) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.enableFloating ? _floatAnimation.value : 0),
          child: _buildContainer(),
        );
      },
    );
  }

  Widget _buildContainer() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        size: widget.size * 0.45,
        color: widget.iconColor ?? Colors.white,
      ),
    );
  }
}

