import 'package:fatawa/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextFieldOptimized extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool filled;
  final Color? fillColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextFieldOptimized({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.filled = false,
    this.fillColor,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 350;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label.isNotEmpty) ...[
              _CustomTextFieldLabelWidget(label: label),
              SizedBox(height: isNarrow ? 6 : 8),
            ],
            _CustomTextFormFieldInput(
              controller: controller,
              validator: validator,
              onChanged: onChanged,
              isPassword: isPassword,
              keyboardType: keyboardType,
              hint: hint,
              suffixIcon: suffixIcon,
              filled: filled,
              fillColor: fillColor,
              isNarrow: isNarrow,
            ),
          ],
        );
      },
    );
  }
}

class _CustomTextFieldLabelWidget extends StatelessWidget {
  final String label;

  const _CustomTextFieldLabelWidget({required this.label});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 350;

    return Text(
      label,
      style: TextStyle(
        fontSize: isNarrow ? 12 : 14,
        fontWeight: FontWeight.w600,
        color:  AppColors.textLabel,
      ),
    );
  }
}

class _CustomTextFormFieldInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isPassword;
  final TextInputType keyboardType;
  final String hint;
  final Widget? suffixIcon;
  final bool filled;
  final Color? fillColor;
  final bool isNarrow;

  const _CustomTextFormFieldInput({
    required this.controller,
    required this.validator,
    required this.onChanged,
    required this.isPassword,
    required this.keyboardType,
    required this.hint,
    required this.suffixIcon,
    required this.filled,
    required this.fillColor,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: isNarrow ? 14 : 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize: isNarrow ? 12 : 14,
        ),
        filled: filled,
        fillColor: fillColor,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 12 : 16,
          vertical: isNarrow ? 12 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: filled ? Colors.transparent : AppColors.inputBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: filled ? Colors.transparent : AppColors.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
      ),
    );
  }
}
