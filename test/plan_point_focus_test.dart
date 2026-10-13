import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:miriago/app_theme.dart';
import 'package:miriago/data/sample_pilgrimage_repository.dart';
import 'package:miriago/plan/pilgrimage_models.dart';
import 'package:miriago/plan/pilgrimage_plan_controller.dart';
import 'package:miriago/plan/plan_screen.dart';

/// Shows one area long enough that its later rows are not built at first.
Future<PilgrimagePlanController> _pumpLongArea(
  WidgetTester tester, {
  Future<void> Function(PilgrimagePlanController controller)? onOpenAddPoints,
}) async {
  final repository = SamplePilgrimageRepository();
  final sample = await repository.loadActivePlan();
  final seed = sample.points.firstWhere(
    (point) => point.groupId == sample.currentGroupId,
  );
  final controller = PilgrimagePlanController(
    plan: sample.copyWith(
      points: [
        for (var i = 0; i < 30; i++)
          seed.copyWith(
            id: 'long-$i',
            name: 'Spot $i',
            position: LatLng(
              seed.position.latitude + i * 0.0001,
              seed.position.longitude,
            ),
          ),
      ],
    ),
    visitRepository: repository,
  );
  addTearDown(controller.dispose);

  await tester.binding.setSurfaceSize(const Size(430, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: PlanScreen(
        controller: controller,
        repository: repository,
        settings: const AppSettings(),
        onOpenMap: () {},
        onOpenPlanManager: () {},
        onOpenAddPoints: () async => onOpenAddPoints?.call(controller),
        onOpenImportExport: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

Rect _rowRect(WidgetTester tester, String name) => tester.getRect(
  find
      .ancestor(
        of: find.descendant(
          of: find.byType(ReorderableListView),
          matching: find.text(name),
        ),
        matching: find.byType(InkWell),
      )
      .first,
);

void main() {
  testWidgets('tapping a map marker scrolls its row to the top of the list', (
    tester,
  ) async {
    await _pumpLongArea(tester);
    await tester.tap(find.text('地图'));
    await tester.pumpAndSettle();
    expect(find.text('Spot 20'), findsNothing);

    final marker = find.byKey(const ValueKey('plan-map-marker-long-20'));
    tester
        .widget<GestureDetector>(
          find
              .ancestor(of: marker, matching: find.byType(GestureDetector))
              .first,
        )
        .onTap!();
    await tester.pumpAndSettle();

    // The tapped spot becomes the first row.
    expect(
      _rowRect(tester, 'Spot 20').top,
      moreOrLessEquals(tester.getRect(find.byType(ReorderableListView)).top),
    );
  });

  testWidgets('adding spots selects the first new one and shows its row', (
    tester,
  ) async {
    final controller = await _pumpLongArea(
      tester,
      onOpenAddPoints: (controller) async {
        final plan = controller.plan;
        controller.replacePlan(
          plan.copyWith(
            points: [
              ...plan.points,
              plan.points.first.copyWith(id: 'added', name: 'Added spot'),
            ],
          ),
        );
      },
    );

    await tester.tap(find.byKey(const ValueKey('plan-add-points-button')));
    await tester.pumpAndSettle();

    expect(controller.selectedPoint?.id, 'added');
    final list = tester.getRect(find.byType(ReorderableListView));
    final row = _rowRect(tester, 'Added spot');
    expect(row.top, greaterThanOrEqualTo(list.top));
    expect(row.bottom, lessThanOrEqualTo(list.bottom));
  });
}
