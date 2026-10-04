import 'package:latlong2/latlong.dart';
import 'package:osm_location_picker/src/di/location_picker_dependencies.dart';
import 'package:osm_location_picker/src/domain/address_lookup.dart';
import 'package:osm_location_picker/src/domain/device_location.dart';
import 'package:osm_location_picker/src/domain/network_status.dart';
import 'package:osm_location_picker/src/domain/place_search.dart';

LocationPickerDependencies fakeDependencies() {
  return LocationPickerDependencies(
    addressLookup: FakeAddressLookup(),
    deviceLocation: FakeDeviceLocation(),
    networkStatus: FakeNetworkStatus(),
    placeSearch: FakePlaceSearch(),
  );
}

class FakeAddressLookup implements AddressLookup {
  @override
  String? cachedAddress(LatLng position) => 'Cairo';

  @override
  Future<String> addressFor(LatLng position) async => 'Cairo';
}

class FakeDeviceLocation implements DeviceLocation {
  @override
  Future<LatLng> currentLocation({
    required String serviceDisabledMessage,
    required String permissionDeniedMessage,
    required String permissionPermanentlyDeniedMessage,
    required String fetchFailedMessage,
  }) async {
    return const LatLng(30.0444, 31.2357);
  }
}

class FakeNetworkStatus implements NetworkStatus {
  @override
  Future<bool> get hasInternet async => true;
}

class FakePlaceSearch implements PlaceSearch {
  @override
  Future<List<NominatimSearchResult>> search(
    String query, {
    LatLng? near,
  }) async {
    return const [];
  }
}
