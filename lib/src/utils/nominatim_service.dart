import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../domain/place_search.dart';

export '../domain/place_search.dart';

/// Thin wrapper around the [Nominatim](https://nominatim.org/) search API.
///
/// Requires no API key. Please respect the
/// [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/).
class NominatimService implements PlaceSearch {
  final Dio _dio;
  final String acceptLanguage;
  final String userAgent;
  final int searchLimit;

  /// Creates a [NominatimService] backed by the provided [Dio] instance.
  NominatimService(
    this._dio, {
    this.acceptLanguage = 'en',
    this.userAgent = 'LocationPicker/1.0',
    this.searchLimit = 5,
  });

  /// Searches for locations matching [query].
  ///
  /// Returns an empty list when [query] is blank or on network failure.
  /// Results are limited to 5 entries.
  @override
  Future<List<NominatimSearchResult>> search(
    String query, {
    LatLng? near,
  }) async {
    if (query.trim().isEmpty) return [];

    final parameters = <String, dynamic>{
      'q': query,
      'format': 'json',
      'limit': searchLimit,
      'addressdetails': 1,
      'dedupe': 1,
      'accept-language': acceptLanguage,
    };
    if (near != null) {
      const span = 0.6;
      parameters['viewbox'] =
          '${near.longitude - span},${near.latitude + span},${near.longitude + span},${near.latitude - span}';
      parameters['bounded'] = 0;
    }

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: parameters,
        options: Options(
          headers: {
            'Accept-Language': acceptLanguage,
            if (!kIsWeb) 'User-Agent': userAgent,
          },
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final list = response.data;
      if (list is List) {
        return list
            .map(
              (e) => NominatimSearchResult.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .where((item) => item.lat != 0 || item.lon != 0)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
