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

/// Puts every ungrouped spot with coordinates into an area per city, named
/// after the city. Spots go in walkable clusters, so a cluster on a city
/// border stays together, and the city is looked up once per cluster. A city
/// that already has an area (by name) gets the spots added to it; clusters
/// whose city can't be found (e.g. offline) get an area each. New areas are
/// anchored on their central spot and sorted into walking order.
/// Returns the plan as stored.
Future<PilgrimagePlan> autoGroupUngroupedSpots({
  required PilgrimagePlan plan,
  required PilgrimageRepository repository,
  Future<String?> Function(LatLng position) nameAt = cityNameAt,
}) async {
  final ungrouped = plan.points
      .where((point) => point.groupId == null && point.hasCoordinate)
      .toList();
  final clusters = clusterSpotsByDistance(ungrouped);
  if (clusters.isEmpty) return plan;

  // City name (or a fallback per unnamed cluster) -> its spots.
  final spotsByName = <String, List<PilgrimagePoint>>{};
  var unnamed = 0;
  for (final cluster in clusters) {
    final city = (await nameAt(centralSpot(cluster).position))?.trim();
    final name = city == null || city.isEmpty
        ? l10n.autoAreaFallbackName(++unnamed)
        : city;
    (spotsByName[name] ??= []).addAll(cluster);
  }

  final existingByName = {
    for (final group in plan.groups) group.name.trim().toLowerCase(): group,
  };
  var orderIndex = plan.groups.isEmpty
      ? 0
      : plan.groups.map((g) => g.orderIndex).reduce((a, b) => a > b ? a : b) +
            1;
  final now = DateTime.now();
  final groupIdsByPointId = <String, String?>{};
  final ordersByGroupId = <String, List<String>>{};
  var current = plan;
  final byCount = spotsByName.entries.toList()
    ..sort((a, b) => b.value.length - a.value.length);
  for (final (index, MapEntry(key: name, value: spots)) in byCount.indexed) {
    final existing = existingByName[name.trim().toLowerCase()];
    final String groupId;
    if (existing != null) {
      groupId = existing.id;
    } else {
      final anchor = centralSpot(spots);
      groupId = 'group-${now.microsecondsSinceEpoch}-$index';
      current = await repository.createPlanGroup(
        planId: plan.id,
        group: PilgrimagePlanGroup(
          id: groupId,
          name: name,
          orderIndex: orderIndex++,
          anchorPointId: anchor.id,
          anchorName: anchor.name,
          anchorLatitude: anchor.position.latitude,
          anchorLongitude: anchor.position.longitude,
          createdAt: now,
        ),
      );
      // An existing area keeps its own order; new spots join at the end.
      ordersByGroupId[groupId] = [
        for (final spot in walkingOrder(spots)) spot.id,
      ];
    }
    for (final spot in spots) {
      groupIdsByPointId[spot.id] = groupId;
    }
  }
  current = await repository.assignPointsToGroups(
    planId: current.id,
    groupIdsByPointId: groupIdsByPointId,
  );
  for (final MapEntry(key: groupId, value: pointIds)
      in ordersByGroupId.entries) {
    current = await repository.reorderGroupPoints(
      planId: current.id,
      groupId: groupId,
      pointIds: pointIds,
    );
  }
  return current;
}

/// Stores [points] of [groupId] in [walkingOrder]; spots without
/// coordinates keep their order at the end.
Future<PilgrimagePlan> sortAreaIntoWalkingOrder({
  required PilgrimagePlan plan,
  required String groupId,
  required List<PilgrimagePoint> points,
  required PilgrimageRepository repository,
  LatLng? start,
}) {
  return repository.reorderGroupPoints(
    planId: plan.id,
    groupId: groupId,
    pointIds: [
      for (final spot in walkingOrder(
        points.where((p) => p.hasCoordinate).toList(),
        start: start,
      ))
        spot.id,
      for (final spot in points.where((p) => !p.hasCoordinate)) spot.id,
    ],
  );
}

/// [spots] in a walking order. With [start] (where the walk begins, e.g. the
/// station): the spot closest to it, then the spot closest to that, and so
/// on. Without it: a short open path that avoids crossing back over itself,
/// starting at whichever end makes the walk shortest. Straight-line
/// distances; good enough to stop a walk zig-zagging across town.
List<PilgrimagePoint> walkingOrder(
  List<PilgrimagePoint> spots, {
  LatLng? start,
}) {
  if (spots.length < 2 || (start == null && spots.length < 3)) {
    return List.of(spots);
  }
  // With a start, it is node 0, fixed at the front, and dropped at the end.
  final positions = [?start, for (final spot in spots) spot.position];
  final first = start == null ? 0 : 1;
  final n = positions.length;
  const distance = Distance();
  final d = [
    for (final a in positions) [for (final b in positions) distance(a, b)],
  ];
  double length(List<int> path) {
    var total = 0.0;
    for (var i = 1; i < path.length; i++) {
      total += d[path[i - 1]][path[i]];
    }
    return total;
  }

  // ponytail: nearest neighbour from every start plus 2-opt is O(n³); fine
  // for an area's few dozen spots.
  List<int>? best;
  for (final origin in start == null ? List.generate(n, (i) => i) : [0]) {
    final path = [origin];
    final left = {for (var i = 0; i < n; i++) i}..remove(origin);
    while (left.isNotEmpty) {
      final next = left.reduce(
        (a, b) => d[path.last][a] <= d[path.last][b] ? a : b,
      );
      path.add(next);
      left.remove(next);
    }
    if (best == null || length(path) < length(best)) best = path;
  }
  final path = best!;
  // From a chosen start, closest-next is the order asked for: don't trade it
  // for a shorter total that leaves nearby spots for later.
  for (var improved = start == null; improved;) {
    improved = false;
    for (var i = first; i < n - 1; i++) {
      for (var j = i + 1; j < n; j++) {
        // Reverse path[i..j]; only the edges at either end change.
        final before =
            (i > 0 ? d[path[i - 1]][path[i]] : 0) +
            (j < n - 1 ? d[path[j]][path[j + 1]] : 0);
        final after =
            (i > 0 ? d[path[i - 1]][path[j]] : 0) +
            (j < n - 1 ? d[path[i]][path[j + 1]] : 0);
        if (after < before - 0.01) {
          path.setRange(i, j + 1, path.sublist(i, j + 1).reversed);
          improved = true;
        }
      }
    }
  }
  return [for (final i in path.skip(first)) spots[i - first]];
}

/// How many ungrouped spots of [before] are in an area in [after], the
/// areas they went into (in plan order), for the message after grouping.
({int spots, List<String> areaIds}) groupedResult(
  PilgrimagePlan before,
  PilgrimagePlan after,
) {
  final wasUngrouped = {
    for (final point in before.points)
      if (point.groupId == null) point.id,
  };
  final areaIds = <String>{};
  var spots = 0;
  for (final point in after.points) {
    if (wasUngrouped.contains(point.id) && point.groupId != null) {
      spots++;
      areaIds.add(point.groupId!);
    }
  }
  final order = {
    for (final (i, group) in after.groups.indexed)
      group.id: group.orderIndex * 100000 + i,
  };
  return (
    spots: spots,
    areaIds: areaIds.toList()..sort((a, b) => order[a]!.compareTo(order[b]!)),
  );
}
