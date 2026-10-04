import 'package:flutter_test/flutter_test.dart';
import 'package:osm_location_picker/src/presentation/location_picker_strings.dart';

void main() {
  group('LocationPickerStrings', () {
    test('keeps English default strings', () {
      const strings = LocationPickerStrings();
      expect(strings.title, 'Select Location');
      expect(strings.searchHint, 'Search for a location...');
      expect(strings.confirmLocation, 'Confirm Location');
      expect(strings.currentLocation, 'Current Location');
      expect(strings.fetchingLocation, 'Fetching location...');
      expect(strings.noResults, 'No results found');
    });
  });
}
