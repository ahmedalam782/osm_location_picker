import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Loads `assets/translations/<languageCode>.json`.
///
/// Add a language by dropping a new JSON file in that folder and listing its
/// code in `assets/translations/languages.json`. Missing files fall back to English.
class AppTranslations {
  static AppTranslations? _current;

  final Locale locale;
  final Map<String, dynamic> _data;

  AppTranslations._(this.locale, this._data) {
    _current = this;
  }

  static AppTranslations get current {
    final translations = _current;
    if (translations == null) {
      throw StateError('Call AppTranslations.load before using .tr()');
    }
    return translations;
  }

  String tr(String key) {
    dynamic value = _data;
    for (final part in key.split('.')) {
      if (value is Map<String, dynamic> && value.containsKey(part)) {
        value = value[part];
      } else {
        return key;
      }
    }
    return value?.toString() ?? key;
  }

  static Future<List<String>> languageCodes() async {
    final raw = await rootBundle.loadString(
      'assets/translations/languages.json',
    );
    return (jsonDecode(raw) as List).cast<String>();
  }

  /// Native name for each code, from `language_name` in that language file.
  static Future<Map<String, String>> languageNames() async {
    final codes = await languageCodes();
    final names = <String, String>{};
    for (final code in codes) {
      final raw = await rootBundle.loadString('assets/translations/$code.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      names[code] = data['language_name']?.toString() ?? code;
    }
    return names;
  }

  static Future<AppTranslations> load(Locale locale) async {
    final code = locale.languageCode;
    String raw;
    try {
      raw = await rootBundle.loadString('assets/translations/$code.json');
    } catch (_) {
      raw = await rootBundle.loadString('assets/translations/en.json');
    }
    return AppTranslations._(
      Locale(code),
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}

extension AssetTr on String {
  String get tr => AppTranslations.current.tr(this);
}
