import 'dart:ui';
import 'package:flutter/material.dart';
import '../../location_picker_icon.dart';
import '../../location_picker_theme.dart';

class MyLocationButton extends StatelessWidget {
  final VoidCallback onTap;
  final LocationPickerTheme theme;

  const MyLocationButton({super.key, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = (theme.controlsBackgroundColor ?? theme.cardColor)
        .withValues(alpha: theme.glassmorphism ? 0.85 : 1.0);
    final borderColor =
        isDark
            ? Colors.white.withValues(alpha: 0.12)
            : theme.borderColor.withValues(alpha: 0.4);

    Widget button = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: surfaceColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [theme.fabShadow],
      ),
      child: Center(
        child: LocationPickerIconView(
          icon: theme.myLocationIcon ?? LocationPickerIcon.myLocation,
          color: theme.primaryColor,
          size: 22,
        ),
      ),
    );

    if (theme.glassmorphism) {
      button = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: button,
        ),
      );
    }

    return Positioned(
      bottom: 100,
      right: 20,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: 'My location',
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: button,
          ),
        ),
      ),
    );
  }
}
