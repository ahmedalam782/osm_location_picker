import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_location_picker/src/presentation/location_picker_config.dart';

void main() {
  group('LocationPickerConfig', () {
    test('keeps sensible defaults', () {
      const config = LocationPickerConfig();
      expect(config.acceptLanguage, 'en');
      expect(config.initialZoom, 16);
      expect(config.fallbackCenter, const LatLng(33.3152, 44.3661));
      expect(
        config.tileUrlTemplate,
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      );
      expect(config.searchLimit, 5);
      expect(config.useDarkTiles, isNull);
    });
  });
}
