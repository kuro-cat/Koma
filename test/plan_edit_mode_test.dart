import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miriago/app_theme.dart';
import 'package:miriago/data/sample_pilgrimage_repository.dart';
import 'package:miriago/plan/pilgrimage_models.dart';
import 'package:miriago/plan/pilgrimage_plan_controller.dart';
import 'package:miriago/plan/plan_group_utils.dart';
import 'package:miriago/plan/plan_screen.dart';

void main() {
  testWidgets('edit mode moves the selected spots to another area', (
    tester,
  ) async {
    final repository = SamplePilgrimageRepository();
    final plan = await repository.loadActivePlan();
    final controller = PilgrimagePlanController(
      plan: plan,
      visitRepository: repository,
    );
    addTearDown(controller.dispose);
    final buckets = planGroupBuckets(plan, plan.completedPointIds);
    final from = buckets.first;
    final target = plan.groups.firstWhere((group) => group.id != from.id);
    final moved = from.points.first;

    await tester.binding.setSurfaceSize(const Size(430, 900));
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
          onOpenAddPoints: () async {},
          onOpenImportExport: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Long-pressing a row enters edit mode with that row selected.
    await tester.longPress(find.text(moved.name).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('plan-edit-bar')), findsOneWidget);

    await tester.tap(find.text('移动'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey('plan-point-group-option-${target.name}')),
    );
    await tester.pumpAndSettle();

    final stored = await repository.loadActivePlan();
    expect(
      stored.points.firstWhere((point) => point.id == moved.id).groupId,
      target.id,
    );
    expect(
      controller.plan.points.firstWhere((p) => p.id == moved.id).groupId,
      target.id,
    );
    // A finished move leaves edit mode.
    expect(find.byKey(const ValueKey('plan-edit-bar')), findsNothing);
  });
}
