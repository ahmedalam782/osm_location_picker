import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../location_picker_icon.dart';
import '../../location_picker_theme.dart';

/// A creative, animated map center pin with ground ripples,
/// dynamic 3D lift physics, and soft contact shadows.
class MapCenterMarker extends StatefulWidget {
  final bool isMoving;
  final bool isLoading;
  final LocationPickerTheme theme;

  const MapCenterMarker({
    super.key,
    required this.isMoving,
    required this.isLoading,
    required this.theme,
  });

  @override
  State<MapCenterMarker> createState() => _MapCenterMarkerState();
}

class _MapCenterMarkerState extends State<MapCenterMarker>
    with TickerProviderStateMixin {
  /// Controls the pin lift & drop animation.
  late final AnimationController _liftController;
  late final Animation<double> _liftAnimation;

  /// Controls the idle pulsing radar / ripple on the ground.
  late final AnimationController _rippleController;

  @override
  void initState() {
    super.initState();

    _liftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _liftAnimation = CurvedAnimation(
      parent: _liftController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.bounceOut,
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    if (widget.isMoving) {
      _liftController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MapCenterMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      if (!_liftController.isAnimating) {
        _liftController.repeat(reverse: true);
      }
      return;
    }

    if (widget.isMoving != oldWidget.isMoving) {
      if (widget.isMoving) {
        _liftController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      } else {
        _liftController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 380),
          curve: Curves.bounceOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _liftController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_liftAnimation, _rippleController]),
        builder: (context, _) {
          final lift = _liftAnimation.value;
          final rippleProgress = _rippleController.value;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // --- Ground Pulse Waves (Visible when resting) ---
              if (lift < 0.6)
                Transform.translate(
                  offset: const Offset(0, 0),
                  child: Opacity(
                    opacity: (1.0 - lift) * (1.0 - rippleProgress),
                    child: Container(
                      width: 24 + (38 * rippleProgress),
                      height: 10 + (16 * rippleProgress),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(
                            24 + (38 * rippleProgress),
                            10 + (16 * rippleProgress),
                          ),
                        ),
                        border: Border.all(
                          color: primaryColor.withValues(
                            alpha: math.max(0.0, 0.45 * (1.0 - rippleProgress)),
                          ),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

              // --- Dynamic Ground Contact Shadow ---
              Transform.translate(
                offset: const Offset(0, 1),
                child: Container(
                  width: math.max(8.0, 16.0 - (4.0 * lift)),
                  height: math.max(4.0, 7.0 - (2.0 * lift)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(
                        math.max(8.0, 16.0 - (4.0 * lift)),
                        math.max(4.0, 7.0 - (2.0 * lift)),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : primaryColor).withValues(
                          alpha: isDark
                              ? 0.55 * (1.0 - (0.4 * lift))
                              : 0.35 * (1.0 - (0.4 * lift)),
                        ),
                        blurRadius: 6.0 + (10.0 * lift),
                        spreadRadius: 1.0 + (2.0 * lift),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Center Target Dot (Exact map coordinate point) ---
              Transform.translate(
                offset: const Offset(0, 0),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),

              // --- Animated Floating Pin ---
              // The tip of the pin rests at the origin (offset 0,0) when lift is 0.
              Transform.translate(
                offset: Offset(0, -26 - (28 * lift)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glow effect around the pin marker
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(
                              alpha: 0.25 + (0.15 * lift),
                            ),
                            blurRadius: 16 + (8 * lift),
                            spreadRadius: 2 + (2 * lift),
                          ),
                        ],
                      ),
                      child: LocationPickerIconView(
                        icon: widget.theme.pinIcon ?? LocationPickerIcon.pin,
                        color: primaryColor,
                        size: 46,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
