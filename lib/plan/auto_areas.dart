import 'package:latlong2/latlong.dart';

import '../data/pilgrimage_repository.dart';
import '../data/place_names.dart';
import '../l10n/l10n.dart';
import 'pilgrimage_models.dart';

/// Spots closer than this end up in the same area: about a 10 minute walk.
const autoAreaLinkMeters = 600.0;

/// Splits [spots] into walkable clusters: two spots share a cluster when a
/// chain of spots, each within [linkMeters] of the next, joins them. Largest
/// cluster first.
List<List<PilgrimagePoint>> clusterSpotsByDistance(
  List<PilgrimagePoint> spots, {
  double linkMeters = autoAreaLinkMeters,
}) {
  // ponytail: O(n²) distance checks, fine for a few hundred spots; use a
  // grid index if plans reach thousands.
  const distance = Distance();
  final parent = List<int>.generate(spots.length, (i) => i);
  int root(int i) {
    while (parent[i] != i) {
      i = parent[i] = parent[parent[i]];
    }
    return i;
  }

  for (var i = 0; i < spots.length; i++) {
    for (var j = i + 1; j < spots.length; j++) {
      if (distance(spots[i].position, spots[j].position) <= linkMeters) {
        parent[root(i)] = root(j);
      }
    }
  }
  final clusters = <int, List<PilgrimagePoint>>{};
  for (var i = 0; i < spots.length; i++) {
    (clusters[root(i)] ??= []).add(spots[i]);
  }
  return clusters.values.toList()..sort((a, b) => b.length - a.length);
}

/// The spot with the shortest total distance to the others.
PilgrimagePoint centralSpot(List<PilgrimagePoint> cluster) {
  const distance = Distance();
  PilgrimagePoint? best;
  var bestTotal = double.infinity;
  for (final spot in cluster) {
    var total = 0.0;
    for (final other in cluster) {
      total += distance(spot.position, other.position);
    }
    if (total < bestTotal) {
      best = spot;
      bestTotal = total;
    }
  }
  return best!;
}

/// Puts every ungrouped spot with coordinates into a new area per walkable
/// cluster, named after the district at its central spot (which also
/// becomes its anchor). Returns the plan as stored.
Future<PilgrimagePlan> autoGroupUngroupedSpots({
  required PilgrimagePlan plan,
  required PilgrimageRepository repository,
  Future<String?> Function(LatLng position) nameAt = districtNameAt,
}) async {
  final ungrouped = plan.points
      .where((point) => point.groupId == null && point.hasCoordinate)
      .toList();
  final clusters = clusterSpotsByDistance(ungrouped);
  if (clusters.isEmpty) return plan;

  final usedNames = {for (final group in plan.groups) group.name};
  var orderIndex = plan.groups.isEmpty
      ? 0
      : plan.groups.map((g) => g.orderIndex).reduce((a, b) => a > b ? a : b) +
            1;
  final now = DateTime.now();
  final groupIdsByPointId = <String, String?>{};
  var current = plan;
  for (final (index, cluster) in clusters.indexed) {
    final anchor = centralSpot(cluster);
    final base =
        await nameAt(anchor.position) ?? l10n.autoAreaFallbackName(index + 1);
    // A second area in the same district is told apart by its central spot.
    var name = usedNames.contains(base) ? '$base · ${anchor.name}' : base;
    for (var n = 2; usedNames.contains(name); n++) {
      name = '$base $n';
    }
    usedNames.add(name);
    final group = PilgrimagePlanGroup(
      id: 'group-${now.microsecondsSinceEpoch}-$index',
      name: name,
      orderIndex: orderIndex++,
      anchorPointId: anchor.id,
      anchorName: anchor.name,
      anchorLatitude: anchor.position.latitude,
      anchorLongitude: anchor.position.longitude,
      createdAt: now,
    );
    current = await repository.createPlanGroup(planId: plan.id, group: group);
    for (final spot in cluster) {
      groupIdsByPointId[spot.id] = group.id;
    }
  }
  return repository.assignPointsToGroups(
    planId: current.id,
    groupIdsByPointId: groupIdsByPointId,
  );
}
