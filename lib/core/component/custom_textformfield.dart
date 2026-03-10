// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../style/color/colors_app.dart';
import 'space.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Function(String value)? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool isRequired;
  final double? size;
  final int? maxLines;
  final double? borderRadius;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final String? Function(String?)? validator;
  final VoidCallback? onEditingComplete;
  const CustomTextFormField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.isRequired = false,
    this.size,
    this.maxLines,
    this.borderRadius,
    this.fillColor,
    this.focusedBorderColor,
    this.validator,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label ?? '',
                style: const TextStyle(
                  color: ColorsApp.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isRequired)
                const Text(
                  '*',
                  style: TextStyle(
                    color: ColorsApp.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SpaceHeight(4),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          textInputAction: textInputAction,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            hintText: hintText,
            hintStyle: const TextStyle(color: ColorsApp.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            filled: true,
            fillColor:
                fillColor ?? (readOnly ? Color(0xFFE0E0E0) : ColorsApp.white),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              borderSide: BorderSide(color: ColorsApp.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              borderSide: BorderSide(color: ColorsApp.error, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              borderSide: BorderSide(
                color: focusedBorderColor ?? Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
          ),
          validator: validator,
          onEditingComplete: onEditingComplete,
        ),
      ],
    );
  }
}
