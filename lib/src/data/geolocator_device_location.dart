import 'package:flutter/foundation.dart';
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
    // 1. Service check: only enforce strictly on native platforms.
    // On web, the browser controls geolocation via its own permissions and network providers.
    if (!kIsWeb) {
      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (_) {
        serviceEnabled = true;
      }
      if (!serviceEnabled) {
        throw GpsFailure(serviceDisabledMessage);
      }
    }

    // 2. Permission check & request
    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
    } catch (_) {
      permission = LocationPermission.denied;
    }

    if (permission == LocationPermission.denied) {
      try {
        permission = await Geolocator.requestPermission();
      } catch (_) {
        permission = LocationPermission.denied;
      }
      if (permission == LocationPermission.denied) {
        throw GpsFailure(permissionDeniedMessage);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw GpsFailure(permissionPermanentlyDeniedMessage);
    }

    // 3. Position fetching (fast low/medium accuracy for web/desktop, medium/high for mobile)
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: kIsWeb ? LocationAccuracy.low : LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      // 4. Fallback to last known position (only on non-web platforms)
      if (!kIsWeb) {
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            return LatLng(lastKnown.latitude, lastKnown.longitude);
          }
        } catch (_) {}
      }
      throw GpsFailure(fetchFailedMessage);
    }
  }
}
