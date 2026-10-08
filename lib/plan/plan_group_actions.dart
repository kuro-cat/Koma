import 'package:flutter/material.dart';

import '../data/pilgrimage_repository.dart';
import '../widgets/app_scaled_route.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/input_dialog.dart';
import '../widgets/keyboard_dismiss_on_tap.dart';
import 'group_anchor_picker_screen.dart';
import 'pilgrimage_models.dart';
import '../l10n/l10n.dart';

/// A repository call that saves an area change and returns the new plan.
typedef PlanChange = Future<PilgrimagePlan> Function();

// Area actions shared by the Plan tab and Manage areas. Each asks the user
// what it needs and returns the change to save, or null when cancelled.

Future<PlanChange?> renameAreaChange(
  BuildContext context,
  PilgrimageRepository repository,
  PilgrimagePlan plan,
  PilgrimagePlanGroup group,
) async {
  // The dialog owns its controller: disposing it here, while the closing
  // dialog's TextField is still animating out, trips IME assertions.
  final name = (await showDialog<String>(
    context: context,
    builder: (context) => AreaNameDialog(
      title: l10n.planGroupManagerRenameTitle,
      confirmLabel: l10n.commonSave,
      initialName: group.name,
    ),
  ))?.trim();
  if (name == null || name.isEmpty || name == group.name) {
    return null;
  }
  return () => repository.renamePlanGroup(
    planId: plan.id,
    groupId: group.id,
    name: name,
  );
}

PlanChange toggleAreaOrderChange(
  PilgrimageRepository repository,
  PilgrimagePlan plan,
  PilgrimagePlanGroup group,
) {
  final nextMode = group.orderMode == PlanGroupOrderMode.manual
      ? PlanGroupOrderMode.unordered
      : PlanGroupOrderMode.manual;
  return () => repository.updatePlanGroup(
    planId: plan.id,
    group: _copyGroup(group, orderMode: nextMode),
  );
}

Future<PlanChange?> setAreaAnchorChange(
  BuildContext context,
  PilgrimageRepository repository,
  PilgrimagePlan plan,
  PilgrimagePlanGroup group,
) async {
  final settings = await repository.loadAppSettings();
  if (!context.mounted) {
    return null;
  }
  final selection = await Navigator.of(context).push<GroupAnchorSelection>(
    appScaledMaterialPageRoute<GroupAnchorSelection>(
      settings: settings,
      builder: (_) => GroupAnchorPickerScreen(
        group: group,
        points: plan.points,
        groupNameForPoint: (point) => _groupNameForPoint(plan, point),
        settings: settings,
      ),
    ),
  );
  if (selection == null) {
    return null;
  }
  return () => repository.updatePlanGroup(
    planId: plan.id,
    group: _copyGroup(
      group,
      anchorName: selection.name,
      anchorLatitude: selection.position?.latitude,
      anchorLongitude: selection.position?.longitude,
      anchorPointId: selection.pointId,
    ),
  );
}

Future<PlanChange?> deleteAreaChange(
  BuildContext context,
  PilgrimageRepository repository,
  PilgrimagePlan plan,
  PilgrimagePlanGroup group,
) async {
  final pointCount = plan.points
      .where((point) => point.groupId == group.id)
      .length;
  final confirmed = await showConfirmActionDialog(
    context,
    title: l10n.planGroupManagerDeleteArea,
    message: l10n.planGroupManagerDeleteMessage(group.name, pointCount),
    confirmLabel: l10n.commonDelete,
    destructive: true,
    emphasizedValues: [group.name],
  );
  if (!confirmed) {
    return null;
  }
  return () => repository.deletePlanGroup(planId: plan.id, groupId: group.id);
}

const Object _unset = Object();

PilgrimagePlanGroup _copyGroup(
  PilgrimagePlanGroup group, {
  PlanGroupOrderMode? orderMode,
  Object? anchorName = _unset,
  Object? anchorLatitude = _unset,
  Object? anchorLongitude = _unset,
  Object? anchorPointId = _unset,
}) {
  return PilgrimagePlanGroup(
    id: group.id,
    name: group.name,
    orderIndex: group.orderIndex,
    orderMode: orderMode ?? group.orderMode,
    anchorName: anchorName == _unset ? group.anchorName : anchorName as String?,
    anchorLatitude: anchorLatitude == _unset
        ? group.anchorLatitude
        : anchorLatitude as double?,
    anchorLongitude: anchorLongitude == _unset
        ? group.anchorLongitude
        : anchorLongitude as double?,
    anchorPointId: anchorPointId == _unset
        ? group.anchorPointId
        : anchorPointId as String?,
    note: group.note,
    createdAt: group.createdAt,
  );
}

String _groupNameForPoint(PilgrimagePlan plan, PilgrimagePoint point) {
  final groupId = point.groupId;
  if (groupId == null) {
    return l10n.planGroupManagerUngroupedSpots;
  }
  return plan.groups.where((group) => group.id == groupId).firstOrNull?.name ??
      l10n.planGroupManagerUnknownArea;
}

class AreaNameDialog extends StatefulWidget {
  const AreaNameDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    this.initialName = '',
  });

  final String title;
  final String confirmLabel;
  final String initialName;

  @override
  State<AreaNameDialog> createState() => AreaNameDialogState();
}

class AreaNameDialogState extends State<AreaNameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmedName = _controller.text.trim();
    if (trimmedName.isEmpty) {
      setState(() {
        _errorText = l10n.planGroupManagerNameRequired;
      });
      return;
    }
    Navigator.of(context).pop(trimmedName);
  }

  @override
  Widget build(BuildContext context) {
    return AppInputDialog(
      title: widget.title,
      content: AppDialogField(
        label: l10n.planGroupManagerNameLabel,
        child: TextField(
          onTapOutside: dismissKeyboardOnTapOutside,
          key: const ValueKey('plan-group-name-field'),
          controller: _controller,
          autofocus: true,
          decoration: appDialogInputDecoration(errorText: _errorText),
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_errorText == null) {
              return;
            }
            setState(() {
              _errorText = null;
            });
          },
          onSubmitted: (_) => _submit(),
        ),
      ),
      confirmLabel: widget.confirmLabel,
      onConfirm: _submit,
    );
  }
}
