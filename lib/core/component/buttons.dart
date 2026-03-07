import 'package:flutter/material.dart';

import '../style/color/colors_app.dart';

enum ButtonStyle { filled, outlined }

class Button extends StatelessWidget {
  const Button.filled({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyle.filled,
    this.color,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height,
    this.borderRadius,
    this.icon,
    this.iconRight,
    this.disabled = false,
    this.fontSize = 16.0,
    this.borderColor,
    this.loading,
  });

  const Button.outlined({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyle.outlined,
    this.color = ColorsApp.white,
    this.textColor,
    this.width = double.infinity,
    this.height,
    this.borderRadius,
    this.icon,
    this.iconRight,
    this.disabled = false,
    this.fontSize = 16.0,
    this.borderColor,
    this.loading,
  });

  final Function() onPressed;
  final String label;
  final ButtonStyle style;
  final Color? color;
  final Color? textColor;
  final double width;
  final double? height;
  final double? borderRadius;
  final Widget? icon;
  final Widget? iconRight;
  final bool disabled;
  final double fontSize;
  final Color? borderColor;
  final bool? loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 44.0,
      width: width,
      child: style == ButtonStyle.filled
          ? GestureDetector(
              onTap: disabled ? null : onPressed,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
                ),
                child: Row(
                  mainAxisAlignment: iconRight != null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    icon ?? const SizedBox.shrink(),
                    if (icon != null) const SizedBox(width: 10.0),
                    Center(
                      child: loading == true
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: ColorsApp.white,
                              ),
                            )
                          : Text(
                              label,
                              style: TextStyle(
                                color: textColor ?? ColorsApp.primary,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              ))
          : OutlinedButton(
              onPressed: disabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: color,
                side: BorderSide(color: borderColor ?? ColorsApp.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: iconRight != null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  icon ?? const SizedBox.shrink(),
                  if (icon != null) const SizedBox(width: 10.0),
                  Flexible(
                    child: Center(
                      child: loading == true
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: borderColor ?? ColorsApp.primary,
                              ),
                            )
                          : Text(
                              label,
                              style: TextStyle(
                                  color: textColor ?? ColorsApp.primary,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis),
                            ),
                    ),
                  ),
                  iconRight ?? const SizedBox.shrink(),
                  if (iconRight != null) const SizedBox(width: 10.0),
                ],
              ),
            ),
    );
  }
}
