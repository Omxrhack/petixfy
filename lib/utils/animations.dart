import 'package:flutter/material.dart';

/// Sistema de animaciones consistente para toda la app
class AppAnimations {
  AppAnimations._();

  // ============================================
  // DURACIONES
  // ============================================
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 700);

  // ============================================
  // CURVES
  // ============================================
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutQuad;
  static const Curve sharp = Curves.easeOutExpo;

  // ============================================
  // DELAYS PARA ANIMACIONES EN CADENA
  // ============================================
  static const Duration staggerDelay = Duration(milliseconds: 100);
  static const Duration shortDelay = Duration(milliseconds: 50);

  /// Fade In con delay opcional
  static Widget fadeIn({
    required Widget child,
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? medium,
      curve: curve ?? easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: delay != null
          ? FutureBuilder(
              future: Future.delayed(delay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return child;
                }
                return Opacity(opacity: 0.0, child: child);
              },
            )
          : child,
    );
  }

  /// Slide In desde una dirección con fade
  static Widget slideIn({
    required Widget child,
    Offset from = const Offset(0, 0.3),
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? medium,
      curve: curve ?? easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            from.dx * (1 - value) * 100,
            from.dy * (1 - value) * 100,
          ),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: delay != null
          ? FutureBuilder(
              future: Future.delayed(delay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return child;
                }
                return Opacity(opacity: 0.0, child: child);
              },
            )
          : child,
    );
  }

  /// Scale In con fade
  static Widget scaleIn({
    required Widget child,
    double from = 0.8,
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? medium,
      curve: curve ?? bounce,
      builder: (context, value, child) {
        final scale = from + (1 - from) * value;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: delay != null
          ? FutureBuilder(
              future: Future.delayed(delay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return child;
                }
                return Opacity(opacity: 0.0, child: child);
              },
            )
          : child,
    );
  }
}

/// Widget que anima shake (sacudida) - útil para errores
class ShakeAnimation extends StatefulWidget {
  const ShakeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 8.0,
    this.trigger = false,
  });

  final Widget child;
  final Duration duration;
  final double offset;
  final bool trigger;

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * widget.offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Widget para animación de loading dots
class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    this.color = Colors.white,
    this.size = 8.0,
  });

  final Color color;
  final double size;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * (1 - (value - 0.5).abs() * 2));
            
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Widget para pulso continuo (usado en campos activos)
class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    super.key,
    required this.child,
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.duration = const Duration(milliseconds: 1000),
  });

  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
