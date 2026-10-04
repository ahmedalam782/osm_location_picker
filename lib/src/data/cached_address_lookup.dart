import 'package:latlong2/latlong.dart';

import '../domain/address_lookup.dart';

/// Remembers reverse-geocode results so the same point is not fetched twice.
class CachedAddressLookup implements AddressLookup {
  final AddressLookup _inner;
  final Map<String, String> _cache = {};

  CachedAddressLookup(this._inner);

  @override
  String? cachedAddress(LatLng position) => _cache[addressCacheKey(position)];

  @override
  Future<String> addressFor(LatLng position) async {
    final key = addressCacheKey(position);
    final cached = _cache[key];
    if (cached != null && cached != 'Unknown') return cached;

    final address = await _inner.addressFor(position);
    _cache[key] = address;
    return address;
  }
}
