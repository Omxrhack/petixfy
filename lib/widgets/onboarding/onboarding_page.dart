import 'package:flutter/material.dart';
import 'package:petixfy/theme/app_colors.dart';

/// Contenedor de página para onboarding con animaciones
class OnboardingPage extends StatelessWidget {
  final Widget child;
  final bool useGradient;
  final Color? backgroundColor;

  const OnboardingPage({
    super.key,
    required this.child,
    this.useGradient = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: useGradient ? AppColors.splashGradient : null,
        color: useGradient ? null : (backgroundColor ?? AppColors.backgroundLight),
      ),
      child: SafeArea(child: child),
    );
  }
}

/// Widget para contenido de slide con animaciones
class OnboardingSlideContent extends StatelessWidget {
  final String title;
  final String description;
  final Widget illustration;
  final Animation<double> animation;

  const OnboardingSlideContent({
    super.key,
    required this.title,
    required this.description,
    required this.illustration,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        _buildIllustration(),
        const SizedBox(height: 48),
        _buildTitle(context),
        const SizedBox(height: 16),
        _buildDescription(context),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildIllustration() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        )),
        child: illustration,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
          ),
        ),
      ),
    );
  }
}
