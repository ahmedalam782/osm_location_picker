import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/place_search.dart';
import '../../view_model/location_picker_notifier.dart';
import '../../view_model/location_picker_state.dart';
import '../../../models/location_model.dart';
import '../../location_picker_config.dart';
import '../../location_picker_theme.dart';
import '../../location_picker_strings.dart';
import 'location_picker_error_widget.dart';
import 'map_action_controls.dart';
import 'map_address_header.dart';
import 'map_center_marker.dart';
import 'map_confirm_button.dart';

class LocationPickerBody extends StatefulWidget {
  final LocationPickerNotifier notifier;
  final LocationPickerTheme theme;
  final LocationPickerStrings strings;
  final LocationPickerConfig config;
  final PlaceSearch placeSearch;

  /// Called when the user confirms, instead of closing a route.
  ///
  /// The full-screen page leaves this null and pops the route.
  final ValueChanged<LocationModel>? onConfirmed;

  const LocationPickerBody({
    super.key,
    required this.notifier,
    required this.theme,
    required this.strings,
    required this.config,
    required this.placeSearch,
    this.onConfirmed,
  });

  @override
  State<LocationPickerBody> createState() => _LocationPickerBodyState();
}

class _LocationPickerBodyState extends State<LocationPickerBody>
    with TickerProviderStateMixin {
  late final MapController _mapController;

  LocationPickerNotifier get _notifier => widget.notifier;
  LocationPickerState? _listenedState;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _notifier.addListener(_onPickerStateChanged);
  }

  AnimationController? _moveAnimationController;

  @override
  void dispose() {
    _notifier.removeListener(_onPickerStateChanged);
    _moveAnimationController?.stop();
    _moveAnimationController?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onPickerStateChanged() {
    final state = _notifier.value;
    final previous = _listenedState;
    _listenedState = state;
    final shouldListen =
        previous == null ||
        previous.addressData.state != state.addressData.state ||
        previous.position != state.position ||
        previous.shouldMoveToPosition != state.shouldMoveToPosition;
    if (!shouldListen) return;
    if (state.shouldMoveToPosition && state.position != null) {
      _animatedMapMove(state.position!, widget.config.initialZoom);
      _notifier.updateShouldMoveToPosition(false);
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    try {
      _moveAnimationController?.stop();
      _moveAnimationController?.dispose();

      final camera = _mapController.camera;

      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _moveAnimationController = controller;

      final latTween = Tween<double>(
        begin: camera.center.latitude,
        end: destLocation.latitude,
      );
      final lngTween = Tween<double>(
        begin: camera.center.longitude,
        end: destLocation.longitude,
      );
      final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
      );

      controller.addListener(() {
        if (mounted) {
          _mapController.move(
            LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
            zoomTween.evaluate(animation),
          );
        }
      });

      controller.forward().then((_) {
        if (_moveAnimationController == controller) {
          controller.dispose();
          _moveAnimationController = null;
        }
      });
    } catch (_) {
      // Map is not ready yet.
    }
  }

  void _zoomIn() {
    try {
      final camera = _mapController.camera;
      final newZoom = (camera.zoom + 1).clamp(1.0, widget.config.maxZoom);
      _animatedMapMove(camera.center, newZoom);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final camera = _mapController.camera;
      final newZoom = (camera.zoom - 1).clamp(1.0, widget.config.maxZoom);
      _animatedMapMove(camera.center, newZoom);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialState = _notifier.value;
    final initialMapCenter =
        initialState.position ??
        initialState.currentCenter ??
        widget.config.fallbackCenter;

    return ValueListenableBuilder<LocationPickerState>(
      valueListenable: _notifier,
      builder: (context, state, map) {
        final hasPosition = state.position != null;
        final addressLoading =
            state.addressData.state == StatusState.loading ||
            state.addressData.state == StatusState.initial;

        final addressText =
            (state.addressData.state == StatusState.loading ||
                    state.isMoving ||
                    state.addressData.state == StatusState.initial)
                ? widget.strings.fetchingLocation
                : (state.addressData.state == StatusState.failure)
                ? widget.strings.searchHint
                : (state.addressData.data != null &&
                    state.addressData.data!.isNotEmpty)
                ? state.addressData.data!
                : widget.strings.unknownLocation;

        return Stack(
          children: [
            map!,

            // Floating Map Controls (Zoom +, Zoom -, My Location)
            Positioned(
              right: 16,
              bottom: widget.config.showConfirmButton ? 120 : 32,
              child: MapActionControls(
                theme: widget.theme,
                onZoomIn: _zoomIn,
                onZoomOut: _zoomOut,
                onMyLocation: () => _notifier.getCurrentLocation(),
                isLocating: addressLoading && state.position == null,
                showZoomControls: widget.config.showZoomControls,
                showMyLocation: widget.config.showMyLocationButton,
              ),
            ),

            // Center Pin Marker (Always visible at map center, ignore pointer so map drags freely)
            IgnorePointer(
              child: MapCenterMarker(
                isMoving: state.isMoving,
                isLoading: false,
                theme: widget.theme,
              ),
            ),

            // Address Header (Visible if showAddressHeader is true)
            if (widget.config.showAddressHeader)
              MapAddressHeader(
                addressText: addressText,
                theme: widget.theme,
                strings: widget.strings,
                placeSearch: widget.placeSearch,
                near: state.currentCenter ?? state.position,
                isLoading: addressLoading,
                showSearch: widget.config.showSearch,
                onLocationSelected: _notifier.selectLocation,
              ),

            // Confirm Button (Visible if showConfirmButton is true)
            if (widget.config.showConfirmButton)
              MapConfirmButton(
                theme: widget.theme,
                title: widget.strings.confirmLocation,
                coordinates:
                    state.currentCenter ??
                    state.position ??
                    widget.config.fallbackCenter,
                isLoading:
                    state.addressData.state == StatusState.loading ||
                    state.isMoving,
                onTap: () {
                  final currentState = _notifier.value;
                  if (currentState.isMoving) return;
                  final center =
                      currentState.currentCenter ??
                      currentState.position ??
                      widget.config.fallbackCenter;
                  final resolvedAddress =
                      (currentState.addressData.data != null &&
                              currentState.addressData.data!.trim().isNotEmpty)
                          ? currentState.addressData.data!
                          : widget.strings.currentLocation;
                  final selected = LocationModel(
                    latLng: center,
                    address: resolvedAddress,
                  );
                  final onConfirmed = widget.onConfirmed;
                  if (onConfirmed != null) {
                    onConfirmed(selected);
                  } else {
                    Navigator.of(context).pop(selected);
                  }
                },
              ),

            // Error overlay (rendered as an overlay on the map, transparent/semi-transparent background)
            if (state.addressData.state == StatusState.failure)
              Positioned.fill(
                child: ColoredBox(
                  color:
                      isDark
                          ? Colors.black.withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.85),
                  child: LocationPickerErrorWidget(
                    theme: widget.theme,
                    message: state.addressData.exception,
                    onDismiss: () => _notifier.dismissError(),
                    onRetry: () {
                      if (hasPosition) {
                        _notifier.getAddressFromLatLng(
                          state.currentCenter ?? state.position!,
                        );
                      } else {
                        _notifier.getCurrentLocation(
                          position: state.currentCenter,
                        );
                      }
                    },
                  ),
                ),
              ),

            if (addressLoading &&
                !hasPosition &&
                widget.theme.loadingLottieAsset != null)
              Center(
                child: Lottie.asset(
                  widget.theme.loadingLottieAsset!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        );
      },
      child: ColorFiltered(
        colorFilter:
            (widget.config.useDarkTiles ?? isDark)
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
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialMapCenter,
            initialZoom: widget.config.initialZoom,
            maxZoom: widget.config.maxZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapEvent: (event) {
              if (event.source == MapEventSource.mapController) return;
              if (event is MapEventMoveStart) {
                _moveAnimationController?.stop();
              }
              if (event is MapEventMove) {
                _moveAnimationController?.stop();
                _notifier.onCameraMove(event.camera.center);
              } else if (event is MapEventMoveEnd) {
                _notifier.onCameraIdle();
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: widget.config.tileUrlTemplate,
              fallbackUrl: widget.config.fallbackUrl,
              userAgentPackageName: widget.config.userAgentPackageName,
              subdomains: widget.config.tileSubdomains,
            ),
          ],
        ),
      ),
    );
  }
}
