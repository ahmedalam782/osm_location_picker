import 'package:latlong2/latlong.dart';

/// Cache key shared by reverse geocoding and the camera-idle check.
String addressCacheKey(LatLng position) =>
    '${position.latitude.toStringAsFixed(4)},${position.longitude.toStringAsFixed(4)}';

/// Reverse-geocodes a map point into a display address.
abstract class AddressLookup {
  /// Returns a previously resolved address for [position], if one exists.
  String? cachedAddress(LatLng position);

  /// Resolves a display address for [position].
  Future<String> addressFor(LatLng position);
}
