# osm_location_picker

[![pub package](https://img.shields.io/pub/v/osm_location_picker.svg?label=pub)](https://pub.dev/packages/osm_location_picker)
[![pub points](https://img.shields.io/pub/points/osm_location_picker)](https://pub.dev/packages/osm_location_picker/score)
[![Flutter](https://img.shields.io/badge/Flutter-3.0.0%2B-02569B?logo=flutter)](https://flutter.dev/)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-brightgreen)](https://flutter.dev/multi-platform)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/ahmedalam782/osm_location_picker/blob/main/LICENSE)

A creative, modern, and responsive Flutter location picker powered by [OpenStreetMap](https://www.openstreetmap.org/).

> **No API key. No account. No billing.** Everything runs on free, open-source map and geocoding services, making this package an ideal fit for **production apps, prototypes, and indie projects** that don't want the overhead of registering with Google Maps or Mapbox.

Users can pan/zoom the map, search for addresses, and tap to confirm a location. The package returns a `LocationModel` containing the selected address string and `LatLng` coordinates.

---

## 🌟 Highlights & New Features

- ✨ **Creative Glassmorphism Design**: Modern frosted glass surfaces, subtle shadows, and customizable border radiuses.
- 🎯 **Animated Radar Pin**: 3D center pin with ground ripples, lift/drop physics on drag, and a precision coordinate target dot.
- 🕹️ **Floating Action Controls Dock**: Unified frosted glass dock housing **Zoom In (+)**, **Zoom Out (-)**, and **My Location** with smooth hover feedback.
- 📋 **Copyable Coordinates Badge**: Interactive pill showing exact latitude and longitude with one-tap clipboard copy.
- 🎨 **100% Customizable Icons & Colors**: Swap any icon (Material, SVG, PNG, Network, or SVG markup) and define rich gradients or dark/light palettes.
- 🌓 **Dynamic Theme Switching (`forBrightness`)**: Seamlessly adapt any custom theme to dark mode or light mode on the fly with `.forBrightness(Brightness.dark)`.
- 🔄 **Safe Auto-Persistence**: Tapping Back or Confirm preserves the selected location—changes are never lost.
- 🖥️ **Multi-Platform & Keyboard Shortcuts**: Fully responsive on Mobile, Tablet, Desktop, and Web with <kbd>Escape</kbd> to close search and <kbd>Arrow</kbd> navigation.
- 🖼️ **Reliable Map Preview (`LocationMapPreview`)**: Static thumbnail with guaranteed pin visibility, ground shadow, and automatic re-centering.
- 🌍 **RTL & Arabic Friendly**: Reverses address components correctly for RTL languages and formats numbers with proper LTR coordinates.

---

## Quick start

```yaml
dependencies:
  osm_location_picker: ^1.0.4
```

```dart
import 'package:osm_location_picker/osm_location_picker.dart';

final LocationModel? result = await Navigator.of(context).push<LocationModel>(
  MaterialPageRoute(builder: (_) => const LocationPickerView()),
);

if (result != null) {
  print(result.address);          // e.g. "Tahrir Square, Cairo, Egypt"
  print(result.latLng?.latitude);  // 30.044420
  print(result.latLng?.longitude); // 31.235712
}
```

---

## Why this package?

|                    | osm_location_picker | Google Maps based pickers |
| ------------------ | ------------------- | ------------------------- |
| **API key**        | Not needed          | Required                  |
| **Billing account**| Not needed          | Required                  |
| **Setup**          | Add permissions, push a widget | Cloud console project, keys, restrictions |
| **Map data**       | OpenStreetMap       | Google Maps               |
| **Customization**  | Full control over all icons, colors & glassmorphism | Limited to Google Maps styling |
| **Language / RTL** | Any language + native Arabic RTL support | Depends on package |

---

## Platform support

| Platform | Supported | Notes                                                  |
| -------- | --------- | ------------------------------------------------------ |
| Android  | ✅        | Full support                                           |
| iOS      | ✅        | Full support                                           |
| Web      | ✅        | Location uses browser Geolocation API, HTTPS required  |
| macOS    | ✅        | Full support (keyboard shortcuts & hover states)       |
| Windows  | ✅        | Full support (keyboard shortcuts & hover states)       |
| Linux    | ✅        | Full support (keyboard shortcuts & hover states)       |

> **Note:** GPS uses [`geolocator`](https://pub.dev/packages/geolocator). If location is unavailable or denied, the map still opens and the user can search or move the pin by hand.

---

## Platform permissions

#### Android: `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS: `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to show it on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to show it on the map.</string>
```

#### macOS: `macos/Runner/DebugProfile.entitlements` & `Release.entitlements`

```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.personal-information.location</key>
<true/>
```

---

## Usage Guide

### 1. Full-Screen Page Mode

Push it as a route. It returns a `LocationModel?` when the user confirms or navigates back:

```dart
final LocationModel? result = await Navigator.of(context).push<LocationModel>(
  MaterialPageRoute(
    builder: (_) => const LocationPickerView(),
  ),
);
```

### 2. Embeddable Widget Mode

Embed the picker directly inside your layout, modal, or bottom sheet:

```dart
SizedBox(
  height: 420,
  child: LocationPickerView.widget(
    initialLatLng: LatLng(30.0444, 31.2357),
    onConfirmed: (LocationModel location) {
      setState(() => selected = location);
    },
  ),
)
```

### 3. Restore Previously Selected Location

```dart
LocationPickerView(
  initialLatLng: LatLng(30.044420, 31.235712),
  initialAddress: 'Tahrir Square, Cairo, Egypt',
)
```

---

## Theming & Styling

### Palette from Accent Color

Use `LocationPickerTheme.fromPrimary` to generate a harmonious palette automatically:

```dart
LocationPickerView(
  theme: LocationPickerTheme.fromPrimary(
    const Color(0xff2563EB), // Royal Blue
    glassmorphism: true,     // Frosted glass blur effect
    borderRadius: 18.0,      // Smooth rounded corners
  ),
)
```

### Adaptive Dark & Light Modes (`forBrightness`)

Quickly convert any custom theme to dark mode while keeping your custom accent and icons intact:

```dart
final lightTheme = LocationPickerTheme.fromPrimary(const Color(0xff2563EB));

// Automatically converts cards, backgrounds, and borders to dark mode:
final darkTheme = lightTheme.forBrightness(Brightness.dark);

LocationPickerView(
  theme: isDark ? darkTheme : lightTheme,
)
```

Or inherit automatically from ambient app `ThemeData`:

```dart
LocationPickerView(
  theme: LocationPickerTheme.of(context),
)
```

---

## Icon Customization

Every icon in the picker can be replaced using `LocationPickerIcon`:
- `LocationPickerIcon.icon(Icons.your_icon)` — Material / Cupertino
- `LocationPickerIcon.svg('assets/icons/pin.svg')` — SVG asset
- `LocationPickerIcon.asset('assets/images/pin.png')` — PNG / JPEG
- `LocationPickerIcon.network('https://example.com/pin.png')` — Network image
- `LocationPickerIcon.markup('<svg>...</svg>')` — Inlined raw SVG

```dart
LocationPickerTheme(
  pinIcon: const LocationPickerIcon.icon(Icons.location_pin, size: 48),
  searchIcon: const LocationPickerIcon.svg('assets/icons/search.svg'),
  myLocationIcon: const LocationPickerIcon.icon(Icons.gps_fixed),
  confirmIcon: const LocationPickerIcon.icon(Icons.check_rounded),
  zoomInIcon: const LocationPickerIcon.icon(Icons.add),
  zoomOutIcon: const LocationPickerIcon.icon(Icons.remove),
  backIcon: const LocationPickerIcon.icon(Icons.arrow_back),
)
```

---

## Static Map Image Preview (`LocationMapPreview`)

After the user selects a place, display a clean map thumbnail. It features:
- Guaranteed visible center pin (never inverted by dark mode filters)
- Ground contact shadow and coordinate dot
- Dynamic re-centering key so changing locations updates the map instantly

```dart
if (selectedLocation?.latLng != null)
  LocationMapPreview(
    location: selectedLocation!.latLng!,
    height: 180,
    zoom: 16.0,
    borderRadius: BorderRadius.circular(16),
    theme: LocationPickerTheme.fromPrimary(Theme.of(context).primaryColor),
  )
```

---

## Map & Geocoding Configuration

```dart
LocationPickerView(
  config: LocationPickerConfig(
    acceptLanguage: 'ar', // Nominatim response language
    initialZoom: 16,
    maxZoom: 18,
    fallbackCenter: LatLng(30.0444, 31.2357),
    searchLimit: 5,
    nominatimUserAgent: 'MyApp/1.0',
    userAgentPackageName: 'com.example.my_app',
    tileUrlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  ),
)
```

---

## Localization & Arabic Support

All text labels are customizable via `LocationPickerStrings`. The package fully supports LTR and RTL (Arabic) layouts:

```dart
LocationPickerView(
  config: const LocationPickerConfig(acceptLanguage: 'ar'),
  strings: const LocationPickerStrings(
    title: 'تحديد الموقع',
    confirmLocation: 'تأكيد الموقع',
    currentLocation: 'موقعي الحالي',
    searchHint: 'ابحث عن اسم الشارع أو المنطقة...',
    fetchingLocation: 'جاري جلب العنوان...',
  ),
)
```

---

## `LocationModel`

```dart
class LocationModel {
  final String? address; // Human-readable address from Nominatim
  final LatLng? latLng;  // Coordinates (latlong2)
}

// JSON Serialization
final Map<String, dynamic> json = model.toJson();
final LocationModel parsed = LocationModel.fromJson(json);
```

---

## Additional information

- Map tiles © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright). See the [tile usage policy](https://operations.osmfoundation.org/policies/tiles).
- Geocoding provided by [Nominatim](https://nominatim.org/).
- File bugs and feature requests on the [GitHub issue tracker](https://github.com/ahmedalam782/osm_location_picker/issues).
- Contributions are welcome. Open a pull request with tests.

---

# بالعربي

**منتقي مواقع عصري وتفاعلي لـ Flutter يعتمد على OpenStreetMap. بدون API key، بدون حساب، وبدون فواتير.**

المستخدم يحرّك الخريطة ويبحث عن أي عنوان ويضغط لتأكيد الموقع، والباكدج ترجّع `LocationModel` فيه العنوان والإحداثيات بدقة.

### أبرز المميزات الجديدة
- 🎨 **تصميم زجاجي عصري (Glassmorphism)**: تأثير الزجاج الشفاف مع ظلال ناعمة وحواف دائرية أنيقة.
- 📍 **مؤشر تفاعلي بنبضات الرادار (Radar Pin)**: حركة 3D عند تحريك الخريطة مع ظل ملامس للأرض ونقطة إحداثيات دقيقة.
- 🔍 **شريط بحث ذكي**: يدعم اختصارات لوحة المفاتيح (<kbd>Escape</kbd> للإغلاق والأسهم للتنقل).
- 📋 **شريحة نسخ الإحداثيات**: زر مدمج لنسخ خطوط الطول والعرض بنقرة واحدة مع إشعار بالنسخ.
- 🌓 **تحويل فوري للوضع الليلي (`forBrightness`)**: تحويل الثيم للوضع الداكن تلقائياً مع الحفاظ على الألوان والأيقونات المخصصة.
- 🔄 **حفظ التغييرات عند الرجوع**: عند تحريك الموقع والرجوع، لا يتم فقدان الموقع المحدد أبداً.
- 🖼️ **معاينة مصغرة للموقع (`LocationMapPreview`)**: بطاقة خريطة مصغرة مع دبوس ثابت وظل، تدعم الوضع الليلي وتتحدث فورياً مع تغيير الموقع.
- 🌐 **دعم كامل للغة العربية والاتجاه من اليمين لليسار (RTL)**: ترتيب أجزاء العنوان بشكل صحيح وتنسيق الإحداثيات بشكل سليم.

### الاستخدام السريع

```dart
final LocationModel? result = await Navigator.of(context).push<LocationModel>(
  MaterialPageRoute(
    builder: (_) => LocationPickerView(
      config: const LocationPickerConfig(acceptLanguage: 'ar'),
      strings: const LocationPickerStrings(
        title: 'اختر موقع التوصيل',
        confirmLocation: 'تأكيد هذا المكان',
        searchHint: 'ابحث عن عنوان أو معلم...',
      ),
      theme: LocationPickerTheme.fromPrimary(
        const Color(0xff059669),
        glassmorphism: true,
      ),
    ),
  ),
);
```