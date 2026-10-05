import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osm_location_picker/src/presentation/location_picker_icon.dart';
import 'package:osm_location_picker/src/presentation/location_picker_theme.dart';

void main() {
  group('LocationPickerTheme', () {
    test('defaults and copyWith work as expected', () {
      const defaultTheme = LocationPickerTheme();
      expect(defaultTheme.glassmorphism, true);
      expect(defaultTheme.borderRadius, 16.0);
      expect(defaultTheme.primaryColor, const Color(0xffEA3433));

      final fromPrimary = LocationPickerTheme.fromPrimary(
        const Color(0xff2563EB),
      );
      expect(fromPrimary.primaryColor, const Color(0xff2563EB));
      expect(fromPrimary.glassmorphism, true);

      final modified = defaultTheme.copyWith(
        glassmorphism: false,
        borderRadius: 24.0,
        primaryColor: Colors.purple,
        zoomInIcon: const LocationPickerIcon.icon(Icons.zoom_in),
        zoomOutIcon: const LocationPickerIcon.icon(Icons.zoom_out),
        backIcon: const LocationPickerIcon.icon(Icons.arrow_back),
      );
      expect(modified.glassmorphism, false);
      expect(modified.borderRadius, 24.0);
      expect(modified.primaryColor, Colors.purple);
      expect(modified.zoomInIcon?.iconData, Icons.zoom_in);
      expect(modified.zoomOutIcon?.iconData, Icons.zoom_out);
      expect(modified.backIcon?.iconData, Icons.arrow_back);
    });

    test('forBrightness adapts properly to dark and light mode', () {
      final fromPrimary = LocationPickerTheme.fromPrimary(
        const Color(0xff2563EB),
      );
      final dark = fromPrimary.forBrightness(Brightness.dark);

      expect(dark.primaryColor, fromPrimary.primaryColor);
      expect(dark.backgroundColor.computeLuminance(), lessThan(0.5));
      expect(dark.cardColor.computeLuminance(), lessThan(0.5));
      expect(dark.textDarkColor.computeLuminance(), greaterThan(0.5));
      expect(dark.forBrightness(Brightness.dark).cardColor, dark.cardColor);
      expect(
        identical(fromPrimary.forBrightness(Brightness.light), fromPrimary),
        isTrue,
      );
    });

    test('keeps font family and custom icons supplied by host app', () {
      const icon = LocationPickerIcon.icon(Icons.check_rounded);
      final theme = LocationPickerTheme.fromPrimary(
        const Color(0xff1B6B4A),
        fontFamily: 'Cairo',
        confirmIcon: icon,
      );

      expect(theme.fontFamily, 'Cairo');
      expect(theme.confirmIcon, icon);
      expect(theme.copyWith().fontFamily, 'Cairo');
    });
  });
}
