import 'dart:ui';
import 'package:flutter/material.dart';
import '../../location_picker_icon.dart';
import '../../location_picker_theme.dart';

/// Modern floating map action controls containing Zoom In (+), Zoom Out (-),
/// and My Location buttons with responsive styling, tooltips, and hover feedback.
class MapActionControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMyLocation;
  final LocationPickerTheme theme;
  final bool isLocating;
  final bool showZoomControls;
  final bool showMyLocation;

  const MapActionControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMyLocation,
    required this.theme,
    this.isLocating = false,
    this.showZoomControls = true,
    this.showMyLocation = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showZoomControls && !showMyLocation) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = (theme.controlsBackgroundColor ?? theme.cardColor)
        .withValues(alpha: theme.glassmorphism ? 0.82 : 1.0);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : theme.borderColor.withValues(alpha: 0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // --- Zoom In & Out Cluster ---
        if (showZoomControls)
          _FrostedContainer(
          theme: theme,
          borderRadius: BorderRadius.circular(14),
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                tooltip: 'Zoom in',
                icon: LocationPickerIconView(
                  icon: theme.zoomInIcon ??
                      const LocationPickerIcon.icon(Icons.add_rounded, size: 22),
                  color: theme.textDarkColor,
                  size: 22,
                ),
                theme: theme,
                onTap: onZoomIn,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              Container(
                width: 32,
                height: 1,
                color: borderColor,
              ),
              _ActionButton(
                tooltip: 'Zoom out',
                icon: LocationPickerIconView(
                  icon: theme.zoomOutIcon ??
                      const LocationPickerIcon.icon(Icons.remove_rounded, size: 22),
                  color: theme.textDarkColor,
                  size: 22,
                ),
                theme: theme,
                onTap: onZoomOut,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
            ],
          ),
        ),

        if (showZoomControls && showMyLocation)
          const SizedBox(height: 12),

        // --- My Location Button ---
        if (showMyLocation)
          _FrostedContainer(
          theme: theme,
          borderRadius: BorderRadius.circular(14),
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          child: _ActionButton(
            tooltip: 'My location',
            icon: isLocating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: theme.primaryColor,
                    ),
                  )
                : LocationPickerIconView(
                    icon: theme.myLocationIcon ?? LocationPickerIcon.myLocation,
                    color: theme.primaryColor,
                    size: 22,
                  ),
            theme: theme,
            onTap: onMyLocation,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }
}

class _FrostedContainer extends StatelessWidget {
  final LocationPickerTheme theme;
  final BorderRadius borderRadius;
  final Color surfaceColor;
  final Color borderColor;
  final Widget child;

  const _FrostedContainer({
    required this.theme,
    required this.borderRadius,
    required this.surfaceColor,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [theme.fabShadow],
      ),
      child: child,
    );

    if (!theme.glassmorphism) return container;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: container,
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String tooltip;
  final Widget icon;
  final LocationPickerTheme theme;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.theme,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: _isHovered
              ? widget.theme.primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: widget.borderRadius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius,
            splashColor: widget.theme.primaryColor.withValues(alpha: 0.2),
            highlightColor: widget.theme.primaryColor.withValues(alpha: 0.1),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: widget.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
