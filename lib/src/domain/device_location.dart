import 'package:latlong2/latlong.dart';

/// Reads the device GPS position.
abstract class DeviceLocation {
  /// Returns the current coordinates, or throws when GPS is unavailable.
  Future<LatLng> currentLocation({
    required String serviceDisabledMessage,
    required String permissionDeniedMessage,
    required String permissionPermanentlyDeniedMessage,
    required String fetchFailedMessage,
  });
}
