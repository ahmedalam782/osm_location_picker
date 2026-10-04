import 'package:latlong2/latlong.dart';

/// A single result returned by a place search.
class NominatimSearchResult {
  /// Full display name of the matched location.
  final String displayName;

  /// Latitude of the matched location.
  final double lat;

  /// Longitude of the matched location.
  final double lon;

  /// OSM type string (e.g. `"city"`, `"road"`).
  final String type;

  /// Place name shown as the suggestion title.
  final String title;

  /// Wider address shown under [title].
  final String subtitle;

  /// Creates a [NominatimSearchResult].
  const NominatimSearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
    required this.title,
    required this.subtitle,
  });

  /// Deserialises a [NominatimSearchResult] from a Nominatim JSON object.
  factory NominatimSearchResult.fromJson(Map<String, dynamic> json) {
    final displayName = json['display_name']?.toString() ?? '';
    final title = _titleFrom(json, displayName);
    return NominatimSearchResult(
      displayName: displayName,
      lat: _asDouble(json['lat']),
      lon: _asDouble(json['lon']),
      type: json['type']?.toString() ?? '',
      title: title,
      subtitle: _subtitleFrom(json, title, displayName),
    );
  }

  LatLng get latLng => LatLng(lat, lon);
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _titleFrom(Map<String, dynamic> json, String displayName) {
  final name = json['name']?.toString().trim();
  if (name != null && name.isNotEmpty) return name;
  final first = displayName.split(RegExp(r'\s*[,،]\s*')).first.trim();
  return first.isEmpty ? displayName : first;
}

String _subtitleFrom(
  Map<String, dynamic> json,
  String title,
  String displayName,
) {
  final address = json['address'];
  if (address is Map) {
    const keys = [
      'road',
      'suburb',
      'neighbourhood',
      'quarter',
      'city',
      'town',
      'village',
      'state',
      'country',
    ];
    final parts = <String>[];
    for (final key in keys) {
      final value = address[key]?.toString().trim();
      if (value == null || value.isEmpty || value == title) continue;
      if (parts.contains(value)) continue;
      parts.add(value);
    }
    if (parts.isNotEmpty) return parts.join(', ');
  }
  final rest = displayName
      .split(RegExp(r'\s*[,،]\s*'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty && part != title)
      .toList();
  return rest.join(', ');
}

/// Searches for places by free text.
abstract class PlaceSearch {
  /// Returns matches for [query].
  ///
  /// [near] biases results toward the map the user is looking at.
  Future<List<NominatimSearchResult>> search(String query, {LatLng? near});
}
