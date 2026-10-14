import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../widgets/rules.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/app_back_button.dart';
import 'plan_group_actions.dart';
import 'pilgrimage_models.dart';
import 'plan_order.dart';
import '../l10n/l10n.dart';

Widget _cleanReorderProxy(
  Widget child,
  int index,
  Animation<double> animation,
) {
  // A lifted row stands forward with an ink frame, never a shadow.
  return Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.ink)),
    child: child,
  );
}

class PlanGroupManagerScreen extends StatefulWidget {
  const PlanGroupManagerScreen({
    required this.plan,
    required this.repository,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;

  @override
  State<PlanGroupManagerScreen> createState() => _PlanGroupManagerScreenState();
}

class _PlanGroupManagerScreenState extends State<PlanGroupManagerScreen> {
  late PilgrimagePlan _plan = widget.plan;
  var _isSaving = false;

  List<PilgrimagePlanGroup> get _groups => sortGroupsByPlanOrder(_plan.groups);

  int get _ungroupedCount {
    return _plan.points.where((point) => point.groupId == null).length;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;

    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop<String?>(null);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(
            onPressed: () => Navigator.of(context).pop<String?>(null),
          ),
          title: Text(l10n.planGroupManagerTitle),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        floatingActionButton: _CreateGroupFab(
          onPressed: _isSaving ? null : _createGroup,
        ),
        body: CustomScrollView(
          slivers: [
            // No page gutter: the rule and rows run edge to edge.
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanGroupManagerHeader(
                      plan: _plan,
                      groupCount: groups.length,
                    ),
                    // The areas hang from a 2px ink rule, as ruled rows.
                    const SectionRule(),
                  ],
                ),
              ),
            ),
            SliverReorderableList(
              itemCount: groups.length,
              onReorderItem: _reorderGroups,
              proxyDecorator: _cleanReorderProxy,
              itemBuilder: (context, index) {
                final group = groups[index];
                final pointCount = _plan.points
                    .where((point) => point.groupId == group.id)
                    .length;
                return Padding(
                  key: ValueKey(group.id),
                  padding: EdgeInsets.zero,
                  child: _PlanGroupCard(
                    index: index,
                    group: group,
                    pointCount: pointCount,
                    isBusy: _isSaving,
                    onOpen: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(group.id),
                    onRename: () => _run(
                      renameAreaChange(
                        context,
                        widget.repository,
                        _plan,
                        group,
                      ),
                      l10n.planGroupManagerRenameFailed,
                    ),
                    onToggleOrderMode: () => _run(
                      Future.value(
                        toggleAreaOrderChange(widget.repository, _plan, group),
                      ),
                      l10n.planGroupManagerOrderModeSaveFailed,
                    ),
                    onDelete: () => _run(
                      deleteAreaChange(
                        context,
                        widget.repository,
                        _plan,
                        group,
                      ),
                      l10n.planGroupManagerDeleteFailed,
                    ),
                  ),
                );
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 112),
              sliver: SliverToBoxAdapter(
                child: _UngroupedGroupCard(
                  pointCount: _ungroupedCount,
                  onOpen: _isSaving
                      ? null
                      : () => Navigator.of(context).pop('ungrouped'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AreaNameDialog(
        title: l10n.planGroupManagerNewArea,
        confirmLabel: l10n.planGroupManagerCreate,
      ),
    );
    final trimmedName = name?.trim();
    if (trimmedName == null || trimmedName.isEmpty || !mounted) {
      return;
    }

    final nextOrderIndex = _groups.isEmpty
        ? 0
        : _groups
                  .map((group) => group.orderIndex)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    final now = DateTime.now();
    await _savePlanChange(
      action: () => widget.repository.createPlanGroup(
        planId: _plan.id,
        group: PilgrimagePlanGroup(
          id: 'group-${now.microsecondsSinceEpoch}',
          name: trimmedName,
          orderIndex: nextOrderIndex,
          createdAt: now,
        ),
      ),
      failureMessage: l10n.planGroupManagerCreateFailed,
    );
  }

  Future<void> _run(Future<PlanChange?> pending, String failureMessage) async {
    final change = await pending;
    if (change == null || !mounted) {
      return;
    }
    await _savePlanChange(action: change, failureMessage: failureMessage);
  }

  Future<void> _reorderGroups(int oldIndex, int newIndex) async {
    final groups = _groups;
    if (_isSaving ||
        oldIndex < 0 ||
        oldIndex >= groups.length ||
        newIndex < 0 ||
        newIndex >= groups.length ||
        oldIndex == newIndex) {
      return;
    }
    // onReorderItem already reports the post-removal destination index.
    final group = groups.removeAt(oldIndex);
    groups.insert(newIndex, group);

    await _savePlanChange(
      action: () => widget.repository.reorderGroups(
        planId: _plan.id,
        orderedGroupIds: [for (final group in groups) group.id],
      ),
      failureMessage: l10n.planGroupManagerReorderFailed,
    );
  }

  Future<void> _savePlanChange({
    required Future<PilgrimagePlan> Function() action,
    required String failureMessage,
  }) async {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      final updatedPlan = await action();
      if (!mounted) {
        return;
      }
      setState(() {
        _plan = updatedPlan;
        _isSaving = false;
      });
    } catch (_) {
      // Show what is actually stored, not the optimistic local order.
      PilgrimagePlan? reloadedPlan;
      try {
        reloadedPlan = (await widget.repository.loadPlans())
            .where((plan) => plan.id == _plan.id)
            .firstOrNull;
      } catch (_) {
        reloadedPlan = null;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        if (reloadedPlan != null) {
          _plan = reloadedPlan;
        }
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showStatusSnack(kind: AppStatusBannerKind.error, title: failureMessage);
    }
  }
}

class _CreateGroupFab extends StatelessWidget {
  const _CreateGroupFab({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // A square primary key, as everywhere else; the theme styles it.
    return FloatingActionButton.extended(
      key: const ValueKey('plan-group-create-fab'),
      onPressed: onPressed,
      tooltip: l10n.planGroupManagerNewArea,
      icon: const Icon(LucideIcons.plus, size: 20),
      label: Text(l10n.planGroupManagerNewArea),
    );
  }
}

class _PlanGroupManagerHeader extends StatelessWidget {
  const _PlanGroupManagerHeader({required this.plan, required this.groupCount});

  final PilgrimagePlan plan;
  final int groupCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('plan-group-summary'),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.planGroupManagerSummary(groupCount, plan.points.length),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanGroupCard extends StatelessWidget {
  const _PlanGroupCard({
    required this.index,
    required this.group,
    required this.pointCount,
    required this.isBusy,
    required this.onOpen,
    required this.onRename,
    required this.onToggleOrderMode,
    required this.onDelete,
  });

  final int index;
  final PilgrimagePlanGroup group;
  final int pointCount;
  final bool isBusy;
  final VoidCallback? onOpen;
  final VoidCallback onRename;
  final VoidCallback onToggleOrderMode;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isEmpty = pointCount == 0;
    final orderLabel = group.orderMode == PlanGroupOrderMode.manual
        ? l10n.planGroupManagerManualOrder
        : l10n.planGroupManagerUnordered;
    final startName = group.startName?.trim() ?? '';
    return Material(
      type: MaterialType.transparency,
      shape: Border(bottom: rowDividerSide),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                enabled: !isBusy,
                child: SizedBox(
                  width: 42,
                  child: Icon(
                    LucideIcons.gripVertical,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                              color: isEmpty
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isEmpty) ...[
                          const SizedBox(width: 6),
                          _GroupMetaChip(label: l10n.planGroupManagerEmpty),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            startName.isEmpty
                                ? ''
                                : l10n.planGroupUtilsStart(startName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _GroupMetaChip(label: orderLabel),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                key: ValueKey('plan-group-actions-${group.id}'),
                tooltip: l10n.planGroupManagerAreaActions,
                enabled: !isBusy,
                icon: const Icon(LucideIcons.ellipsisVertical),
                position: PopupMenuPosition.under,
                offset: const Offset(0, 6),
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      onRename();
                    case 'order':
                      onToggleOrderMode();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: _GroupActionRow(
                      icon: LucideIcons.edit,
                      label: l10n.planGroupManagerRename,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'order',
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _GroupActionRow(
                      icon: LucideIcons.arrowUpDown,
                      label: group.orderMode == PlanGroupOrderMode.manual
                          ? l10n.planGroupManagerSwitchToUnordered
                          : l10n.planGroupManagerSwitchToManualOrder,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: _GroupActionRow(
                      icon: LucideIcons.trash2,
                      label: l10n.planGroupManagerDeleteArea,
                      destructive: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A plain fact tag: raise with a rule edge and ink-2 text, so it reads on
/// any row ground.
class _GroupMetaChip extends StatelessWidget {
  const _GroupMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _GroupActionRow extends StatelessWidget {
  const _GroupActionRow({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _UngroupedGroupCard extends StatelessWidget {
  const _UngroupedGroupCard({required this.pointCount, required this.onOpen});

  final int pointCount;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final hasPoints = pointCount > 0;
    return Material(
      key: const ValueKey('ungrouped'),
      type: MaterialType.transparency,
      shape: Border(bottom: rowDividerSide),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
          child: Row(
            children: [
              // Lines up with the drag grips above.
              SizedBox(
                width: 42,
                child: Icon(LucideIcons.inbox, color: AppColors.textSecondary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.planGroupManagerUngroupedSpots,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.planGroupManagerUngroupedWaiting(pointCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasPoints
                            ? AppColors.accentForeground
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: hasPoints
                            ? FontWeight.w600
                            : FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
