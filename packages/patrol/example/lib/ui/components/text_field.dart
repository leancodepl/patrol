import 'package:example/ui/style/colors.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:flutter/material.dart';

class PTTextField extends StatelessWidget {
  const PTTextField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: _TextField(
            controller: controller,
            label: label,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: PTTextStyles.label.copyWith(color: PTColors.error),
          ),
        ],
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
  });

  final String label;
  final TextEditingController controller;

  static const _borderColor = Color(0xFF777777);
  static const _fillColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: PTTextStyles.bodyMedium.copyWith(color: PTColors.textWhite),
      cursorColor: PTColors.textWhite,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: PTTextStyles.bodyMedium.copyWith(color: PTColors.textWhite),
        fillColor: _fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        filled: true,
        focusedBorder: _getBorder(PTColors.lcYellow),
        border: _getBorder(_borderColor),
        enabledBorder: _getBorder(_borderColor),
      ),
    );
  }

  OutlineInputBorder _getBorder(Color color) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: color),
      );
}
