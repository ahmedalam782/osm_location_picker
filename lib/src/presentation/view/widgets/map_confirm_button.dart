import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../location_picker_icon.dart';
import '../../location_picker_theme.dart';

/// A creative, responsive location confirmation dock.
///
/// Adapts gracefully to all screen sizes (mobile, tablet, desktop, web),
/// featuring frosted glassmorphism, coordinates pill with copy action,
/// and a vibrant animated action button.
class MapConfirmButton extends StatefulWidget {
  final VoidCallback onTap;
  final String title;
  final LocationPickerTheme theme;
  final LatLng? coordinates;
  final bool isLoading;

  const MapConfirmButton({
    super.key,
    required this.onTap,
    required this.title,
    required this.theme,
    this.coordinates,
    this.isLoading = false,
  });

  @override
  State<MapConfirmButton> createState() => _MapConfirmButtonState();
}

class _MapConfirmButtonState extends State<MapConfirmButton> {
  bool _isHovered = false;
  bool _copied = false;

  void _copyCoordinates() {
    if (widget.coordinates == null) return;
    final text =
        '${widget.coordinates!.latitude.toStringAsFixed(6)}, ${widget.coordinates!.longitude.toStringAsFixed(6)}';
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor;
    final darkerPrimary = Color.lerp(primary, Colors.black, 0.20) ?? primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient =
        widget.theme.accentGradient ??
        LinearGradient(
          colors: [primary, darkerPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final radius = BorderRadius.circular(widget.theme.borderRadius);

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Optional Coordinates Chip with Copy Feedback ---
                if (widget.coordinates != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _CoordinatesBadge(
                      coordinates: widget.coordinates!,
                      theme: widget.theme,
                      isDark: isDark,
                      copied: _copied,
                      onTap: _copyCoordinates,
                    ),
                  ),

                // --- Action Button ---
                MouseRegion(
                  cursor:
                      widget.isLoading
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    height: 52,
                    transform: Matrix4.translationValues(
                      0,
                      _isHovered && !widget.isLoading ? -2 : 0,
                      0,
                    ),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(
                            alpha: _isHovered ? 0.45 : 0.28,
                          ),
                          blurRadius: _isHovered ? 18 : 12,
                          offset: Offset(0, _isHovered ? 6 : 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.isLoading ? null : widget.onTap,
                        borderRadius: radius,
                        splashColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.1),
                        child: Center(
                          child:
                              widget.isLoading
                                  ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: widget.theme.textLightColor,
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LocationPickerIconView(
                                        icon:
                                            widget.theme.confirmIcon ??
                                            const LocationPickerIcon.icon(
                                              Icons.check_circle_rounded,
                                              size: 20,
                                            ),
                                        color: widget.theme.textLightColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: widget.theme.textLightColor,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoordinatesBadge extends StatelessWidget {
  final LatLng coordinates;
  final LocationPickerTheme theme;
  final bool isDark;
  final bool copied;
  final VoidCallback onTap;

  const _CoordinatesBadge({
    required this.coordinates,
    required this.theme,
    required this.isDark,
    required this.copied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lat = coordinates.latitude.toStringAsFixed(5);
    final lng = coordinates.longitude.toStringAsFixed(5);
    final label = '$lat, $lng';

    final surfaceColor = theme.cardColor.withValues(
      alpha: theme.glassmorphism ? 0.85 : 1.0,
    );
    final borderColor =
        isDark
            ? Colors.white.withValues(alpha: 0.12)
            : theme.borderColor.withValues(alpha: 0.35);

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            copied ? Icons.check_rounded : Icons.my_location_rounded,
            size: 14,
            color: copied ? Colors.green : theme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            copied ? 'Coordinates Copied!' : label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textDarkColor.withValues(alpha: 0.8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (theme.glassmorphism) {
      chip = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: chip,
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: 'Click to copy coordinates',
        child: GestureDetector(onTap: onTap, child: chip),
      ),
    );
  }
}
