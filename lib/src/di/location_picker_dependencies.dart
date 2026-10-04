import 'package:dio/dio.dart';

import '../data/cached_address_lookup.dart';
import '../data/geolocator_device_location.dart';
import '../data/internet_network_status.dart';
import '../data/nominatim_address_lookup.dart';
import '../domain/address_lookup.dart';
import '../domain/device_location.dart';
import '../domain/network_status.dart';
import '../presentation/location_picker_config.dart';
import '../utils/nominatim_service.dart';

/// Services the location picker needs.
///
/// Pass your own implementations, or use [LocationPickerDependencies.defaults].
class LocationPickerDependencies {
  final AddressLookup addressLookup;
  final DeviceLocation deviceLocation;
  final NetworkStatus networkStatus;
  final PlaceSearch placeSearch;
  final void Function()? _close;

  const LocationPickerDependencies({
    required this.addressLookup,
    required this.deviceLocation,
    required this.networkStatus,
    required this.placeSearch,
    void Function()? close,
  }) : _close = close;

  /// Nominatim, Geolocator, and a connectivity check wired together.
  ///
  /// [config] supplies the Nominatim language, user agent, and search limit.
  factory LocationPickerDependencies.defaults([
    LocationPickerConfig config = const LocationPickerConfig(),
  ]) {
    final dio = Dio();
    return LocationPickerDependencies(
      addressLookup: CachedAddressLookup(
        NominatimAddressLookup(
          dio,
          acceptLanguage: config.acceptLanguage,
          userAgent: config.nominatimUserAgent,
        ),
      ),
      deviceLocation: GeolocatorDeviceLocation(),
      networkStatus: InternetNetworkStatus(),
      placeSearch: NominatimService(
        dio,
        acceptLanguage: config.acceptLanguage,
        userAgent: config.nominatimUserAgent,
        searchLimit: config.searchLimit,
      ),
      close: dio.close,
    );
  }

  /// Releases resources created by [LocationPickerDependencies.defaults].
  void close() => _close?.call();
}
