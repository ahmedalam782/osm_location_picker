import 'package:flutter/material.dart';

import 'location_picker_icon.dart';

/// Visual configuration for [LocationPickerView].
///
/// All colours have sensible defaults (red accent on white). Use
/// [LocationPickerTheme.of] to derive colours automatically from the app's
/// [ThemeData], or construct this class directly for full control.
class LocationPickerTheme {
  /// Primary accent colour used for buttons, the confirm bar, and the pin.
  final Color primaryColor;

  /// Scaffold / map overlay background colour.
  final Color backgroundColor;

  /// Card surface colour (search bar, address header, etc.).
  final Color cardColor;

  /// Border colour for cards and input fields.
  final Color borderColor;

  /// Primary text colour (on light surfaces).
  final Color textDarkColor;

  /// Secondary text colour (on dark / coloured surfaces).
  final Color textLightColor;

  /// Shadow applied to floating cards.
  final BoxShadow shadowBox;

  /// Shadow applied to FABs.
  final BoxShadow fabShadow;

  /// Whether to apply modern frosted glassmorphism (blur + semi-transparent surface).
  /// Defaults to `true`.
  final bool glassmorphism;

  /// Standard border radius for cards, search bars, and bottom sheets.
  /// Defaults to `16.0`.
  final double borderRadius;

  /// Optional gradient for action buttons and accents.
  final Gradient? accentGradient;

  /// Surface color for map controls (Zoom buttons, My Location).
  final Color? controlsBackgroundColor;

  /// Optional Lottie asset path shown while the location is loading.
  final String? loadingLottieAsset;

  /// Optional Lottie asset path shown on a generic error state.
  final String? errorLottieAsset;

  /// Optional Lottie asset path shown when the device is offline.
  final String? noInternetLottieAsset;

  /// Search icon. An asset image, SVG, network image, or Material icon.
  final LocationPickerIcon? searchIcon;

  /// Map pin. An asset image, SVG, network image, or Material icon.
  final LocationPickerIcon? pinIcon;

  /// Pin drawn on the selected-location map image.
  ///
  /// Separate from [pinIcon], which is the marker while the user is picking.
  final LocationPickerIcon? selectedIcon;

  /// Button that recenters the map on the device. An asset image, SVG,
  /// network image, or Material icon.
  final LocationPickerIcon? myLocationIcon;

  /// Icon on the confirm button. An asset image, SVG, network image, or
  /// Material icon. The built-in icon is a check.
  final LocationPickerIcon? confirmIcon;

  /// Zoom in button icon. Defaults to `Icons.add_rounded`.
  final LocationPickerIcon? zoomInIcon;

  /// Zoom out button icon. Defaults to `Icons.remove_rounded`.
  final LocationPickerIcon? zoomOutIcon;

  /// Back button icon on the AppBar. Defaults to `Icons.arrow_back_ios_new_rounded`.
  final LocationPickerIcon? backIcon;

  /// Font used for the picker text.
  ///
  /// Pass the same family you use for the current language, the way you pass
  /// translated strings. When null, text keeps the host app font.
  final String? fontFamily;

  /// Builds a palette from [primary].
  ///
  /// The bar, card border, and buttons all use this colour, so changing the
  /// accent does not leave the old pink background in place.
  factory LocationPickerTheme.fromPrimary(
    Color primary, {
    LocationPickerIcon? searchIcon,
    LocationPickerIcon? pinIcon,
    LocationPickerIcon? selectedIcon,
    LocationPickerIcon? myLocationIcon,
    LocationPickerIcon? confirmIcon,
    LocationPickerIcon? zoomInIcon,
    LocationPickerIcon? zoomOutIcon,
    LocationPickerIcon? backIcon,
    String? fontFamily,
    bool glassmorphism = true,
    double borderRadius = 16.0,
    Gradient? accentGradient,
    Color? controlsBackgroundColor,
  }) {
    return LocationPickerTheme(
      primaryColor: primary,
      backgroundColor: Color.alphaBlend(
        primary.withValues(alpha: 0.12),
        const Color(0xffffffff),
      ),
      cardColor: const Color(0xffffffff),
      borderColor: primary.withValues(alpha: 0.35),
      searchIcon: searchIcon,
      pinIcon: pinIcon,
      selectedIcon: selectedIcon,
      myLocationIcon: myLocationIcon,
      confirmIcon: confirmIcon,
      zoomInIcon: zoomInIcon,
      zoomOutIcon: zoomOutIcon,
      backIcon: backIcon,
      fontFamily: fontFamily,
      glassmorphism: glassmorphism,
      borderRadius: borderRadius,
      accentGradient: accentGradient,
      controlsBackgroundColor: controlsBackgroundColor,
    );
  }

  /// Creates a [LocationPickerTheme] with optional overrides.
  ///
  /// All fields have defaults so you only need to pass the values you want
  /// to change.
  const LocationPickerTheme({
    this.primaryColor = const Color(0xffEA3433),
    this.backgroundColor = const Color(0xffFDF2F2),
    this.cardColor = const Color(0xffffffff),
    this.borderColor = const Color(0xffFCD6D6),
    this.textDarkColor = const Color(0xff0A100B),
    this.textLightColor = const Color(0xffffffff),
    this.shadowBox = const BoxShadow(
      color: Color(0x14000000), // refined modern shadow
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    this.fabShadow = const BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 14,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    this.glassmorphism = true,
    this.borderRadius = 16.0,
    this.accentGradient,
    this.controlsBackgroundColor,
    this.loadingLottieAsset,
    this.errorLottieAsset,
    this.noInternetLottieAsset,
    this.searchIcon,
    this.pinIcon,
    this.selectedIcon,
    this.myLocationIcon,
    this.confirmIcon,
    this.zoomInIcon,
    this.zoomOutIcon,
    this.backIcon,
    this.fontFamily,
  });

  /// Recolours light surfaces when [brightness] is dark.
  ///
  /// The accent, icons, and font stay the same. A theme that already uses a
  /// dark background is returned unchanged.
  LocationPickerTheme forBrightness(Brightness brightness) {
    if (brightness != Brightness.dark) return this;
    if (backgroundColor.computeLuminance() < 0.5 &&
        cardColor.computeLuminance() < 0.5) {
      return this;
    }
    const surface = Color(0xff1C221D);
    return copyWith(
      backgroundColor: Color.alphaBlend(
        primaryColor.withValues(alpha: 0.22),
        const Color(0xff111412),
      ),
      cardColor: surface,
      borderColor: primaryColor.withValues(alpha: 0.45),
      textDarkColor: const Color(0xffF2F5F3),
      controlsBackgroundColor: controlsBackgroundColor ?? surface,
    );
  }

  /// Returns a copy of this theme with the given fields replaced.
  LocationPickerTheme copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? cardColor,
    Color? borderColor,
    Color? textDarkColor,
    Color? textLightColor,
    BoxShadow? shadowBox,
    BoxShadow? fabShadow,
    bool? glassmorphism,
    double? borderRadius,
    Gradient? accentGradient,
    Color? controlsBackgroundColor,
    String? loadingLottieAsset,
    String? errorLottieAsset,
    String? noInternetLottieAsset,
    LocationPickerIcon? searchIcon,
    LocationPickerIcon? pinIcon,
    LocationPickerIcon? selectedIcon,
    LocationPickerIcon? myLocationIcon,
    LocationPickerIcon? confirmIcon,
    LocationPickerIcon? zoomInIcon,
    LocationPickerIcon? zoomOutIcon,
    LocationPickerIcon? backIcon,
    String? fontFamily,
  }) {
    return LocationPickerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      textDarkColor: textDarkColor ?? this.textDarkColor,
      textLightColor: textLightColor ?? this.textLightColor,
      shadowBox: shadowBox ?? this.shadowBox,
      fabShadow: fabShadow ?? this.fabShadow,
      glassmorphism: glassmorphism ?? this.glassmorphism,
      borderRadius: borderRadius ?? this.borderRadius,
      accentGradient: accentGradient ?? this.accentGradient,
      controlsBackgroundColor:
          controlsBackgroundColor ?? this.controlsBackgroundColor,
      loadingLottieAsset: loadingLottieAsset ?? this.loadingLottieAsset,
      errorLottieAsset: errorLottieAsset ?? this.errorLottieAsset,
      noInternetLottieAsset:
          noInternetLottieAsset ?? this.noInternetLottieAsset,
      searchIcon: searchIcon ?? this.searchIcon,
      pinIcon: pinIcon ?? this.pinIcon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      myLocationIcon: myLocationIcon ?? this.myLocationIcon,
      confirmIcon: confirmIcon ?? this.confirmIcon,
      zoomInIcon: zoomInIcon ?? this.zoomInIcon,
      zoomOutIcon: zoomOutIcon ?? this.zoomOutIcon,
      backIcon: backIcon ?? this.backIcon,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  /// Derives a [LocationPickerTheme] from the ambient [BuildContext]'s
  /// [ThemeData], automatically adapting to dark/light mode.
  factory LocationPickerTheme.of(
    BuildContext context, {
    String? loadingLottieAsset,
    String? errorLottieAsset,
    String? noInternetLottieAsset,
    LocationPickerIcon? searchIcon,
    LocationPickerIcon? pinIcon,
    LocationPickerIcon? selectedIcon,
    LocationPickerIcon? myLocationIcon,
    LocationPickerIcon? confirmIcon,
    LocationPickerIcon? zoomInIcon,
    LocationPickerIcon? zoomOutIcon,
    LocationPickerIcon? backIcon,
    String? fontFamily,
    bool glassmorphism = true,
    double borderRadius = 16.0,
    Gradient? accentGradient,
    Color? controlsBackgroundColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LocationPickerTheme(
      primaryColor: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      cardColor: isDark ? const Color(0xff161B17) : const Color(0xffffffff),
      borderColor:
          isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Theme.of(context).primaryColor.withValues(alpha: 0.16),
      textDarkColor: isDark ? const Color(0xffF2F5F3) : const Color(0xff0A100B),
      textLightColor:
          isDark ? const Color(0xff0A100B) : const Color(0xffffffff),
      controlsBackgroundColor: controlsBackgroundColor ?? (isDark ? const Color(0xff1C221D) : Colors.white),
      loadingLottieAsset: loadingLottieAsset,
      errorLottieAsset: errorLottieAsset,
      noInternetLottieAsset: noInternetLottieAsset,
      searchIcon: searchIcon,
      pinIcon: pinIcon,
      selectedIcon: selectedIcon,
      myLocationIcon: myLocationIcon,
      confirmIcon: confirmIcon,
      zoomInIcon: zoomInIcon,
      zoomOutIcon: zoomOutIcon,
      backIcon: backIcon,
      fontFamily: fontFamily ??
          Theme.of(context).textTheme.bodyMedium?.fontFamily,
      glassmorphism: glassmorphism,
      borderRadius: borderRadius,
      accentGradient: accentGradient,
    );
  }
}
