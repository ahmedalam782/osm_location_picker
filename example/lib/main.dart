import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:osm_location_picker/osm_location_picker.dart';

import 'app_translations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  List<String> _languageCodes = const ['ar', 'en'];
  Map<String, String> _languageNames = const {'ar': 'العربية', 'en': 'English'};
  bool _ready = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final codes = await AppTranslations.languageCodes();
    final names = await AppTranslations.languageNames();
    await AppTranslations.load(_locale);
    if (!mounted) return;
    setState(() {
      _languageCodes = codes;
      _languageNames = names;
      _ready = true;
    });
  }

  Future<void> _setLocale(String languageCode) async {
    final locale = Locale(languageCode);
    await AppTranslations.load(locale);
    if (!mounted) return;
    setState(() => _locale = locale);
  }

  void _toggleThemeMode() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  LocationPickerStrings _pickerStrings() {
    return LocationPickerStrings(
      title: 'location_picker.title'.tr,
      fetchingLocation: 'location_picker.fetching_location'.tr,
      locationFetchFailed: 'location_picker.location_fetch_failed'.tr,
      unknownLocation: 'location_picker.unknown_location'.tr,
      confirmLocation: 'location_picker.confirm_location'.tr,
      currentLocation: 'location_picker.current_location'.tr,
      noInternet: 'location_picker.no_internet'.tr,
      serviceDisabled: 'location_picker.service_disabled'.tr,
      permissionDenied: 'location_picker.permission_denied'.tr,
      permissionPermanentlyDenied:
          'location_picker.permission_permanently_denied'.tr,
      searchHint: 'location_picker.search_hint'.tr,
      noResults: 'location_picker.no_results'.tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xffEA3433);

    return MaterialApp(
      title: 'Location Picker Example',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      supportedLocales: _languageCodes.map(Locale.new),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: seedColor,
        scaffoldBackgroundColor: const Color(0xffF8FAFB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: seedColor,
        scaffoldBackgroundColor: const Color(0xff111412),
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _ready
          ? HomeScreen(
              languageCodes: _languageCodes,
              languageNames: _languageNames,
              locale: _locale,
              strings: _pickerStrings(),
              themeMode: _themeMode,
              onToggleTheme: _toggleThemeMode,
              onLocaleChanged: _setLocale,
            )
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<String> languageCodes;
  final Map<String, String> languageNames;
  final Locale locale;
  final LocationPickerStrings strings;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final ValueChanged<String> onLocaleChanged;

  const HomeScreen({
    super.key,
    required this.languageCodes,
    required this.languageNames,
    required this.locale,
    required this.strings,
    required this.themeMode,
    required this.onToggleTheme,
    required this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationModel? _selectedLocation;
  Color _accent = const Color(0xffEA3433);
  bool _copied = false;

  static const _accents = <Color>[
    Color(0xffEA3433), // Crimson Red
    Color(0xff2563EB), // Royal Blue
    Color(0xff059669), // Emerald
    Color(0xffD97706), // Amber Gold
    Color(0xff7C3AED), // Violet
  ];

  void _copyCoordinates() {
    if (_selectedLocation?.latLng == null) return;
    final lat = _selectedLocation!.latLng!.latitude.toStringAsFixed(6);
    final lng = _selectedLocation!.latLng!.longitude.toStringAsFixed(6);
    Clipboard.setData(ClipboardData(text: '$lat, $lng'));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData themeIcon;
    switch (widget.themeMode) {
      case ThemeMode.light:
        themeIcon = Icons.light_mode_rounded;
        break;
      case ThemeMode.dark:
        themeIcon = Icons.dark_mode_rounded;
        break;
      case ThemeMode.system:
        themeIcon = Icons.brightness_auto_rounded;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'demo.title'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Tooltip(
            message: 'Toggle theme mode',
            child: IconButton(
              icon: Icon(themeIcon),
              onPressed: widget.onToggleTheme,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.locale.languageCode,
                borderRadius: BorderRadius.circular(12),
                items: [
                  for (final code in widget.languageCodes)
                    DropdownMenuItem(
                      value: code,
                      child: Text(
                        widget.languageNames[code] ?? code,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
                onChanged: (code) {
                  if (code != null) widget.onLocaleChanged(code);
                },
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Location Preview Card ---
                if (_selectedLocation?.latLng != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff1C221D) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.06,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Static interactive map thumbnail preview
                        LocationMapPreview(
                          location: _selectedLocation!.latLng!,
                          height: 200,
                          theme: LocationPickerTheme.fromPrimary(_accent),
                          config: const LocationPickerConfig(
                            tileUrlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'org.osm.location_picker',
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _accent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        color: _accent,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'demo.address'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xff0A100B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _selectedLocation!.address ??
                                    'demo.no_address'.tr,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.4,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : const Color(0xff374151),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.08),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'demo.coordinates'.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.5,
                                                )
                                              : const Color(0xff6B7280),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Text(
                                          '${_selectedLocation!.latLng?.latitude.toStringAsFixed(6)}, ${_selectedLocation!.latLng?.longitude.toStringAsFixed(6)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xff111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: OutlinedButton.icon(
                                      onPressed: _copyCoordinates,
                                      icon: Icon(
                                        _copied
                                            ? Icons.check_rounded
                                            : Icons.copy_rounded,
                                        size: 15,
                                      ),
                                      label: Text(
                                        _copied ? 'Copied' : 'Copy',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _copied
                                            ? Colors.green
                                            : _accent,
                                        side: BorderSide(
                                          color: _copied
                                              ? Colors.green
                                              : _accent.withValues(alpha: 0.5),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xff1C221D).withValues(alpha: 0.6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accent.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.map_rounded,
                              size: 40,
                              color: _accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'demo.no_location'.tr,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xff111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap the button below to pick a location from the map',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.55)
                                : const Color(0xff6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // --- Accent Theme Color Picker ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff181D19) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final color in _accents)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: () => setState(() => _accent = color),
                                customBorder: const CircleBorder(),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: _accent == color ? 34 : 26,
                                  height: _accent == color ? 34 : 26,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    boxShadow: _accent == color
                                        ? [
                                            BoxShadow(
                                              color: color.withValues(
                                                alpha: 0.45,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: _accent == color ? 2.5 : 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- Open Location Picker Action Button ---
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _accent,
                          Color.lerp(_accent, Colors.black, 0.20) ?? _accent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.of(context)
                              .push<LocationModel>(
                                MaterialPageRoute(
                                  builder: (context) => LocationPickerView(
                                    initialLatLng: _selectedLocation?.latLng,
                                    initialAddress: _selectedLocation?.address,
                                    strings: widget.strings,
                                    theme: LocationPickerTheme.fromPrimary(
                                      _accent,
                                      fontFamily: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.fontFamily,
                                      confirmIcon:
                                          const LocationPickerIcon.icon(
                                            Icons.check_rounded,
                                          ),
                                    ),
                                    config: LocationPickerConfig(
                                      tileUrlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      acceptLanguage:
                                          widget.locale.languageCode,
                                      nominatimUserAgent:
                                          'OsmLocationPickerApp/1.0',
                                      userAgentPackageName:
                                          'org.osm.location_picker',
                                    ),
                                  ),
                                ),
                              );
                          if (result != null) {
                            setState(() {
                              _selectedLocation = result;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.explore_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'demo.open'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
