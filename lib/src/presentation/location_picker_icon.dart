import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An icon the host app can replace.
///
/// Use an asset image, an SVG, a network image, or a Material icon.
/// When a theme field is left null, the picker keeps its built-in icon.
///
/// ```dart
/// LocationPickerTheme(
///   searchIcon: LocationPickerIcon.svg('assets/search.svg'),
///   pinIcon: LocationPickerIcon.network('https://example.com/pin.png'),
///   selectedIcon: LocationPickerIcon.asset('assets/selected.png'),
///   myLocationIcon: LocationPickerIcon.asset('assets/gps.png'),
/// )
/// ```
class LocationPickerIcon {
  /// Built-in search icon.
  static const search = LocationPickerIcon.svg(
    'assets/icons/search.svg',
    package: 'osm_location_picker',
    size: 20,
  );

  /// Built-in map pin.
  static const pin = LocationPickerIcon.svg(
    'assets/icons/location_mark.svg',
    package: 'osm_location_picker',
    size: 45,
  );

  /// Built-in pin shown on the selected-location map image.
  static const selected = LocationPickerIcon.svg(
    'assets/icons/selected_location.svg',
    package: 'osm_location_picker',
    size: 40,
  );

  /// Built-in button that moves the map to the device location.
  static const myLocation = LocationPickerIcon.svg(
    'assets/icons/my_location.svg',
    package: 'osm_location_picker',
    size: 24,
  );

  final String? assetPath;
  final String? packageName;
  final String? url;
  final String? svgMarkup;
  final IconData? iconData;
  final bool svg;

  /// Tints the icon with the picker accent. Raster photos stay untinted
  /// unless this is set to true.
  final bool tint;

  /// Drawn width and height. When null, the slot uses its own size.
  final double? size;

  /// A raster asset, such as a PNG or JPEG.
  const LocationPickerIcon.asset(
    String asset, {
    String? package,
    this.size,
    this.tint = false,
  }) : assetPath = asset,
       packageName = package,
       url = null,
       svgMarkup = null,
       iconData = null,
       svg = false;

  /// An SVG asset.
  const LocationPickerIcon.svg(
    String asset, {
    String? package,
    this.size,
    this.tint = true,
  }) : assetPath = asset,
       packageName = package,
       url = null,
       svgMarkup = null,
       iconData = null,
       svg = true;

  /// An SVG document, with no asset file.
  const LocationPickerIcon.markup(
    String markup, {
    this.size,
    this.tint = true,
  }) : assetPath = null,
       packageName = null,
       url = null,
       svgMarkup = markup,
       iconData = null,
       svg = true;

  /// A network image. Set [svg] when the URL points at an SVG file.
  const LocationPickerIcon.network(
    this.url, {
    bool svg = false,
    this.size,
    bool? tint,
  }) : assetPath = null,
       packageName = null,
       svgMarkup = null,
       iconData = null,
       svg = svg,
       tint = tint ?? svg;

  /// A Material icon.
  const LocationPickerIcon.icon(IconData icon, {this.size, this.tint = true})
    : assetPath = null,
      packageName = null,
      url = null,
      svgMarkup = null,
      iconData = icon,
      svg = false;
}

/// Draws a [LocationPickerIcon].
class LocationPickerIconView extends StatelessWidget {
  final LocationPickerIcon icon;
  final Color? color;

  /// Size used when [LocationPickerIcon.size] is null.
  final double? size;

  const LocationPickerIconView({
    super.key,
    required this.icon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final drawnSize = icon.size ?? size;
    final tint = icon.tint ? color : null;
    final filter = tint == null
        ? null
        : ColorFilter.mode(tint, BlendMode.srcIn);

    final iconData = icon.iconData;
    if (iconData != null) {
      return Icon(iconData, size: drawnSize, color: tint);
    }

    final markup = icon.svgMarkup;
    if (markup != null) {
      return SvgPicture.string(
        markup,
        width: drawnSize,
        height: drawnSize,
        colorFilter: filter,
      );
    }

    final url = icon.url;
    if (url != null) {
      if (icon.svg) {
        return SvgPicture.network(
          url,
          width: drawnSize,
          height: drawnSize,
          colorFilter: filter,
        );
      }
      return Image.network(
        url,
        width: drawnSize,
        height: drawnSize,
        fit: BoxFit.contain,
        color: tint,
        colorBlendMode: tint == null ? null : BlendMode.srcIn,
      );
    }

    final assetPath = icon.assetPath;
    if (assetPath == null) return const SizedBox.shrink();

    if (icon.svg) {
      return SvgPicture.asset(
        assetPath,
        package: icon.packageName,
        width: drawnSize,
        height: drawnSize,
        colorFilter: filter,
      );
    }

    return Image.asset(
      assetPath,
      package: icon.packageName,
      width: drawnSize,
      height: drawnSize,
      fit: BoxFit.contain,
      color: tint,
      colorBlendMode: tint == null ? null : BlendMode.srcIn,
    );
  }
}
