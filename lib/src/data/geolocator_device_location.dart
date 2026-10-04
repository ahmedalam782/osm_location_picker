import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../domain/device_location.dart';
import '../utils/location_picker_failure.dart';

class GeolocatorDeviceLocation implements DeviceLocation {
  @override
  Future<LatLng> currentLocation({
    required String serviceDisabledMessage,
    required String permissionDeniedMessage,
    required String permissionPermanentlyDeniedMessage,
    required String fetchFailedMessage,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw GpsFailure(serviceDisabledMessage);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw GpsFailure(permissionDeniedMessage);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw GpsFailure(permissionPermanentlyDeniedMessage);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return LatLng(lastKnown.latitude, lastKnown.longitude);
        }
      } catch (_) {}
      throw GpsFailure(fetchFailedMessage);
    }
  }
}
