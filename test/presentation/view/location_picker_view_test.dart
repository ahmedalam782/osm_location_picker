import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_location_picker/src/models/location_model.dart';
import 'package:osm_location_picker/src/presentation/view/location_picker_view.dart';

import '../../test_helpers.dart';

void main() {
  group('LocationPickerView', () {
    testWidgets(
      'widget mode confirms in place and does not show the page title',
      (tester) async {
        LocationModel? selected;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LocationPickerView.widget(
                initialLatLng: const LatLng(30.0444, 31.2357),
                initialAddress: 'Cairo',
                dependencies: fakeDependencies(),
                onConfirmed: (location) => selected = location,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Select Location'), findsNothing);
        expect(find.text('Confirm Location'), findsOneWidget);

        await tester.tap(find.text('Confirm Location'));
        await tester.pump();

        expect(selected?.address, 'Cairo');
        expect(selected?.latLng, const LatLng(30.0444, 31.2357));
      },
    );

    testWidgets('page mode shows the app bar title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LocationPickerView(
            initialLatLng: const LatLng(30.0444, 31.2357),
            initialAddress: 'Cairo',
            dependencies: fakeDependencies(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Select Location'), findsOneWidget);
      expect(find.text('Confirm Location'), findsOneWidget);
    });

    testWidgets('page mode back button returns current location model', (
      tester,
    ) async {
      LocationModel? popped;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      popped = await Navigator.of(context).push<LocationModel>(
                        MaterialPageRoute(
                          builder:
                              (_) => LocationPickerView(
                                initialLatLng: const LatLng(30.0444, 31.2357),
                                initialAddress: 'Cairo',
                                dependencies: fakeDependencies(),
                              ),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Select Location'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(popped?.address, 'Cairo');
      expect(popped?.latLng, const LatLng(30.0444, 31.2357));
    });
  });
}
