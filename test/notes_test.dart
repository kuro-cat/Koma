import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miriago/app_theme.dart';
import 'package:miriago/data/sample_pilgrimage_repository.dart';
import 'package:miriago/main.dart';
import 'package:miriago/plan/pilgrimage_models.dart';
import 'package:miriago/plan/pilgrimage_plan_controller.dart';
import 'package:miriago/point_detail/point_detail_sheet.dart';

void main() {
  testWidgets('a note added on the spot sheet is saved and shown', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = SamplePilgrimageRepository();
    final plan = await repository.loadActivePlan();
    final point = plan.points.first.copyWith(note: null);
    final controller = PilgrimagePlanController(
      plan: plan,
      visitRepository: repository,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => PointDetailSheet.show(
                context,
                point: point,
                status: VisitStatus.pending,
                onReplaceReference: (_, _) async {},
                planController: controller,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('point-detail-add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('note-dialog-field')),
      '17:00 关门',
    );
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final saved = (await repository.loadActivePlan()).points.firstWhere(
      (p) => p.id == point.id,
    );
    expect(saved.note, '17:00 关门');
    expect(find.byKey(const ValueKey('point-detail-note')), findsOneWidget);
    expect(find.text('17:00 关门'), findsOneWidget);
  });

  testWidgets('an area note shows under the area switcher', (tester) async {
    final repository = SamplePilgrimageRepository();
    final plan = await repository.loadActivePlan();
    final group = plan.groups.first;
    await repository.updatePlanGroup(
      planId: plan.id,
      group: group.copyWith(note: '渡轮 9:10 出发'),
    );
    await repository.setCurrentGroup(planId: plan.id, groupId: group.id);
    await tester.pumpWidget(MiriaGoApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('plan-area-note')), findsOneWidget);
    expect(find.text('渡轮 9:10 出发'), findsOneWidget);
  });

  testWidgets('the area map numbers spots in order and flags the start', (
    tester,
  ) async {
    final repository = SamplePilgrimageRepository();
    final plan = await repository.loadActivePlan();
    final area = plan.groups.first;
    final spots = plan.points.where((p) => p.groupId == area.id).toList()
      ..sort((a, b) => a.groupOrderIndex!.compareTo(b.groupOrderIndex!));
    await repository.updatePlanGroup(
      planId: plan.id,
      group: area.copyWith(
        startName: 'Station',
        startLatitude: spots.first.position.latitude,
        startLongitude: spots.first.position.longitude,
      ),
    );
    await repository.setCurrentGroup(planId: plan.id, groupId: area.id);
    await tester.pumpWidget(MiriaGoApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, '地图'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('plan-map-start')), findsOneWidget);
    final second = find.byKey(ValueKey('plan-map-marker-${spots[1].id}'));
    expect(
      find.descendant(of: second, matching: find.text('2')),
      findsOneWidget,
    );
  });
}
