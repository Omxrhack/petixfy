import 'package:flutter/material.dart';
import 'package:petixfy/theme/app_colors.dart';

/// Indicador de progreso animado para onboarding
class AnimatedProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;

  const AnimatedProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? (activeColor ?? Colors.white)
                : (inactiveColor ?? Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(5),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: (activeColor ?? Colors.white).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

/// Barra de progreso lineal animada para formularios
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.progressColor,
    this.backgroundColor,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paso ${currentStep + 1} de $totalSteps',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                color: backgroundColor ?? AppColors.borderLight,
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor ?? AppColors.primary,
                            progressColor?.withOpacity(0.8) ??
                                AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Indicador de pasos con iconos
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<IconData> stepIcons;
  final Color? activeColor;
  final Color? inactiveColor;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.stepIcons,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepIcons.length, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? (activeColor ?? AppColors.primary)
                    : (inactiveColor ?? AppColors.borderLight),
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                stepIcons[index],
                size: 20,
                color: isActive ? Colors.white : AppColors.textTertiary,
              ),
            ),
            if (index < stepIcons.length - 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index < currentStep
                      ? (activeColor ?? AppColors.primary)
                      : (inactiveColor ?? AppColors.borderLight),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      }),
    );
  }
}
