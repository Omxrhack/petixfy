import 'package:flutter/material.dart';
import 'package:petixfy/theme/app_colors.dart';

/// Botón principal para onboarding
class OnboardingPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;

  const OnboardingPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
  });

  @override
  State<OnboardingPrimaryButton> createState() =>
      _OnboardingPrimaryButtonState();
}

class _OnboardingPrimaryButtonState extends State<OnboardingPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildButton(),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      width: widget.expanded ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        gradient: widget.onPressed != null
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: widget.onPressed == null ? AppColors.borderLight : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: widget.onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize:
                        widget.expanded ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.text,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: widget.onPressed != null
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (widget.icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          widget.icon,
                          color: widget.onPressed != null
                              ? Colors.white
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Botón secundario/outline para onboarding
class OnboardingSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconLeading;

  const OnboardingSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.iconLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: onPressed != null
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.borderLight,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && iconLeading) ...[
                  Icon(
                    icon,
                    color: onPressed != null
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPressed != null
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (icon != null && !iconLeading) ...[
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    color: onPressed != null
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de texto para saltar onboarding
class OnboardingSkipButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const OnboardingSkipButton({
    super.key,
    this.text = 'Saltar',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
