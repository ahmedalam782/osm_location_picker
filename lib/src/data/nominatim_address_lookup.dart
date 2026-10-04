import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../domain/address_lookup.dart';

/// Reverse geocoder backed by the Nominatim API.
class NominatimAddressLookup implements AddressLookup {
  final Dio _dio;
  final String acceptLanguage;
  final String userAgent;

  NominatimAddressLookup(
    this._dio, {
    this.acceptLanguage = 'en',
    this.userAgent = 'LocationPicker/1.0',
  });

  @override
  String? cachedAddress(LatLng position) => null;

  @override
  Future<String> addressFor(LatLng position) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=${position.latitude}&lon=${position.longitude}&format=json&accept-language=$acceptLanguage',
      options: Options(
        headers: {
          if (!kIsWeb) 'User-Agent': userAgent,
          'Accept-Language': acceptLanguage,
        },
        receiveTimeout: const Duration(seconds: 4),
      ),
    );

    final data = response.data;
    String? address;
    if (data is Map) {
      address = data['display_name'] as String?;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          address = decoded['display_name'] as String?;
        }
      } catch (_) {}
    }

    return address ?? 'Unknown';
  }
}
