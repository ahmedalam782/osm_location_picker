import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_location_picker/src/domain/place_search.dart';

void main() {
  group('NominatimSearchResult', () {
    test('splits a place name and address correctly', () {
      final result = NominatimSearchResult.fromJson({
        'display_name': 'Tahrir Square, Cairo, Egypt',
        'name': 'Tahrir Square',
        'lat': '30.0444',
        'lon': 31.2357,
        'type': 'square',
        'address': {'city': 'Cairo', 'country': 'Egypt'},
      });

      expect(result.title, 'Tahrir Square');
      expect(result.subtitle, 'Cairo, Egypt');
      expect(result.lat, 30.0444);
      expect(result.lon, 31.2357);
      expect(result.latLng, const LatLng(30.0444, 31.2357));
    });
  });
}
