import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petixfy/theme/app_colors.dart';
import 'package:petixfy/utils/animations.dart';

/// Caja individual para un dígito de un código OTP.
///
/// - Por defecto 54x64 px, esquinas redondeadas y sombra ligera.
/// - Resalta el borde cuando recibe foco.
/// - Soporta borrar con backspace (delegando vía [onBackspace] cuando la caja
///   ya está vacía).
/// - Animaciones de scale al recibir focus y success state.
class OtpBox extends StatelessWidget {
  const OtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onBackspace,
    this.onSubmitted,
    this.autofocus = false,
    this.width = 54,
    this.height = 64,
    this.fontSize = 24,
    this.showSuccess = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBackspace;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final double width;
  final double height;
  final double fontSize;
  final bool showSuccess;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final hasFocus = focusNode.hasFocus;
        final hasValue = controller.text.isNotEmpty;

        Widget box = AnimatedContainer(
          duration: AppAnimations.fast,
          curve: AppAnimations.easeInOut,
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: showSuccess ? AppColors.successLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: showSuccess
                  ? AppColors.success
                  : hasFocus
                      ? AppColors.primary
                      : (hasValue
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.borderLight),
              width: hasFocus || showSuccess ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: showSuccess
                    ? AppColors.success.withValues(alpha: 0.18)
                    : hasFocus
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : AppColors.shadowLight.withValues(alpha: 0.4),
                blurRadius: hasFocus || showSuccess ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              KeyboardListener(
                focusNode: FocusNode(skipTraversal: true),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      controller.text.isEmpty) {
                    onBackspace?.call();
                  }
                },
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  cursorColor: AppColors.primary,
                  style: TextStyle(
                    color: showSuccess
                        ? AppColors.success
                        : AppColors.textPrimary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              ),
              if (showSuccess && hasValue)
                AnimatedOpacity(
                  duration: AppAnimations.medium,
                  opacity: 1.0,
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
            ],
          ),
        );

        if (hasFocus && !showSuccess) {
          box = PulseAnimation(
            minScale: 0.98,
            maxScale: 1.02,
            duration: const Duration(milliseconds: 1500),
            child: box,
          );
        }

        return AnimatedScale(
          scale: hasFocus ? 1.05 : 1.0,
          duration: AppAnimations.fast,
          curve: AppAnimations.easeInOut,
          child: box,
        );
      },
    );
  }
}

/// Fila de cajas OTP que coordina el foco y el borrado entre ellas.
/// Calcula automáticamente el ancho de cada caja según el espacio disponible
/// para que tanto 6 como 8 dígitos se vean bien en cualquier pantalla.
class OtpBoxGroup extends StatefulWidget {
  const OtpBoxGroup({
    super.key,
    this.length = 6,
    required this.controllers,
    required this.focusNodes,
    this.onCompleted,
    this.onChanged,
    this.autofocus = true,
    this.showSuccess = false,
  });

  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  /// Se invoca cuando el usuario llenó todos los dígitos.
  final ValueChanged<String>? onCompleted;

  /// Se invoca cada vez que cambia el contenido de cualquier caja, con el
  /// código actual concatenado.
  final ValueChanged<String>? onChanged;

  final bool autofocus;
  final bool showSuccess;

  @override
  State<OtpBoxGroup> createState() => _OtpBoxGroupState();
}

class _OtpBoxGroupState extends State<OtpBoxGroup> {
  String get _code => widget.controllers.map((c) => c.text).join();

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      widget.controllers[index].text = value.substring(value.length - 1);
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      widget.focusNodes[index + 1].requestFocus();
    }

    setState(() {});
    widget.onChanged?.call(_code);

    if (_code.length == widget.length &&
        !_code.contains(RegExp(r'\s')) &&
        !_code.split('').any((d) => d.isEmpty)) {
      widget.onCompleted?.call(_code);
    }
  }

  void _handleBackspace(int index) {
    if (index > 0) {
      widget.focusNodes[index - 1].requestFocus();
      widget.controllers[index - 1].clear();
      setState(() {});
      widget.onChanged?.call(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minSpacing = 6.0;
        const maxBoxWidth = 54.0;
        const minBoxWidth = 36.0;

        // Ancho disponible para cajas (descontando los gaps mínimos).
        final available =
            constraints.maxWidth - minSpacing * (widget.length - 1);
        double boxWidth = (available / widget.length).clamp(
          minBoxWidth,
          maxBoxWidth,
        );

        // Alto y tamaño de fuente proporcionales al ancho elegido.
        final boxHeight = boxWidth * (64 / 54);
        final fontSize = boxWidth * (24 / 54);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (i) {
            return AppAnimations.scaleIn(
              delay: Duration(milliseconds: 300 + (i * 50)),
              from: 0.5,
              child: OtpBox(
                controller: widget.controllers[i],
                focusNode: widget.focusNodes[i],
                autofocus: widget.autofocus && i == 0,
                width: boxWidth,
                height: boxHeight,
                fontSize: fontSize,
                showSuccess: widget.showSuccess,
                onChanged: (v) => _handleChanged(i, v),
                onBackspace: () => _handleBackspace(i),
              ),
            );
          }),
        );
      },
    );
  }
}
