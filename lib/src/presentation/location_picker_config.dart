import 'package:latlong2/latlong.dart';

/// Map and geocoding settings a host app can override.
///
/// Every field has a default. Pass only the values you want to change.
class LocationPickerConfig {
  /// Raster tile URL. `{z}`, `{x}`, and `{y}` are replaced by the map.
  ///
  /// The default is the public OpenStreetMap tile server, which does not need
  /// an API key. Carto basemaps (`basemaps.cartocdn.com`) require one.
  /// In debug builds Flutter Map prints a reminder about the public tile
  /// server. That reminder is not a failed tile request.
  final String tileUrlTemplate;

  /// Subdomains substituted for `{s}` in [tileUrlTemplate].
  final List<String> tileSubdomains;

  /// Package name sent with tile requests.
  final String userAgentPackageName;

  /// User-Agent sent to Nominatim.
  final String nominatimUserAgent;

  /// `Accept-Language` sent to Nominatim, for example `en`, `ar`, or `fr`.
  final String acceptLanguage;

  /// Zoom used when the map opens and when it moves to a selected point.
  final double initialZoom;

  /// Highest zoom the map allows.
  final double maxZoom;

  /// Center used when GPS is unavailable.
  final LatLng fallbackCenter;

  /// Maximum number of search results.
  final int searchLimit;

  /// Forces dark map tiles. When `null`, follows the app brightness.
  final bool? useDarkTiles;

  /// Creates map and geocoding settings.
  const LocationPickerConfig({
    this.tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.tileSubdomains = const [],
    this.userAgentPackageName = 'com.location_picker.app',
    this.nominatimUserAgent = 'LocationPicker/1.0',
    this.acceptLanguage = 'en',
    this.initialZoom = 16,
    this.maxZoom = 18,
    this.fallbackCenter = const LatLng(33.3152, 44.3661),
    this.searchLimit = 5,
    this.useDarkTiles,
  });
}
