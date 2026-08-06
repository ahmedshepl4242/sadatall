import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !enabled || isLoading || onPressed == null;

    Widget buildLoadingIndicator() {
      return LoadingAnimationWidget.staggeredDotsWave(
        color: type == ButtonType.primary ? Colors.white : theme.primaryColor,
        size: 20,
      );
    }

    Widget buildButtonContent() {
      if (isLoading) {
        return buildLoadingIndicator();
      }

      final List<Widget> children = [];
      
      if (icon != null) {
        children.add(Icon(icon, size: 18));
        if (text.isNotEmpty) {
          children.add(const SizedBox(width: 8));
        }
      }
      
      if (text.isNotEmpty) {
        children.add(
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: fontWeight ?? FontWeight.w600,
            ),
          ),
        );
      }

      return children.length == 1
          ? children.first
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            );
    }

    Widget buildButton() {
      switch (type) {
        case ButtonType.primary:
          return ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, height ?? 48),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: buildButtonContent(),
          );

        case ButtonType.secondary:
          return ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              minimumSize: Size(width ?? double.infinity, height ?? 48),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: buildButtonContent(),
          );

        case ButtonType.outline:
          return OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, height ?? 48),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: buildButtonContent(),
          );

        case ButtonType.text:
          return TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              minimumSize: Size(width ?? 0, height ?? 48),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: buildButtonContent(),
          );
      }
    }

    return buildButton();
  }
}