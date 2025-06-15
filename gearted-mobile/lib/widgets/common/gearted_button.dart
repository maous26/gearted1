import 'package:flutter/material.dart';

enum GeartedButtonType {
  primary,
  secondary,
  accent,
  outline,
  ghost,
}

class GeartedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final GeartedButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Size? size;

  const GeartedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = GeartedButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    Color? borderColor;
    
    switch (type) {
      case GeartedButtonType.primary:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        borderColor = null;
        break;
      case GeartedButtonType.secondary:
        backgroundColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        borderColor = null;
        break;
      case GeartedButtonType.accent:
        backgroundColor = colorScheme.tertiary;
        textColor = colorScheme.onTertiary;
        borderColor = null;
        break;
      case GeartedButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = colorScheme.primary;
        break;
      case GeartedButtonType.ghost:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.onBackground;
        borderColor = null;
        break;
    }
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: size?.height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          disabledForegroundColor: textColor.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
