import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osm_location_picker/src/presentation/location_picker_theme.dart';
import 'package:osm_location_picker/src/presentation/view/widgets/map_action_controls.dart';

void main() {
  group('MapActionControls', () {
    testWidgets('renders zoom in, zoom out, and my location buttons',
        (tester) async {
      bool zoomedIn = false;
      bool zoomedOut = false;
      bool myLocation = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapActionControls(
              theme: const LocationPickerTheme(),
              onZoomIn: () => zoomedIn = true,
              onZoomOut: () => zoomedOut = true,
              onMyLocation: () => myLocation = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(zoomedIn, true);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      expect(zoomedOut, true);

      await tester.tap(find.byTooltip('My location'));
      expect(myLocation, true);
    });
  });
}
