import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_location_picker/src/models/location_model.dart';

void main() {
  group('LocationModel', () {
    test('toJson and fromJson serialization works', () {
      const latLng = LatLng(33.3152, 44.3661);
      const model = LocationModel(address: 'Test Address', latLng: latLng);

      final json = model.toJson();
      expect(json['address'], 'Test Address');
      expect(json['latLng']['latitude'], 33.3152);
      expect(json['latLng']['longitude'], 44.3661);

      final parsedModel = LocationModel.fromJson(json);
      expect(parsedModel.address, 'Test Address');
      expect(parsedModel.latLng?.latitude, 33.3152);
      expect(parsedModel.latLng?.longitude, 44.3661);
    });

    test('reads a coordinate list', () {
      final model = LocationModel.fromJson({
        'address': 'Cairo',
        'latLng': [30.0444, 31.2357],
      });

      expect(model.address, 'Cairo');
      expect(model.latLng?.latitude, 30.0444);
      expect(model.latLng?.longitude, 31.2357);
    });
  });
}
