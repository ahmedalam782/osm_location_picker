/// UI strings used by [LocationPickerView].
///
/// English is the default. Pass strings from the host app when you want
/// another language, including values already translated with `.tr()`:
///
/// ```dart
/// LocationPickerView(
///   strings: LocationPickerStrings(
///     title: 'location_picker.title'.tr(),
///     confirmLocation: 'location_picker.confirm_location'.tr(),
///   ),
/// )
/// ```
///
/// Omitted fields stay in English.
class LocationPickerStrings {
  /// Title displayed in the app bar.
  final String title;

  /// Shown while the device GPS position is being acquired.
  final String fetchingLocation;

  /// Shown when fetching the GPS position fails.
  final String locationFetchFailed;

  /// Placeholder address when reverse geocoding returns nothing.
  final String unknownLocation;

  /// Label for the confirm-location action button.
  final String confirmLocation;

  /// Label for the "my location" / GPS button.
  final String currentLocation;

  /// Shown when the device has no internet connection.
  final String noInternet;

  /// Shown when the device location service is disabled.
  final String serviceDisabled;

  /// Shown when location permission has been denied.
  final String permissionDenied;

  /// Shown when location permission has been permanently denied.
  final String permissionPermanentlyDenied;

  /// Placeholder hint inside the address search field.
  final String searchHint;

  /// Shown when an address search returns no results.
  final String noResults;

  /// Creates UI strings. Every field defaults to English.
  const LocationPickerStrings({
    this.title = 'Select Location',
    this.fetchingLocation = 'Fetching location...',
    this.locationFetchFailed = 'Failed to fetch location',
    this.unknownLocation = 'Unknown location',
    this.confirmLocation = 'Confirm Location',
    this.currentLocation = 'Current Location',
    this.noInternet = 'No internet connection, please try again!',
    this.serviceDisabled = 'Location services are disabled',
    this.permissionDenied = 'Location permission denied',
    this.permissionPermanentlyDenied = 'Location permission permanently denied',
    this.searchHint = 'Search for a location...',
    this.noResults = 'No results found',
  });
}
