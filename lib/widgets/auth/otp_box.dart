import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petixfy/theme/app_colors.dart';

/// Caja individual para un dígito de un código OTP.
///
/// - Tamaño 54x64 px, esquinas redondeadas y sombra ligera.
/// - Resalta el borde cuando recibe foco.
/// - Soporta borrar con backspace (delegando vía [onBackspace] cuando la caja
///   ya está vacía).
class OtpBox extends StatelessWidget {
  const OtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onBackspace,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBackspace;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final hasFocus = focusNode.hasFocus;
        final hasValue = controller.text.isNotEmpty;

        return Container(
          width: 54,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasFocus
                  ? AppColors.primary
                  : (hasValue
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.borderLight),
              width: hasFocus ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: hasFocus
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.shadowLight.withValues(alpha: 0.4),
                blurRadius: hasFocus ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: KeyboardListener(
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
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
        );
      },
    );
  }
}

/// Fila de cajas OTP que coordina el foco y el borrado entre ellas.
class OtpBoxGroup extends StatefulWidget {
  const OtpBoxGroup({
    super.key,
    this.length = 6,
    required this.controllers,
    required this.focusNodes,
    this.onCompleted,
    this.onChanged,
    this.autofocus = true,
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

  @override
  State<OtpBoxGroup> createState() => _OtpBoxGroupState();
}

class _OtpBoxGroupState extends State<OtpBoxGroup> {
  String get _code =>
      widget.controllers.map((c) => c.text).join();

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) {
        return OtpBox(
          controller: widget.controllers[i],
          focusNode: widget.focusNodes[i],
          autofocus: widget.autofocus && i == 0,
          onChanged: (v) => _handleChanged(i, v),
          onBackspace: () => _handleBackspace(i),
        );
      }),
    );
  }
}
