import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../data/app_file_reclamation.dart';
import '../data/pilgrimage_repository.dart';
import '../plan_transfer/import_export_screen.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/input_dialog.dart';
import '../widgets/copyable_text.dart';
import '../widgets/route_planner_skill_hint.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/app_back_button.dart';
import 'pilgrimage_models.dart';
import '../widgets/menu_back_scope.dart';
import '../widgets/rules.dart';

Widget _cleanPlanReorderProxy(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final elevation = Curves.easeOut.transform(animation.value) * 10;
      return Material(
        key: const ValueKey('plan-reorder-proxy'),
        color: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        elevation: elevation,
        borderRadius: BorderRadius.zero,
        child: child,
      );
    },
    child: child,
  );
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({required this.repository, super.key});

  final PilgrimageRepository repository;

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<PilgrimagePlan>? _plans;
  PilgrimagePlan? _activePlan;
  Object? _error;
  String? _switchingPlanId;
  bool _sorting = false;
  bool _savingOrder = false;
  String? _expandedPlanId;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _error = null;
    });

    try {
      final plans = await widget.repository.loadPlans();
      final activePlan = plans.isEmpty
          ? null
          : await widget.repository.loadActivePlan();
      if (!mounted) {
        return;
      }

      setState(() {
        _plans = plans;
        _activePlan = activePlan;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
      });
    }
  }

  Future<void> _switchPlan(PilgrimagePlan plan) async {
    if (_switchingPlanId != null) {
      return;
    }
    setState(() => _switchingPlanId = plan.id);

    var switched = false;
    try {
      await widget.repository.setActivePlan(plan.id);
      switched = true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.planManagerSwitchFailed,
        );
      }
    }
    if (!mounted) {
      return;
    }
    setState(() => _switchingPlanId = null);

    if (switched) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _createEmptyPlan() async {
    final created = await createPlanFromInfoForm(
      context,
      widget.repository,
      defaultName: l10n.planManagerNewPlanName((_plans?.length ?? 0) + 1),
    );
    if (created != null) {
      await _loadPlans();
    }
  }

  Future<void> _deletePlan(PilgrimagePlan plan) async {
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.planManagerDeletePlan,
      message: l10n.planManagerDeleteMessage(plan.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
      emphasizedValues: [plan.name],
    );
    if (!confirmed || !mounted) {
      return;
    }

    try {
      await deletePlanReclaimingFiles(
        repository: widget.repository,
        planId: plan.id,
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.planManagerDeleteFailed,
        );
      }
    }
    await _loadPlans();
  }

  Future<void> _editPlanInfo(PilgrimagePlan plan) async {
    // The dialog owns its controllers so they outlive its exit animation.
    final result = await showDialog<_PlanInfoFormResult>(
      context: context,
      builder: (context) => _PlanInfoDialog(
        title: l10n.planManagerEditInfo,
        name: plan.name,
        area: plan.area,
        memo: plan.memo,
      ),
    );
    if (result == null || result.name.isEmpty) {
      return;
    }

    final area = result.area.isEmpty ? l10n.planManagerAreaNotSet : result.area;
    if (result.name != plan.name || area != plan.area) {
      await widget.repository.updatePlanInfo(
        planId: plan.id,
        name: result.name,
        area: area,
      );
    }
    if (result.memo != plan.memo) {
      await widget.repository.updatePlanMemo(
        planId: plan.id,
        memo: result.memo,
      );
    }
    await _loadPlans();
  }

  Future<void> _openImportExport(PilgrimagePlan plan) async {
    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            ImportExportScreen(plan: plan, repository: widget.repository),
      ),
    );
    if (imported == true) {
      await _loadPlans();
    }
  }

  Future<void> _duplicatePlan(PilgrimagePlan plan) async {
    try {
      final visitRecords = await widget.repository.loadVisitRecords(plan.id);
      final duplicatedPlan = await widget.repository.importPlanPackage(
        plan: plan.copyWith(name: l10n.planManagerCopyName(plan.name)),
        visitRecords: visitRecords,
      );
      await _loadPlans();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: l10n.planManagerCopied(duplicatedPlan.name),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.planManagerCopyFailed,
      );
    }
  }

  Future<void> _reorderPlans(int sourceIndex, int targetIndex) async {
    final plans = _plans;
    if (plans == null ||
        _savingOrder ||
        sourceIndex == targetIndex ||
        sourceIndex < 0 ||
        sourceIndex >= plans.length ||
        targetIndex < 0 ||
        targetIndex >= plans.length) {
      return;
    }

    final previousPlans = List<PilgrimagePlan>.of(plans);
    final reorderedPlans = List<PilgrimagePlan>.of(plans);
    final movedPlan = reorderedPlans.removeAt(sourceIndex);
    reorderedPlans.insert(targetIndex, movedPlan);
    setState(() {
      _plans = reorderedPlans;
      _savingOrder = true;
    });

    try {
      await widget.repository.reorderPlans(
        orderedPlanIds: reorderedPlans.map((plan) => plan.id).toList(),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _plans = previousPlans);
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.planManagerSaveOrderFailed,
      );
    } finally {
      if (mounted) {
        setState(() => _savingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = _plans;

    return Scaffold(
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(
          _sorting ? l10n.planManagerReorderTitle : l10n.planManagerTitle,
        ),
        actions: [
          if (plans != null && plans.length > 1)
            IconButton(
              key: const ValueKey('plan-order-toggle'),
              tooltip: _sorting
                  ? l10n.planManagerDoneSorting
                  : l10n.planManagerSortPlans,
              onPressed: _savingOrder
                  ? null
                  : () => setState(() {
                      _sorting = !_sorting;
                      _expandedPlanId = null;
                    }),
              icon: _savingOrder
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _sorting ? LucideIcons.check : LucideIcons.arrowUpDown,
                    ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_error != null) {
            return _ErrorState(onRetry: _loadPlans);
          }

          if (plans == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final activePlan = plans
              .where((plan) => plan.id == _activePlan?.id)
              .firstOrNull;
          return ListView(
            // Rules and rows run edge to edge; the rest insets 12.
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _CreatePlanButton(
                  onPressed: _sorting || _savingOrder ? null : _createEmptyPlan,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: RoutePlannerSkillLink(
                  lead: l10n.planManagerSkillLead,
                  repository: widget.repository,
                ),
              ),
              const SizedBox(height: 10),
              if (plans.isNotEmpty) ...[
                _PlanSectionLabel(
                  key: ValueKey('all-plans-section'),
                  label: l10n.planManagerAllPlans,
                ),
                ReorderableListView.builder(
                  key: const ValueKey('reorderable-plan-list'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  proxyDecorator: _cleanPlanReorderProxy,
                  onReorderItem: _savingOrder ? (_, _) {} : _reorderPlans,
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Padding(
                      key: ValueKey('reorder-plan-${plan.id}'),
                      padding: EdgeInsets.zero,
                      child: _PlanCard(
                        plan: plan,
                        selected: plan.id == activePlan?.id,
                        expanded: _expandedPlanId == plan.id,
                        reorderIndex: _sorting ? index : null,
                        reorderEnabled: !_savingOrder,
                        onToggle: _sorting
                            ? null
                            : () => setState(
                                () => _expandedPlanId =
                                    _expandedPlanId == plan.id ? null : plan.id,
                              ),
                        onOpen: () => _switchPlan(plan),
                        onEdit: () => _editPlanInfo(plan),
                        onExport: _sorting
                            ? null
                            : () => _openImportExport(plan),
                        onDuplicate: _sorting
                            ? null
                            : () => _duplicatePlan(plan),
                        onDelete: _sorting ? null : () => _deletePlan(plan),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Asks for a new plan's info, then creates it. Null when cancelled.
Future<PilgrimagePlan?> createPlanFromInfoForm(
  BuildContext context,
  PilgrimageRepository repository, {
  required String defaultName,
}) async {
  final result = await showDialog<_PlanInfoFormResult>(
    context: context,
    builder: (context) =>
        _PlanInfoDialog(title: l10n.planManagerNewPlan, name: defaultName),
  );
  if (result == null) {
    return null;
  }
  final plan = await repository.createPlan(
    name: result.name.isEmpty ? defaultName : result.name,
    area: result.area.isEmpty ? l10n.planManagerAreaNotSet : result.area,
  );
  if (result.memo.isEmpty) {
    return plan;
  }
  return repository.updatePlanMemo(planId: plan.id, memo: result.memo);
}

class _PlanInfoDialog extends StatefulWidget {
  const _PlanInfoDialog({
    required this.title,
    required this.name,
    this.area = '',
    this.memo = '',
  });

  final String title;
  final String name;
  final String area;
  final String memo;

  @override
  State<_PlanInfoDialog> createState() => _PlanInfoDialogState();
}

class _PlanInfoDialogState extends State<_PlanInfoDialog> {
  late final _nameController = TextEditingController(text: widget.name);
  late final _areaController = TextEditingController(text: widget.area);
  late final _memoController = TextEditingController(text: widget.memo);

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _PlanInfoFormResult(
        name: _nameController.text.trim(),
        area: _areaController.text.trim(),
        memo: _memoController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppInputDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogField(
            label: l10n.planManagerPlanName,
            child: TextField(
              onTapOutside: dismissKeyboardOnTapOutside,
              controller: _nameController,
              autofocus: true,
              decoration: appDialogInputDecoration(),
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 14),
          AppDialogField(
            label: l10n.planManagerAreaLabel,
            child: TextField(
              onTapOutside: dismissKeyboardOnTapOutside,
              controller: _areaController,
              decoration: appDialogInputDecoration(),
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 14),
          AppDialogField(
            label: l10n.planManagerDetails,
            child: TextField(
              key: const ValueKey('plan-info-details-field'),
              onTapOutside: dismissKeyboardOnTapOutside,
              controller: _memoController,
              decoration: appDialogInputDecoration(),
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 8,
            ),
          ),
        ],
      ),
      confirmLabel: l10n.commonSave,
      onConfirm: _submit,
    );
  }
}

class _PlanInfoFormResult {
  const _PlanInfoFormResult({
    required this.name,
    required this.area,
    required this.memo,
  });

  final String name;
  final String area;
  final String memo;
}

class _CreatePlanButton extends StatelessWidget {
  const _CreatePlanButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const ValueKey('create-plan'),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      icon: const Icon(LucideIcons.plus, size: 19),
      label: Text(l10n.planManagerNewPlan),
    );
  }
}

class _PlanSectionLabel extends StatelessWidget {
  const _PlanSectionLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    // A caps name over the list's 2px ink top rule.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: CapsLabel(label),
        ),
        const SectionRule(),
      ],
    );
  }
}

/// A ruled plan row. Tapping it opens the plan's details in place; the
/// Open key below them switches to the plan.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.expanded,
    required this.onToggle,
    required this.onOpen,
    required this.onEdit,
    required this.onExport,
    required this.onDuplicate,
    required this.onDelete,
    this.reorderIndex,
    this.reorderEnabled = true,
  });

  final PilgrimagePlan plan;
  final bool selected;
  final bool expanded;
  final VoidCallback? onToggle;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback? onExport;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final int? reorderIndex;
  final bool reorderEnabled;

  @override
  Widget build(BuildContext context) {
    final works = _works(plan);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // The current plan sits on the accent wash, as Tsumiki's current row.
    // An opened row keeps its ground so the mist work tags stay visible.
    final cardColor = selected ? AppColors.accentWash : AppColors.surface;

    final header = Padding(
      padding: EdgeInsets.fromLTRB(reorderIndex == null ? 12 : 50, 12, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: CopyableText(
                        key: ValueKey('plan-card-title-${plan.id}'),
                        text: plan.name,
                        copyLabel: l10n.planManagerPlanName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        onTap: onToggle,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          height: 1.15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      Text(
                        l10n.planManagerCurrentPlan,
                        key: const ValueKey('plan-status-current'),
                        style: TextStyle(
                          color: AppColors.accentStrongForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                CopyableText(
                  key: ValueKey('plan-card-summary-${plan.id}'),
                  text: l10n.planManagerPlanSummary(
                    plan.area,
                    plan.points.length,
                    works.length,
                  ),
                  copyText: l10n.planManagerPlanCopyText(
                    plan.name,
                    plan.area,
                    plan.points.length,
                    works.length,
                  ),
                  copyLabel: l10n.planManagerPlanInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  onTap: onToggle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  key: ValueKey('plan-card-work-row-${plan.id}'),
                  height: expanded && works.isNotEmpty ? null : 22,
                  child: works.isEmpty
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.planManagerNoWorks,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        )
                      : _PlanWorkTags(works: works, expanded: expanded),
                ),
              ],
            ),
          ),
          if (onExport != null && onDuplicate != null && onDelete != null)
            _PlanMoreButton(
              plan: plan,
              onEdit: onEdit,
              onExport: onExport!,
              onDuplicate: onDuplicate!,
              onDelete: onDelete!,
            ),
          if (onToggle != null)
            SizedBox(
              width: 40,
              height: 44,
              child: AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  LucideIcons.chevronDown,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );

    return Material(
      key: ValueKey('plan-card-${plan.id}'),
      color: cardColor,
      shape: Border(bottom: BorderSide(color: AppColors.divider)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                key: ValueKey('plan-card-toggle-${plan.id}'),
                onTap: onToggle,
                child: header,
              ),
              AnimatedSize(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: expanded
                    ? _PlanDetails(plan: plan, onOpen: onOpen, onEdit: onEdit)
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
          if (reorderIndex case final index?)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: ReorderableDragStartListener(
                index: index,
                enabled: reorderEnabled,
                child: SizedBox(
                  key: ValueKey('plan-card-drag-handle-${plan.id}'),
                  width: 44,
                  child: Tooltip(
                    message: l10n.planManagerDragSort,
                    child: Center(
                      child: Icon(
                        LucideIcons.gripVertical,
                        size: 22,
                        color: AppColors.textSecondary.withValues(
                          alpha: reorderEnabled ? 0.7 : 0.35,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<PilgrimageWork> _works(PilgrimagePlan plan) {
    if (plan.works.isNotEmpty) {
      return plan.works;
    }

    final worksById = <String, PilgrimageWork>{};
    for (final point in plan.points) {
      worksById[point.work.id] = point.work;
    }
    return worksById.values.toList(growable: false);
  }
}

/// The opened part of a plan row: facts, the plan's details, and the keys.
class _PlanDetails extends StatelessWidget {
  const _PlanDetails({
    required this.plan,
    required this.onOpen,
    required this.onEdit,
  });

  final PilgrimagePlan plan;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dates = MaterialLocalizations.of(context);
    final done = plan.points
        .where((point) => plan.completedPointIds.contains(point.id))
        .length;
    final memo = plan.memo.trim();

    return Padding(
      key: ValueKey('plan-card-details-${plan.id}'),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 10,
            children: [
              _PlanFact(
                label: l10n.planManagerFactSpots,
                value: l10n.planManagerSpotsDone(plan.points.length, done),
              ),
              _PlanFact(
                label: l10n.planManagerFactAreas,
                value: '${plan.groups.length}',
              ),
              _PlanFact(
                label: l10n.planManagerFactCreated,
                value: dates.formatMediumDate(plan.createdAt),
              ),
              _PlanFact(
                label: l10n.planManagerFactUpdated,
                value: dates.formatMediumDate(plan.updatedAt),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            memo.isEmpty ? l10n.planManagerNoDetails : memo,
            key: ValueKey('plan-card-memo-${plan.id}'),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: memo.isEmpty
                  ? AppColors.textTertiary
                  : AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: ValueKey('plan-card-edit-${plan.id}'),
                  onPressed: onEdit,
                  icon: const Icon(LucideIcons.edit, size: 18),
                  label: Text(l10n.planManagerEditDetails),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  key: ValueKey('plan-card-open-${plan.id}'),
                  onPressed: onOpen,
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  label: Text(l10n.planManagerOpenPlan),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A caps name over its value, as Tsumiki's trip facts.
class _PlanFact extends StatelessWidget {
  const _PlanFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CapsLabel(label),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _PlanMoreButton extends StatefulWidget {
  const _PlanMoreButton({
    required this.plan,
    required this.onEdit,
    required this.onExport,
    required this.onDuplicate,
    required this.onDelete,
  });

  final PilgrimagePlan plan;
  final VoidCallback onEdit;
  final VoidCallback onExport;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  State<_PlanMoreButton> createState() => _PlanMoreButtonState();
}

class _PlanMoreButtonState extends State<_PlanMoreButton> {
  final MenuController _controller = MenuController();

  static const double _menuWidth = 200;
  static const double _buttonWidth = 40;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      alignmentOffset: const Offset(_buttonWidth - _menuWidth, 4),
      style: const MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(Size(_menuWidth, 0)),
        maximumSize: WidgetStatePropertyAll(Size(_menuWidth, 520)),
      ),
      builder: closesOnBack((context, controller, child) => child!),
      menuChildren: [
        _PlanActionsMenuPanel(
          onEdit: widget.onEdit,
          onExport: widget.onExport,
          onDuplicate: widget.onDuplicate,
          onDelete: widget.onDelete,
        ),
      ],
      child: _PlanActionButton(
        key: ValueKey('plan-card-transfer-${widget.plan.id}'),
        tooltip: l10n.planManagerMoreActions,
        onPressed: () {
          if (_controller.isOpen) {
            _controller.close();
          } else {
            _controller.open();
          }
        },
        icon: LucideIcons.ellipsis,
        iconSize: 20,
      ),
    );
  }
}

/// The plan's ⋯ menu; the theme's menu style draws its 1px ink frame.
class _PlanActionsMenuPanel extends StatelessWidget {
  const _PlanActionsMenuPanel({
    required this.onEdit,
    required this.onExport,
    required this.onDuplicate,
    required this.onDelete,
  });
  final VoidCallback onEdit;
  final VoidCallback onExport;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('plan-actions-menu'),
      width: _PlanMoreButtonState._menuWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlanMenuActionItem(
            actionKey: const ValueKey('plan-menu-action-edit'),
            label: l10n.planManagerEditInfo,
            icon: LucideIcons.pencil,
            onPressed: onEdit,
          ),
          _PlanMenuActionItem(
            actionKey: const ValueKey('plan-menu-action-transfer'),
            label: l10n.planManagerImportExport,
            icon: LucideIcons.import,
            onPressed: onExport,
          ),
          _PlanMenuActionItem(
            actionKey: const ValueKey('plan-menu-action-copy'),
            label: l10n.planManagerCopyPlan,
            icon: LucideIcons.copy,
            onPressed: onDuplicate,
          ),
          Divider(height: 1, color: AppColors.divider),
          _PlanMenuActionItem(
            actionKey: const ValueKey('plan-menu-action-delete'),
            label: l10n.planManagerDeletePlan,
            icon: LucideIcons.trash2,
            onPressed: onDelete,
            isDangerous: true,
          ),
        ],
      ),
    );
  }
}

class _PlanMenuActionItem extends StatelessWidget {
  const _PlanMenuActionItem({
    required this.actionKey,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDangerous = false,
  });

  final Key actionKey;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDangerous
        ? AppColors.error
        : AppColors.textPrimary;

    return MenuItemButton(
      key: actionKey,
      onPressed: onPressed,
      leadingIcon: Icon(icon),
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14),
        ),
        foregroundColor: WidgetStatePropertyAll(foregroundColor),
        iconColor: WidgetStatePropertyAll(foregroundColor),
      ),
      child: Text(label),
    );
  }
}

class _PlanActionButton extends StatelessWidget {
  const _PlanActionButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.iconSize = 19,
    super.key,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: tooltip,
        child: SizedBox(
          width: 40,
          height: 44,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.zero,
              hoverColor: AppColors.surfaceMuted,
              highlightColor: AppColors.surfaceMuted,
              splashColor: AppColors.accent.withValues(alpha: 0.08),
              focusColor: Colors.transparent,
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return AppColors.surfaceMuted;
                }
                return Colors.transparent;
              }),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: onPressed == null
                      ? AppColors.textSecondary.withValues(alpha: 0.2)
                      : AppColors.textSecondary.withValues(alpha: 0.58),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanWorkTags extends StatelessWidget {
  const _PlanWorkTags({required this.works, this.expanded = false});

  final List<PilgrimageWork> works;

  /// An opened plan lists every work in full.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Wrap(
        key: const ValueKey('plan-work-tags'),
        spacing: 5,
        runSpacing: 5,
        children: [
          for (final work in works) _PlanWorkTag(work: work, full: true),
        ],
      );
    }
    const visibleCount = 3;
    final visibleWorks = works.take(visibleCount).toList(growable: false);
    final remainingCount = works.length - visibleWorks.length;

    return Row(
      key: const ValueKey('plan-work-tags'),
      children: [
        for (var index = 0; index < visibleWorks.length; index++) ...[
          Flexible(
            fit: FlexFit.loose,
            child: _PlanWorkTag(work: visibleWorks[index]),
          ),
          if (index != visibleWorks.length - 1 || remainingCount > 0)
            const SizedBox(width: 5),
        ],
        if (remainingCount > 0)
          Text(
            '+$remainingCount',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
      ],
    );
  }
}

/// A Tsumiki tag: the work's name on raise with a rule edge, so it reads on
/// the plain, wash and mist rows alike. No colour coding.
class _PlanWorkTag extends StatelessWidget {
  const _PlanWorkTag({required this.work, this.full = false});

  final PilgrimageWork work;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        work.title,
        maxLines: full ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(LucideIcons.refreshCw),
        label: Text(l10n.planManagerReload),
      ),
    );
  }
}
