import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_location_picker/src/presentation/location_picker_theme.dart';
import 'package:osm_location_picker/src/presentation/view/widgets/map_confirm_button.dart';

void main() {
  group('MapConfirmButton', () {
    testWidgets('renders coordinates and handles tap callback',
        (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                MapConfirmButton(
                  theme: const LocationPickerTheme(),
                  title: 'Confirm',
                  coordinates: const LatLng(30.0444, 31.2357),
                  onTap: () => confirmed = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.textContaining('30.04440'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      expect(confirmed, true);
    });
  });
}
