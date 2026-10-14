import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:miriago/data/sample_pilgrimage_repository.dart';
import 'package:miriago/plan/auto_areas.dart';
import 'package:miriago/plan/pilgrimage_models.dart';

void main() {
  // 0.001° latitude is about 111 m.
  PilgrimagePoint spot(String id, double lat, double lon) =>
      samplePilgrimagePlan.points.first.copyWith(
        id: id,
        name: id,
        position: LatLng(lat, lon),
        groupId: null,
      );

  test('spots a short walk apart share an area, even through a chain', () {
    final clusters = clusterSpotsByDistance([
      spot('a', 34.000, 132.0),
      spot('b', 34.005, 132.0), // 555 m from a
      spot('c', 34.010, 132.0), // 555 m from b, 1.1 km from a
      spot('far', 34.100, 132.0),
    ]);

    expect(clusters.map((c) => c.map((s) => s.id).toSet()), [
      {'a', 'b', 'c'},
      {'far'},
    ]);
  });

  test('grouping makes one area per city', () async {
    final plan = samplePilgrimagePlan.copyWith(
      groups: const [],
      points: [
        spot('a', 34.000, 132.0),
        spot('b', 34.002, 132.0),
        spot('c', 34.004, 132.0),
        spot('far', 34.100, 132.0),
        spot('far2', 34.200, 132.0),
      ],
    );
    final repository = SamplePilgrimageRepository(plans: [plan]);

    final grouped = await autoGroupUngroupedSpots(
      plan: plan,
      repository: repository,
      nameAt: (position) async => position.latitude < 34.05 ? '忠海' : '竹原',
    );

    expect(grouped.points.every((p) => p.groupId != null), isTrue);
    final names = {
      for (final group in grouped.groups)
        group.name: grouped.points
            .where((p) => p.groupId == group.id)
            .map((p) => p.id)
            .toSet(),
    };
    expect(names, {
      '忠海': {'a', 'b', 'c'},
      // Two clusters far apart, but both in 竹原: one area.
      '竹原': {'far', 'far2'},
    });
  });

  test('spots in a city that already has an area join it', () async {
    final takehara = PilgrimagePlanGroup(
      id: 'takehara',
      name: '竹原',
      orderIndex: 0,
      createdAt: DateTime(2026),
    );
    final plan = samplePilgrimagePlan.copyWith(
      groups: [takehara],
      points: [spot('a', 34.0, 132.0), spot('b', 34.001, 132.0)],
    );
    final repository = SamplePilgrimageRepository(plans: [plan]);

    final grouped = await autoGroupUngroupedSpots(
      plan: plan,
      repository: repository,
      nameAt: (_) async => '竹原',
    );

    expect(grouped.groups.map((g) => g.id), ['takehara']);
    expect(grouped.points.map((p) => p.groupId), everyElement('takehara'));
    final result = groupedResult(plan, grouped);
    expect(result.spots, 2);
    expect(result.areaIds, ['takehara']);
  });

  test('walking order visits spots along a street without doubling back', () {
    final street = [
      for (var i = 0; i < 8; i++) spot('s$i', 34.0 + i * 0.001, 132.0),
    ];
    final shuffled = [5, 0, 7, 2, 6, 1, 3, 4].map((i) => street[i]).toList();

    final ids = walkingOrder(shuffled).map((s) => s.id).toList();

    final forward = [for (var i = 0; i < 8; i++) 's$i'];
    expect(ids, anyOf(equals(forward), equals(forward.reversed.toList())));
  });

  test('a walk from a chosen start begins at the nearby end', () {
    final street = [
      for (var i = 0; i < 8; i++) spot('s$i', 34.0 + i * 0.001, 132.0),
    ];
    final shuffled = [5, 0, 7, 2, 6, 1, 3, 4].map((i) => street[i]).toList();

    // The station is just past s7.
    final ids = walkingOrder(
      shuffled,
      start: const LatLng(34.0085, 132.0),
    ).map((s) => s.id).toList();

    expect(ids, [for (var i = 7; i >= 0; i--) 's$i']);
  });

  test('from a chosen start, each next spot is the closest one left', () {
    // On a line, 1 unit = 0.001°. Start at 0; spots at 1, 3 and -1.5.
    // Closest-next: 1, then 3 (2 away, -1.5 is 2.5), then -1.5, though
    // -1.5, 1, 3 would be a shorter walk.
    final spots = [
      spot('minus', 34.0, 132.0 - 0.0015),
      spot('one', 34.0, 132.001),
      spot('three', 34.0, 132.003),
    ];

    final ids = walkingOrder(
      spots,
      start: const LatLng(34.0, 132.0),
    ).map((s) => s.id).toList();

    expect(ids, ['one', 'three', 'minus']);
  });

  test('grouped areas come in walking order', () async {
    final street = [
      for (var i = 0; i < 6; i++) spot('s$i', 34.0 + i * 0.001, 132.0),
    ];
    final plan = samplePilgrimagePlan.copyWith(
      groups: const [],
      points: [4, 1, 5, 0, 3, 2].map((i) => street[i]).toList(),
    );
    final repository = SamplePilgrimageRepository(plans: [plan]);

    final grouped = await autoGroupUngroupedSpots(
      plan: plan,
      repository: repository,
      nameAt: (_) async => '竹原',
    );

    final ordered = [...grouped.points]
      ..sort((a, b) => a.groupOrderIndex!.compareTo(b.groupOrderIndex!));
    final forward = [for (var i = 0; i < 6; i++) 's$i'];
    expect(
      ordered.map((p) => p.id).toList(),
      anyOf(equals(forward), equals(forward.reversed.toList())),
    );
  });
}
