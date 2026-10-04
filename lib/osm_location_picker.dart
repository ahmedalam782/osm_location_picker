/// A self-contained Flutter location picker powered by OpenStreetMap.
///
/// No API key is required. Users can pan/zoom the map, search for addresses,
/// and confirm a location. The package returns a [LocationModel] with the
/// selected address and [LatLng] coordinates.
///
/// ## Usage
/// Use [LocationPickerView] as a page, or [LocationPickerView.widget] inline.
///
/// ```dart
/// final result = await Navigator.of(context).push<LocationModel>(
///   MaterialPageRoute(builder: (_) => const LocationPickerView()),
/// );
///
/// LocationPickerView.widget(
///   onConfirmed: (location) {},
/// );
/// ```
library;

export 'src/di/location_picker_dependencies.dart';
export 'src/domain/address_lookup.dart';
export 'src/domain/device_location.dart';
export 'src/domain/network_status.dart';
export 'src/domain/place_search.dart';
export 'src/models/location_model.dart';
export 'src/presentation/location_picker_config.dart';
export 'src/presentation/location_picker_icon.dart';
export 'src/presentation/location_picker_strings.dart';
export 'src/presentation/location_picker_theme.dart';
export 'src/presentation/view/location_picker_view.dart';
export 'src/presentation/view/location_map_preview.dart';
export 'src/presentation/view/widgets/map_action_controls.dart';
export 'src/presentation/view/widgets/map_confirm_button.dart';
export 'src/presentation/view/widgets/map_center_marker.dart';
export 'src/presentation/view/widgets/my_location_button.dart';
export 'src/utils/nominatim_service.dart';
