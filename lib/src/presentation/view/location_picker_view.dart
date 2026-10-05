import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../models/location_model.dart';
import '../../di/location_picker_dependencies.dart';
import '../location_picker_config.dart';
import '../location_picker_icon.dart';
import '../location_picker_theme.dart';
import '../location_picker_strings.dart';
import '../view_model/location_picker_notifier.dart';
import 'widgets/location_picker_body.dart';

/// Location picker backed by OpenStreetMap.
///
/// Use it as a page:
///
/// ```dart
/// final result = await Navigator.of(context).push<LocationModel>(
///   MaterialPageRoute(builder: (_) => const LocationPickerView()),
/// );
/// ```
///
/// Or embed it as a widget. Confirm calls [onConfirmed] and does not pop
/// the surrounding route:
///
/// ```dart
/// LocationPickerView.widget(
///   onConfirmed: (location) {
///     setState(() => selected = location);
///   },
/// )
/// ```
class LocationPickerView extends StatefulWidget {
  /// Pre-selected coordinates shown on the map when the picker opens.
  ///
  /// When `null` the picker tries to acquire the device's current GPS position.
  final LatLng? initialLatLng;

  /// Pre-selected address label shown in the header.
  final String? initialAddress;

  /// Visual theme. Defaults to [LocationPickerTheme.of] (derived from
  /// the ambient [ThemeData]) when not provided.
  final LocationPickerTheme? theme;

  /// UI text. Defaults to English when not provided.
  ///
  /// Pass strings from the host app, including `.tr()` values:
  /// `LocationPickerStrings(title: 'location_picker.title'.tr())`.
  final LocationPickerStrings? strings;

  /// GPS, geocoding, search, and connectivity.
  ///
  /// Defaults to [LocationPickerDependencies.defaults] when omitted.
  final LocationPickerDependencies? dependencies;

  /// Map tiles, zoom, fallback center, and Nominatim language.
  ///
  /// Defaults to [LocationPickerConfig] when omitted.
  final LocationPickerConfig config;

  /// Whether this picker fills a route with an app bar.
  ///
  /// `true` for [LocationPickerView]. `false` for [LocationPickerView.widget].
  final bool asPage;

  /// Called when the user confirms a place in widget mode.
  final ValueChanged<LocationModel>? onConfirmed;

  /// Full-screen page. Push it and await a [LocationModel].
  const LocationPickerView({
    super.key,
    this.initialLatLng,
    this.initialAddress,
    this.theme,
    this.strings,
    this.dependencies,
    this.config = const LocationPickerConfig(),
  }) : asPage = true,
       onConfirmed = null;

  /// Embeddable picker. [onConfirmed] receives the selected place.
  const LocationPickerView.widget({
    super.key,
    required this.onConfirmed,
    this.initialLatLng,
    this.initialAddress,
    this.theme,
    this.strings,
    this.dependencies,
    this.config = const LocationPickerConfig(),
  }) : asPage = false;

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  LocationPickerNotifier? _notifier;
  LocationPickerDependencies? _ownedDependencies;

  LocationPickerDependencies get _dependencies =>
      widget.dependencies ?? _ownedDependencies!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_notifier != null) return;

    final dependencies =
        widget.dependencies ??
        LocationPickerDependencies.defaults(widget.config);
    if (widget.dependencies == null) _ownedDependencies = dependencies;

    final activeStrings = widget.strings ?? const LocationPickerStrings();
    final notifier = LocationPickerNotifier(
      initialLatLng: widget.initialLatLng,
      initialAddress: widget.initialAddress,
      fallbackLatLng: widget.config.fallbackCenter,
      strings: activeStrings,
      addressLookup: dependencies.addressLookup,
      deviceLocation: dependencies.deviceLocation,
      networkStatus: dependencies.networkStatus,
    );
    final address = widget.initialAddress;
    if (widget.initialLatLng == null) {
      if (widget.config.autoFetchCurrentLocation) {
        notifier.getCurrentLocation();
      }
    } else if (address == null || address.isEmpty) {
      notifier.getAddressFromLatLng(widget.initialLatLng!);
    }
    _notifier = notifier;
  }

  @override
  void dispose() {
    _notifier?.dispose();
    _ownedDependencies?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    if (notifier == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTheme = (widget.theme ?? LocationPickerTheme.of(context))
        .forBrightness(isDark ? Brightness.dark : Brightness.light);
    final activeStrings = widget.strings ?? const LocationPickerStrings();
    final fontFamily = activeTheme.fontFamily;
    final body = LocationPickerBody(
      notifier: notifier,
      theme: activeTheme,
      strings: activeStrings,
      config: widget.config,
      placeSearch: _dependencies.placeSearch,
      onConfirmed: widget.asPage ? null : widget.onConfirmed,
    );
    final picker = widget.asPage
        ? _page(activeTheme, activeStrings, isDark, body)
        : body;
    return _withFont(context, fontFamily, picker);
  }

  Widget _page(
    LocationPickerTheme activeTheme,
    LocationPickerStrings activeStrings,
    bool isDark,
    Widget body,
  ) {
    void handleBack() {
      final notifier = _notifier;
      if (notifier != null) {
        final state = notifier.value;
        final center = state.currentCenter ?? state.position;
        if (center != null) {
          final address = (state.addressData.data != null &&
                  state.addressData.data!.trim().isNotEmpty)
              ? state.addressData.data!
              : activeStrings.currentLocation;
          Navigator.of(context).pop(LocationModel(
            latLng: center,
            address: address,
          ));
          return;
        }
      }
      Navigator.of(context).pop();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          handleBack();
        },
        child: Scaffold(
          backgroundColor: activeTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            titleSpacing: 4,
            title: Text(
              activeStrings.title,
              style: TextStyle(
                color: activeTheme.textDarkColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Center(
                child: Tooltip(
                  message: 'Back',
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: handleBack,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: activeTheme.cardColor.withValues(
                            alpha: activeTheme.glassmorphism ? 0.75 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : activeTheme.borderColor.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: LocationPickerIconView(
                            icon: activeTheme.backIcon ??
                                const LocationPickerIcon.icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                ),
                            color: activeTheme.textDarkColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: body,
        ),
      ),
    );
  }
}

Widget _withFont(BuildContext context, String? fontFamily, Widget child) {
  if (fontFamily == null || fontFamily.isEmpty) return child;

  final currentTheme = Theme.of(context);
  return Theme(
    data: currentTheme.copyWith(
      textTheme: currentTheme.textTheme.apply(fontFamily: fontFamily),
      primaryTextTheme: currentTheme.primaryTextTheme.apply(
        fontFamily: fontFamily,
      ),
    ),
    child: DefaultTextStyle.merge(
      style: TextStyle(fontFamily: fontFamily),
      child: child,
    ),
  );
}
