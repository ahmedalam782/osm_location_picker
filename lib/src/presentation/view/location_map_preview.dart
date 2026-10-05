import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../location_picker_config.dart';
import '../location_picker_icon.dart';
import '../location_picker_theme.dart';

/// A still map image of a selected location.
///
/// Features adaptive dark/light map tiles, reliable centering, and a prominent
/// pin marker with ground shadow and precision target dot.
class LocationMapPreview extends StatelessWidget {
  /// Selected geographic coordinates shown at the center of the preview.
  final LatLng location;

  /// Visual theme. Inherits from [LocationPickerTheme.of] when null.
  final LocationPickerTheme? theme;

  /// Map tile and caching configuration.
  final LocationPickerConfig config;

  /// Height of the map preview container.
  final double height;

  /// Camera zoom level. Defaults to 16.0 for a balanced neighborhood view.
  final double zoom;

  /// Border radius applied to the preview container.
  final BorderRadius borderRadius;

  const LocationMapPreview({
    super.key,
    required this.location,
    this.theme,
    this.config = const LocationPickerConfig(),
    this.height = 180,
    this.zoom = 16.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTheme = (theme ?? LocationPickerTheme.of(context))
        .forBrightness(isDark ? Brightness.dark : Brightness.light);
    final pin =
        activeTheme.selectedIcon ??
        activeTheme.pinIcon ??
        LocationPickerIcon.pin;
    final pinSize = pin.size ?? 42.0;

    final useDarkTiles = config.useDarkTiles ?? isDark;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- 1. Map Tiles (TileLayer filtered for dark/light mode) ---
            Positioned.fill(
              child: ColorFiltered(
                colorFilter:
                    useDarkTiles
                        ? const ColorFilter.matrix([
                          -0.2126,
                          -0.7152,
                          -0.0722,
                          0,
                          255,
                          -0.2126,
                          -0.7152,
                          -0.0722,
                          0,
                          255,
                          -0.2126,
                          -0.7152,
                          -0.0722,
                          0,
                          255,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ])
                        : const ColorFilter.matrix([
                          1,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                child: FlutterMap(
                  // Key ensures whenever coordinates or zoom change, the map immediately updates
                  key: ValueKey(
                    '${location.latitude}_${location.longitude}_$zoom',
                  ),
                  options: MapOptions(
                    initialCenter: location,
                    initialZoom: zoom,
                    maxZoom: config.maxZoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: config.tileUrlTemplate,
                      fallbackUrl: config.fallbackUrl,
                      userAgentPackageName: config.userAgentPackageName,
                      subdomains: config.tileSubdomains,
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. Center Location Pin (Guaranteed visible, resting on center point) ---
            IgnorePointer(
              child: _StaticMapCenterPin(
                theme: activeTheme,
                pin: pin,
                pinSize: pinSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a precision ground pin resting exactly at the map center.
class _StaticMapCenterPin extends StatelessWidget {
  final LocationPickerTheme theme;
  final LocationPickerIcon pin;
  final double pinSize;

  const _StaticMapCenterPin({
    required this.theme,
    required this.pin,
    required this.pinSize,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Ground ripple / accent ring
        Container(
          width: 24,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.elliptical(24, 10)),
            border: Border.all(
              color: primary.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
        ),

        // Contact shadow directly beneath the tip
        Transform.translate(
          offset: const Offset(0, 1),
          child: Container(
            width: 14,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.elliptical(14, 6)),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),

        // Precision target dot (exact coordinate point)
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),

        // Floating upright pin with its tip resting precisely on the target dot
        Transform.translate(
          offset: Offset(0, -(pinSize / 2) + 1),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: LocationPickerIconView(
              icon: pin,
              color: primary,
              size: pinSize,
            ),
          ),
        ),
      ],
    );
  }
}
