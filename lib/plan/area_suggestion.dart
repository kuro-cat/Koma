import 'package:latlong2/latlong.dart';

import '../data/place_names.dart';
import 'pilgrimage_models.dart';
import 'plan_group_utils.dart';

/// How far the nearest area may be and still be suggested.
const areaSuggestionMaxMeters = 5000.0;

/// The area [spots] most likely belong in: one named after their city, or
/// else the nearest area within [areaSuggestionMaxMeters]. Null if neither.
Future<PilgrimagePlanGroup?> suggestAreaForSpots(
  PilgrimagePlan plan,
  List<PilgrimagePoint> spots,
) async {
  final placed = spots.where((spot) => spot.hasCoordinate).toList();
  if (plan.groups.isEmpty || placed.isEmpty) return null;
  final cities = await cityNamesFor(placed.map((spot) => spot.position));
  return matchAreaForSpots(plan, placed, cities);
}

/// [suggestAreaForSpots] once the spots' [cities] are known.
PilgrimagePlanGroup? matchAreaForSpots(
  PilgrimagePlan plan,
  List<PilgrimagePoint> spots,
  List<String> cities,
) {
  final groups = sortGroupsByPlanOrder(plan.groups);
  for (final city in cities) {
    final key = _placeKey(city);
    for (final group in groups) {
      if (_placeKey(group.name) == key) return group;
    }
  }

  final placed = spots.where((spot) => spot.hasCoordinate).toList();
  if (placed.isEmpty) return null;
  final center = LatLng(
    placed.map((spot) => spot.position.latitude).reduce((a, b) => a + b) /
        placed.length,
    placed.map((spot) => spot.position.longitude).reduce((a, b) => a + b) /
        placed.length,
  );
  const distance = Distance();
  final spotIds = {for (final spot in spots) spot.id};
  PilgrimagePlanGroup? nearest;
  var nearestMeters = areaSuggestionMaxMeters;
  for (final group in groups) {
    final members = plan.points.where(
      (point) =>
          point.groupId == group.id &&
          point.hasCoordinate &&
          !spotIds.contains(point.id),
    );
    for (final position in members.map((p) => p.position)) {
      final meters = distance(center, position);
      if (meters <= nearestMeters) {
        nearest = group;
        nearestMeters = meters;
      }
    }
  }
  return nearest;
}

/// "Uji", "uji city", "宇治市" and "宇治" all compare equal.
String _placeKey(String name) => name
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'\s+(city|ward|town|village)$'), '')
    .replaceAll(RegExp(r'[市区町村]$'), '');
