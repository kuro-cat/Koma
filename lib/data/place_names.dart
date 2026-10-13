import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../l10n/l10n.dart';

/// Lookups so far, by rounded position and language.
final _cityCache = <String, String?>{};

/// The city (or ward) at [position] from the phone's geocoder, in the app's
/// language. Null off Android/iOS, offline, or when nothing is found.
Future<String?> cityNameAt(LatLng position) async {
  final mobile =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (!mobile) return null;
  final language = l10n.localeName;
  final key =
      '${position.latitude.toStringAsFixed(3)},'
      '${position.longitude.toStringAsFixed(3)},$language';
  if (_cityCache.containsKey(key)) return _cityCache[key];
  String? city;
  try {
    final places = await Geocoding(
      locale: Locale(language),
    ).placemarkFromCoordinates(position.latitude, position.longitude);
    final place = places.firstOrNull;
    city = [
      place?.locality,
      place?.subAdministrativeArea,
      place?.administrativeArea,
    ].map((name) => name?.trim() ?? '').where((name) => name.isNotEmpty).firstOrNull;
  } catch (_) {
    return null; // Offline or no geocoder: try again next time.
  }
  return _cityCache[key] = city;
}

/// The cities of [positions], the one with the most positions first.
Future<List<String>> cityNamesFor(Iterable<LatLng> positions) async {
  // Spots within about a kilometre share a lookup.
  // ponytail: at most 12 lookups, so a box over many towns may miss the
  // smallest ones; sample more if that matters.
  final cells = <String, (LatLng, int)>{};
  for (final position in positions) {
    final key =
        '${position.latitude.toStringAsFixed(2)},'
        '${position.longitude.toStringAsFixed(2)}';
    final cell = cells[key];
    cells[key] = (cell?.$1 ?? position, (cell?.$2 ?? 0) + 1);
  }
  final sampled = cells.values.toList()..sort((a, b) => b.$2 - a.$2);
  final counts = <String, int>{};
  for (final (position, count) in sampled.take(12)) {
    final city = await cityNameAt(position);
    if (city != null) counts[city] = (counts[city] ?? 0) + count;
  }
  return counts.keys.toList()..sort((a, b) => counts[b]! - counts[a]!);
}
