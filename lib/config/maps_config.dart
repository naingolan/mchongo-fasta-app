import 'package:flutter/widgets.dart';

/// Google Maps setup for MchongoFasta.
///
/// 1. Create a Maps SDK key in Google Cloud (enable Maps SDK for Android + iOS).
/// 2. Android: add to `android/local.properties`:
///    `MAPS_API_KEY=your_key_here`
/// 3. iOS: copy `ios/Flutter/MapsSecrets.xcconfig.example` to
///    `ios/Flutter/MapsSecrets.xcconfig` and set `MAPS_API_KEY=your_key_here`.
class MapsConfig {
  /// Set true in widget tests so platform GoogleMap views are skipped.
  static bool forceDisable = false;

  static bool get isAvailable {
    if (forceDisable) return false;
    return !WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
  }
}
