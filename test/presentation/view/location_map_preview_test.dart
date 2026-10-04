import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_location_picker/src/presentation/location_picker_icon.dart';
import 'package:osm_location_picker/src/presentation/view/location_map_preview.dart';

void main() {
  group('LocationMapPreview', () {
    testWidgets('renders marker and pin icon correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationMapPreview(
              location: LatLng(30.0444, 31.2357),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LocationMapPreview), findsOneWidget);
      expect(find.byType(LocationPickerIconView), findsOneWidget);
      final rect = tester.getRect(find.byType(LocationPickerIconView));
      expect(rect.width, greaterThan(0));
      expect(rect.height, greaterThan(0));
    });
  });
}
