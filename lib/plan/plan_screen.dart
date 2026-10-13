import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../map/map_colors.dart';
import '../data/pilgrimage_repository.dart';
import '../widgets/auto_caching_reference_thumbnail.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/reference_thumbnail_stub.dart'
    if (dart.library.io) '../widgets/reference_thumbnail_io.dart';
import '../widgets/snackbar_helper.dart';
import '../data/app_file_reclamation.dart';
import '../camera_reference/camerawesome_reference_screen.dart';
import '../point_detail/point_detail_sheet.dart';
import '../records/point_visit_records_screen.dart';
import '../records/visit_record_detail_screen.dart';
import '../map/map_marker_scale.dart';
import '../map/map_tile_config.dart';
import '../map/map_location_tracker.dart';
import '../utils/selected_item_order.dart';
import 'add_points_screen.dart';
import 'nearest_group_assign_screen.dart';
import 'plan_group_actions.dart';
import 'plan_group_manager_screen.dart';
import 'plan_group_picker_sheet.dart';
import 'auto_areas.dart';
import 'plan_group_utils.dart';
import 'plan_memo_screen.dart';
import 'pilgrimage_models.dart';
import 'area_name_dialog.dart';
import 'area_suggestion.dart';
import '../data/place_names.dart';
import 'pilgrimage_plan_controller.dart';
import 'reference_cache_progress_dialog.dart';
import 'reference_full_cache_runner.dart';
import 'reference_image_status.dart';
import '../widgets/menu_back_scope.dart';
import '../widgets/rules.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    required this.controller,
    required this.settings,
    required this.repository,
    required this.onOpenMap,
    required this.onOpenPlanManager,
    required this.onOpenAddPoints,
    required this.onOpenImportExport,
    this.onPickPlan,
    this.isActive = true,
    this.locationTracker,
    super.key,
  });

  final PilgrimagePlanController controller;
  final AppSettings settings;
  final PilgrimageRepository repository;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenPlanManager;
  final Future<void> Function() onOpenAddPoints;
  final VoidCallback onOpenImportExport;

  /// Opens the plan list from the title; the title is plain text without it.
  final VoidCallback? onPickPlan;
  final bool isActive;
  final MapLocationTracker? locationTracker;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen>
    with MapLocationLifecycle<PlanScreen> {
  int _selectedGroupIndex = 0;
  String? _selectedGroupId;
  late String _selectedPlanId;
  PointSortMode _sortMode = PointSortMode.plan;
  bool _sortDescending = false;
  bool _showMap = false;
  bool _showPlanActions = false;
  bool _showVirtualLocation = false;
  bool _isLocating = false;

  // Edit mode: the same list, with selection, bulk actions and reorder.
  bool _editing = false;
  final Set<String> _selectedIds = {};
  bool _isSaving = false;
  ReferenceCacheTask? _observedCacheTask;
  PilgrimagePlan? _seenCachedPlan;
  ReferenceCacheTask get _cacheTask =>
      ReferenceCacheTask.forPlan(widget.repository, controller.plan.id);
  bool get _isCachingFullReferences => _cacheTask.isRunning;

  void _onCacheChanged() {
    final updated = _observedCacheTask?.updatedPlan;
    if (mounted &&
        updated != null &&
        !identical(_seenCachedPlan, updated) &&
        controller.plan.id == updated.id) {
      _seenCachedPlan = updated;
      controller.replacePlan(updated);
    }
    if (mounted) setState(() {});
  }

  double _mapHeightRatio = 0.42;
  LatLng? _currentLocation;
  late final _locationTracker = widget.locationTracker ?? MapLocationTracker();
  String? _locationError;

  @override
  bool get locationPageEnabled =>
      widget.isActive && _showMap && controller.points.isNotEmpty;

  @override
  void onLocationActivityChanged(bool active) => _locationTracker.configure(
    active: active,
    continuous: settings.continuousMapLocation,
  );

  @override
  void didUpdateWidget(covariant PlanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncLocationActivity(force: true);
  }

  void _onLocationChanged() {
    if (!mounted) return;
    final position = _locationTracker.position;
    final nextError = _locationTracker.error;
    if (nextError != null &&
        nextError != _locationError &&
        locationPageActive) {
      _showSnackBar(nextError);
    }
    setState(() {
      if (position != null) {
        _currentLocation = LatLng(position.latitude, position.longitude);
      }
      _isLocating = _locationTracker.locating;
      _showVirtualLocation = _locationTracker.enabled;
      _locationError = nextError;
    });
  }

  final _pointListController = ScrollController();
  final _pointTileKeys = <String, GlobalKey>{};
  final _planActionsPanelRegionKey = GlobalKey();

  PilgrimagePlanController get controller => widget.controller;

  AppSettings get settings => widget.settings;

  @override
  void initState() {
    super.initState();
    _selectedPlanId = controller.plan.id;
    _selectedGroupId = controller.plan.currentGroupId;
    _locationTracker.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    _observedCacheTask?.removeListener(_onCacheChanged);
    _locationTracker.removeListener(_onLocationChanged);
    _locationTracker.dispose();
    _pointListController.dispose();
    super.dispose();
  }

  void _selectGroup(int index, List<PlanGroupBucket> groups) {
    final selectedIndex = index.clamp(0, groups.length - 1);
    final groupId = groups[selectedIndex].id;
    setState(() {
      _selectedGroupIndex = selectedIndex;
      _selectedGroupId = groupId;
    });
    if (_pointListController.hasClients) {
      _pointListController.jumpTo(0);
    }
    syncLocationActivity();
    controller.setCurrentGroup(groupId);
  }

  void _selectPoint(PilgrimagePoint point, List<PlanGroupBucket> groups) {
    final nextGroupIndex = groups.indexWhere((group) {
      if (point.groupId == null) {
        return group.isUngrouped;
      }
      return group.id == point.groupId;
    });
    setState(() {
      if (nextGroupIndex >= 0) {
        _selectedGroupIndex = nextGroupIndex;
        _selectedGroupId = groups[nextGroupIndex].id;
      }
    });
    if (nextGroupIndex >= 0) {
      controller.setCurrentGroup(groups[nextGroupIndex].id);
    }
    controller.selectPoint(point);
  }

  void _handleMapPointTap(
    BuildContext context,
    PilgrimagePoint point,
    List<PlanGroupBucket> groups,
  ) {
    if (controller.selectedPoint?.id == point.id) {
      _showPointDetail(context, point);
      return;
    }

    _selectPoint(point, groups);
    _scrollPointTileIntoView(point.id);
  }

  Future<void> _scrollPointTileIntoView(String pointId) async {
    // Rows vary in height and are built lazily, so jump by the list's own
    // measured extent until the row exists, then let ensureVisible finish.
    for (var attempt = 0; attempt < 6; attempt++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
      final tileContext = _pointTileKeys[pointId]?.currentContext;
      if (tileContext != null && tileContext.mounted) {
        await Scrollable.ensureVisible(
          tileContext,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0,
        );
        return;
      }

      final group = planGroupBuckets(
        controller.plan,
        controller.completedPointIds,
      ).elementAtOrNull(_selectedGroupIndex);
      if (group == null || !_pointListController.hasClients) {
        return;
      }
      final displayPoints = displayPointsForGroup(
        group,
        sortMode: _sortMode,
        descending: _sortDescending,
        currentLocation: _currentLocation,
      );
      final index = displayPoints.indexWhere((point) => point.id == pointId);
      if (index < 0) {
        return;
      }

      final position = _pointListController.position;
      final rowExtent =
          (position.maxScrollExtent + position.viewportDimension) /
          displayPoints.length;
      _pointListController.jumpTo(
        (index * rowExtent).clamp(0.0, position.maxScrollExtent),
      );
    }
  }

  GlobalKey _pointTileKey(String pointId) {
    return _pointTileKeys.putIfAbsent(pointId, GlobalKey.new);
  }

  void _resizeMap(double deltaY, double viewportHeight) {
    if (!_showMap) {
      return;
    }
    setState(() {
      _mapHeightRatio = (_mapHeightRatio + deltaY / viewportHeight).clamp(
        0.22,
        0.58,
      );
    });
  }

  void _togglePlanActions() {
    setState(() {
      _showPlanActions = !_showPlanActions;
    });
  }

  void _collapsePlanActions() {
    if (!_showPlanActions) {
      return;
    }
    setState(() {
      _showPlanActions = false;
    });
  }

  Future<void> _openAddPoints() async {
    final before = {for (final point in controller.points) point.id};
    await widget.onOpenAddPoints();
    // The shell hands over the reloaded plan on its next frame.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    final added = controller.points
        .where((point) => !before.contains(point.id))
        .firstOrNull;
    if (added == null) {
      return;
    }
    _selectPoint(
      added,
      planGroupBuckets(controller.plan, controller.completedPointIds),
    );
    _scrollPointTileIntoView(added.id);
  }

  void _openPlanAction(VoidCallback action) {
    _collapsePlanActions();
    action();
  }

  void _handlePlanBodyPointerDown(PointerDownEvent event) {
    if (!_showPlanActions || !settings.dismissPlanActionsOnOutsideTap) {
      return;
    }
    final renderBox =
        _planActionsPanelRegionKey.currentContext?.findRenderObject()
            as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return;
    }
    final panelRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    if (!panelRect.contains(event.position)) {
      _collapsePlanActions();
    }
  }

  Future<void> _toggleCurrentLocation() async {
    if (_showVirtualLocation && _locationError == null) {
      _locationTracker.disable();
      return;
    }
    await _locationTracker.locate();
  }

  @override
  Widget build(BuildContext context) {
    syncLocationActivity();
    if (_observedCacheTask != _cacheTask) {
      _observedCacheTask?.removeListener(_onCacheChanged);
      _observedCacheTask = _cacheTask..addListener(_onCacheChanged);
    }
    final plan = controller.plan;
    final groups = planGroupBuckets(plan, controller.completedPointIds);
    if (_selectedPlanId != plan.id) {
      _selectedPlanId = plan.id;
      _selectedGroupId = plan.currentGroupId;
    }
    final restoredGroupIndex = groups.indexWhere(
      (group) => group.id == _selectedGroupId,
    );
    if (restoredGroupIndex >= 0) {
      _selectedGroupIndex = restoredGroupIndex;
    }
    if (_selectedGroupIndex >= groups.length) {
      _selectedGroupIndex = groups.isEmpty ? 0 : groups.length - 1;
    }
    if (groups.isNotEmpty) {
      _selectedGroupId = groups[_selectedGroupIndex].id;
    }
    final selectedGroup = groups.isEmpty ? null : groups[_selectedGroupIndex];
    final displayPoints = selectedGroup == null
        ? const <PilgrimagePoint>[]
        : displayPointsForGroup(
            selectedGroup,
            sortMode: _sortMode,
            descending: _sortDescending,
            currentLocation: _currentLocation,
          );

    final canReorder =
        _editing &&
        selectedGroup != null &&
        selectedGroup.isManualOrder &&
        _sortMode == PointSortMode.plan &&
        !_sortDescending;

    return PopScope(
      canPop: !_editing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _setEditing(false);
        }
      },
      child: Scaffold(
        appBar: _editing
            ? AppBar(
                toolbarHeight: kToolbarHeight,
                automaticallyImplyLeading: false,
                title: Text(
                  l10n.pointManagerSelectedCount(_selectedIds.length),
                ),
                actions: [
                  TextButton(
                    key: const ValueKey('plan-select-all'),
                    onPressed: () => setState(() {
                      final ids = displayPoints.map((point) => point.id);
                      if (_selectedIds.containsAll(ids)) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds.addAll(ids);
                      }
                    }),
                    child: Text(l10n.pointManagerSelectAll),
                  ),
                  TextButton(
                    key: const ValueKey('plan-edit-done'),
                    onPressed: () => _setEditing(false),
                    child: Text(l10n.planEditDone),
                  ),
                  const SizedBox(width: 8),
                ],
              )
            : AppBar(
                toolbarHeight: kToolbarHeight,
                actionsPadding: EdgeInsets.zero,
                title: InkWell(
                  key: const ValueKey('plan-title-picker'),
                  onTap: widget.onPickPlan,
                  borderRadius: BorderRadius.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          plan.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.onPickPlan != null) ...[
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.chevronsUpDown, size: 18),
                      ],
                    ],
                  ),
                ),
                actions: [
                  if (controller.points.isNotEmpty)
                    IconButton(
                      key: const ValueKey('plan-edit-button'),
                      tooltip: l10n.planEdit,
                      onPressed: () => _setEditing(true),
                      icon: const Icon(LucideIcons.squarePen),
                    ),
                  IconButton(
                    key: const ValueKey('plan-add-points-button'),
                    tooltip: l10n.planAddSpots,
                    onPressed: () => _openPlanAction(_openAddPoints),
                    icon: const Icon(LucideIcons.mapPinPlus),
                  ),
                  IconButton(
                    key: const ValueKey('plan-actions-toggle'),
                    tooltip: _showPlanActions
                        ? l10n.planHideActions
                        : l10n.planShowActions,
                    onPressed: _togglePlanActions,
                    icon: Icon(
                      _showPlanActions
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                    ),
                  ),
                ],
              ),
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _handlePlanBodyPointerDown,
          child: Column(
            children: [
              if (selectedGroup == null || controller.points.isEmpty)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                    children: [
                      _WorkHeader(plan: plan),
                      _PlanActionsReveal(
                        expanded: _showPlanActions,
                        child: KeyedSubtree(
                          key: _planActionsPanelRegionKey,
                          child: _PlanActionsPanel(
                            isCachingReferences: _isCachingFullReferences,
                            onCacheReferences: _handleReferenceCachePressed,
                            onSwitchPlan: () =>
                                _openPlanAction(widget.onOpenPlanManager),
                            onOpenMemo: () => _openPlanAction(_openPlanMemo),
                            onImportExport: () =>
                                _openPlanAction(widget.onOpenImportExport),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _EmptyPlanCard(onAddPoints: _openAddPoints),
                    ],
                  ),
                )
              else ...[
                _PlanActionsReveal(
                  expanded: _showPlanActions,
                  padding: EdgeInsets.zero,
                  child: KeyedSubtree(
                    key: _planActionsPanelRegionKey,
                    child: _PlanActionsPanel(
                      isCachingReferences: _isCachingFullReferences,
                      onCacheReferences: _handleReferenceCachePressed,
                      onSwitchPlan: () =>
                          _openPlanAction(widget.onOpenPlanManager),
                      onOpenMemo: () => _openPlanAction(_openPlanMemo),
                      onImportExport: () =>
                          _openPlanAction(widget.onOpenImportExport),
                    ),
                  ),
                ),
                _GroupSwitcher(
                  groups: groups,
                  selectedIndex: _selectedGroupIndex,
                  showProgressRing: widget.settings.showPlanGroupProgress,
                  onSelectGroup: (group) {
                    final currentGroups = planGroupBuckets(
                      controller.plan,
                      controller.completedPointIds,
                    );
                    final index = currentGroups.indexWhere(
                      (candidate) => candidate.id == group.id,
                    );
                    if (index >= 0) {
                      _selectGroup(index, currentGroups);
                    }
                  },
                  onCreateGroup: () => _createGroupFromPointDetail(context),
                  onAreaAction: (action) =>
                      _handleAreaAction(action, selectedGroup),
                ),
                _PlanGroupControls(
                  locationError: _locationError,
                  group: selectedGroup,
                  showMap: _showMap,
                  sortMode: _sortMode,
                  sortDescending: _sortDescending,
                  mapHeightRatio: _mapHeightRatio,
                  settings: settings,
                  showVirtualLocation: _showVirtualLocation,
                  isLocating: _isLocating,
                  currentLocation: _currentLocation,
                  selectedPointId: controller.selectedPoint?.id,
                  onSetSortMode: (mode) {
                    setState(() {
                      _sortMode = mode;
                    });
                  },
                  onToggleSortDirection: () {
                    setState(() {
                      _sortDescending = !_sortDescending;
                    });
                  },
                  onToggleMap: () {
                    setState(() {
                      _showMap = !_showMap;
                    });
                    syncLocationActivity();
                  },
                  onResizeMap: _resizeMap,
                  onToggleVirtualLocation: _toggleCurrentLocation,
                  onSelectPoint: (point) =>
                      _handleMapPointTap(context, point, groups),
                  completedPointIds: controller.completedPointIds,
                ),
                Expanded(
                  child: Column(
                    children: [
                      // Rows hang from a 2px ink rule, as Tsumiki's lists do.
                      if (displayPoints.isNotEmpty)
                        Container(height: 2, color: AppColors.ink),
                      Expanded(
                        child: displayPoints.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  l10n.planAreaEmpty,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : ReorderableListView.builder(
                                scrollController: _pointListController,
                                padding: const EdgeInsets.only(bottom: 24),
                                buildDefaultDragHandles: false,
                                itemCount: displayPoints.length,
                                onReorderItem: (oldIndex, newIndex) =>
                                    _reorderPoints(
                                      selectedGroup,
                                      displayPoints,
                                      oldIndex,
                                      newIndex,
                                    ),
                                itemBuilder: (context, index) {
                                  final point = displayPoints[index];
                                  return _PlanPointTile(
                                    key: _pointTileKey(point.id),
                                    controller: controller,
                                    point: point,
                                    status: controller.statusFor(point),
                                    recordCount: controller
                                        .recordsForPoint(point.id)
                                        .length,
                                    editing: _editing,
                                    selected: _selectedIds.contains(point.id),
                                    reorderIndex: canReorder ? index : null,
                                    onTap: _editing
                                        ? () => _toggleSelected(point)
                                        : () {
                                            _selectPoint(point, groups);
                                            _showPointDetail(context, point);
                                          },
                                    onLongPress: _editing
                                        ? null
                                        : () => _setEditing(true, point),
                                    onOpenCamera: () =>
                                        _openCamera(context, point),
                                    onComplete: () =>
                                        controller.completePoint(point),
                                    onReopen: () =>
                                        controller.reopenPoint(point),
                                  );
                                },
                              ),
                      ),
                      if (_editing)
                        _EditBar(
                          hasSelection: _selectedIds.isNotEmpty && !_isSaving,
                          onMove: _moveSelected,
                          onComplete: _completeSelected,
                          onDelete: _deleteSelected,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _setEditing(bool editing, [PilgrimagePoint? first]) {
    setState(() {
      _editing = editing;
      _showPlanActions = false;
      _selectedIds.clear();
      if (first != null) {
        _selectedIds.add(first.id);
      }
    });
  }

  void _toggleSelected(PilgrimagePoint point) {
    setState(() {
      if (!_selectedIds.remove(point.id)) {
        _selectedIds.add(point.id);
      }
    });
  }

  /// Saves a change and shows the stored plan; names what failed otherwise.
  Future<bool> _savePlanChange(PlanChange action, String failureMessage) async {
    if (_isSaving) {
      return false;
    }
    setState(() => _isSaving = true);
    try {
      final updatedPlan = await action();
      if (mounted) {
        controller.replacePlan(updatedPlan);
      }
      return true;
    } catch (_) {
      _showSnackBar(failureMessage);
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _runAreaChange(
    Future<PlanChange?> pending,
    String failureMessage,
  ) async {
    final change = await pending;
    if (change != null && mounted) {
      await _savePlanChange(change, failureMessage);
    }
  }

  Future<void> _reloadPlan() async {
    final updatedPlan = await widget.repository.loadActivePlan();
    if (mounted) {
      controller.replacePlan(updatedPlan);
    }
  }

  Future<void> _moveSelected() async {
    const ungrouped = '__ungrouped__';
    final pointIds = {..._selectedIds};
    final movingPoints = controller.points
        .where((point) => pointIds.contains(point.id) && point.hasCoordinate)
        .toList();
    final picked = await showPlanGroupSelectionSheet(
      context: context,
      title: l10n.pointManagerMoveToGroup,
      subtitle: l10n.pointManagerMoveToGroupSubtitle,
      selectedOptionId: '',
      options: [
        PlanGroupSelectionOption(
          id: ungrouped,
          title: l10n.pointManagerNotInGroup,
        ),
        for (final group in sortGroupsByPlanOrder(controller.plan.groups))
          PlanGroupSelectionOption(id: group.id, title: group.name),
      ],
      suggestedOptionId: suggestAreaForSpots(
        controller.plan,
        movingPoints,
      ).then((group) => group?.id),
      onCreateOption: () async {
        final created = await _createGroupFromPointDetail(
          context,
          spots: movingPoints,
        );
        return created == null
            ? null
            : PlanGroupSelectionOption(id: created.id, title: created.name);
      },
    );
    if (picked == null || !mounted) {
      return;
    }
    final saved = await _savePlanChange(
      () => widget.repository.movePointsToGroup(
        planId: controller.plan.id,
        pointIds: pointIds,
        groupId: picked == ungrouped ? null : picked,
      ),
      l10n.pointManagerMoveGroupFailed,
    );
    if (saved) {
      _setEditing(false);
    }
  }

  void _completeSelected() {
    for (final point in controller.points) {
      if (_selectedIds.contains(point.id) &&
          controller.statusFor(point) != VisitStatus.completed) {
        controller.completePoint(point);
      }
    }
    _setEditing(false);
  }

  Future<void> _deleteSelected() async {
    final points = controller.points
        .where((point) => _selectedIds.contains(point.id))
        .toList(growable: false);
    final countText = l10n.pointManagerSpotCount(points.length);
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.pointManagerBatchDeleteTitle,
      message: l10n.pointManagerBatchDeleteMessage(countText),
      confirmLabel: l10n.commonDelete,
      destructive: true,
      emphasizedValues: [countText],
    );
    if (!confirmed || !mounted) {
      return;
    }
    final saved = await _savePlanChange(() async {
      final updatedPlan = await widget.repository.deletePointsFromPlan(
        planId: controller.plan.id,
        pointIds: {for (final point in points) point.id},
      );
      // Reference files are reclaimed only after the deletion has committed.
      reclaimDeletedPointFiles(repository: widget.repository, points: points);
      return updatedPlan;
    }, l10n.pointManagerBatchDeleteFailed);
    if (saved) {
      _setEditing(false);
    }
  }

  Future<void> _reorderPoints(
    PlanGroupBucket group,
    List<PilgrimagePoint> points,
    int oldIndex,
    int newIndex,
  ) async {
    final ordered = [...points];
    ordered.insert(newIndex, ordered.removeAt(oldIndex));
    await _savePlanChange(
      () => widget.repository.reorderGroupPoints(
        planId: controller.plan.id,
        groupId: group.id,
        pointIds: [for (final point in ordered) point.id],
      ),
      l10n.pointManagerPointOrderSaveFailed,
    );
  }

  Future<void> _handleAreaAction(
    _AreaAction action,
    PlanGroupBucket bucket,
  ) async {
    final plan = controller.plan;
    final group = bucket.group;
    switch (action) {
      case _AreaAction.rename when group != null:
        await _runAreaChange(
          renameAreaChange(context, widget.repository, plan, group),
          l10n.planGroupManagerRenameFailed,
        );
      case _AreaAction.anchor when group != null:
        await _runAreaChange(
          setAreaAnchorChange(context, widget.repository, plan, group),
          l10n.planGroupManagerAnchorSaveFailed,
        );
      case _AreaAction.order when group != null:
        await _savePlanChange(
          toggleAreaOrderChange(widget.repository, plan, group),
          l10n.planGroupManagerOrderModeSaveFailed,
        );
      case _AreaAction.delete when group != null:
        await _runAreaChange(
          deleteAreaChange(context, widget.repository, plan, group),
          l10n.planGroupManagerDeleteFailed,
        );
      case _AreaAction.manage:
        final pickedId = await Navigator.of(context).push<String?>(
          MaterialPageRoute(
            builder: (_) => PlanGroupManagerScreen(
              plan: plan,
              repository: widget.repository,
            ),
          ),
        );
        await _reloadPlan();
        if (pickedId != null && mounted) {
          setState(() => _selectedGroupId = pickedId);
        }
      case _AreaAction.auto:
        final before = plan.groups.length;
        await _savePlanChange(
          () => autoGroupUngroupedSpots(
            plan: plan,
            repository: widget.repository,
          ),
          l10n.autoAreaFailed,
        );
        final added = controller.plan.groups.length - before;
        if (mounted && added > 0) {
          final firstNew = sortGroupsByPlanOrder(
            controller.plan.groups,
          ).skip(before).first;
          setState(() => _selectedGroupId = firstNew.id);
          _showSnackBar(
            l10n.autoAreaGrouped(bucket.points.length, added),
            kind: AppStatusBannerKind.success,
          );
        }
      case _AreaAction.nearest:
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => NearestGroupAssignScreen(
              plan: plan,
              settings: settings,
              repository: widget.repository,
            ),
          ),
        );
        await _reloadPlan();
      case _AreaAction.box:
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => BoxGroupAssignScreen(
              plan: plan,
              repository: widget.repository,
              settings: settings,
            ),
          ),
        );
        await _reloadPlan();
      default:
        break;
    }
  }

  Future<void> _openPlanMemo() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PlanMemoScreen(controller: controller),
      ),
    );
  }

  void _openCamera(BuildContext context, PilgrimagePoint point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CamerawesomeReferenceScreen(
          point: point,
          controller: controller,
          settings: settings,
        ),
      ),
    );
  }

  void _showPointDetail(BuildContext context, PilgrimagePoint point) {
    PointDetailSheet.show(
      context,
      point: point,
      status: controller.statusFor(point),
      onSetCurrent: () => controller.setCurrentPoint(point),
      onOpenCamera: () => _openCamera(context, point),
      onComplete: () => controller.statusFor(point) == VisitStatus.completed
          ? controller.reopenPoint(point)
          : controller.completePoint(point),
      onReplaceReference: (point, image) => controller.updatePoint(
        point.copyWith(
          referenceImageUrl: null,
          referenceThumbnailPath: image.thumbnailPath,
          referenceFullImagePath: image.fullImagePath,
        ),
      ),
      groups: controller.plan.groups,
      groupBuckets: planGroupBuckets(
        controller.plan,
        controller.completedPointIds,
      ),
      onMoveToGroup: controller.movePointToGroup,
      onCreateGroup: () => _createGroupFromPointDetail(context, spots: [point]),
      records: controller.recordsForPoint(point.id),
      onOpenRecords: () => _openPointRecords(context, point),
      onOpenRecord: (record) => _openRecordDetail(context, record),
      onEditPoint: () => _editPoint(context, point),
      onDelete: controller.deletePoint,
      navigationApp: settings.navigationApp,
      settings: settings,
      planController: controller,
    );
  }

  /// Names and creates an area, offering the cities of [spots] as names.
  Future<PilgrimagePlanGroup?> _createGroupFromPointDetail(
    BuildContext context, {
    List<PilgrimagePoint> spots = const [],
  }) async {
    final name = await showAreaNameDialog(
      context,
      suggestions: spots.isEmpty
          ? null
          : cityNamesFor(spots.map((spot) => spot.position).toList()),
      fieldKey: const ValueKey('plan-point-group-name-field'),
    );
    final trimmedName = name?.trim();
    if (trimmedName == null || trimmedName.isEmpty || !mounted) {
      return null;
    }

    final groups = controller.plan.groups;
    final nextOrderIndex = groups.isEmpty
        ? 0
        : groups
                  .map((group) => group.orderIndex)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    final now = DateTime.now();
    final group = PilgrimagePlanGroup(
      id: 'group-${now.microsecondsSinceEpoch}',
      name: trimmedName,
      orderIndex: nextOrderIndex,
      createdAt: now,
    );
    try {
      final updatedPlan = await widget.repository.createPlanGroup(
        planId: controller.plan.id,
        group: group,
      );
      if (!mounted) {
        return null;
      }
      controller.replacePlan(updatedPlan);
      return updatedPlan.groups
          .where((item) => item.id == group.id)
          .firstOrNull;
    } catch (_) {
      if (mounted) {
        _showSnackBar(l10n.planCreateAreaFailed);
      }
      return null;
    }
  }

  Future<void> _editPoint(BuildContext context, PilgrimagePoint point) async {
    final updated = await EditPointScreen.open(
      context,
      plan: controller.plan,
      repository: widget.repository,
      point: point,
    );
    if (updated != true || !mounted) {
      return;
    }
    final updatedPlan = await widget.repository.loadActivePlan();
    if (!mounted) {
      return;
    }
    controller.replacePlan(updatedPlan);
  }

  void _openPointRecords(BuildContext context, PilgrimagePoint point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PointVisitRecordsScreen(
          point: point,
          controller: controller,
          settings: settings,
        ),
      ),
    );
  }

  void _openRecordDetail(BuildContext context, PilgrimageVisitRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitRecordDetailScreen(
          record: record,
          point: controller.pointById(record.pointId),
          controller: controller,
          settings: settings,
          onDelete: () => controller.deleteVisitRecord(record),
        ),
      ),
    );
  }

  Future<void> _handleReferenceCachePressed() async {
    if (_isCachingFullReferences) {
      await _cacheFullReferenceImages(startOnOpen: false);
      return;
    }

    final points = pointsNeedingFullReferenceCache(controller.points);
    if (points.isEmpty) {
      _showSnackBar(
        l10n.planNoReferencesToCache,
        kind: AppStatusBannerKind.warning,
      );
      return;
    }

    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.planCacheFullReferencesTitle,
      message: l10n.planCacheFullReferencesMessage(
        l10n.planCacheFullImageCount(points.length),
      ),
      confirmLabel: l10n.planStartCaching,
      notice: l10n.planCacheWifiNotice,
      emphasizedValues: [l10n.planCacheFullImageCount(points.length)],
    );
    if (!confirmed || !mounted) {
      return;
    }
    _collapsePlanActions();
    await _cacheFullReferenceImages();
  }

  Future<void> _cacheFullReferenceImages({bool startOnOpen = true}) async {
    final planId = controller.plan.id;
    final task = _cacheTask;
    final repository = widget.repository;
    final imageSource = settings.anitabiImageSource;
    final maxConcurrent = settings.mapThumbnailConcurrentLoads;
    await showReferenceCacheProgressDialog(
      context: context,
      task: task,
      startOnOpen: startOnOpen,
      run: (onProgress) async {
        final plan = (await repository.loadPlans()).firstWhere(
          (plan) => plan.id == planId,
        );
        await cacheFullReferenceImages(
          plan: plan,
          repository: repository,
          onPlanUpdated: (updated) {
            task.updatedPlan = updated;
          },
          imageSource: imageSource,
          maxConcurrent: maxConcurrent,
          onProgress: onProgress,
          isCancelled: () => task.cancelled,
        );
      },
    );
  }

  void _showSnackBar(
    String message, {
    AppStatusBannerKind kind = AppStatusBannerKind.error,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showStatusSnack(kind: kind, title: message);
  }
}

class _PlanActionsReveal extends StatelessWidget {
  const _PlanActionsReveal({
    required this.expanded,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final bool expanded;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: expanded
          ? Padding(padding: padding, child: child)
          : const SizedBox.shrink(),
    );
  }
}

class _PlanActionsPanel extends StatelessWidget {
  const _PlanActionsPanel({
    required this.isCachingReferences,
    required this.onCacheReferences,
    required this.onSwitchPlan,
    required this.onOpenMemo,
    required this.onImportExport,
  });

  final bool isCachingReferences;
  final VoidCallback onCacheReferences;
  final VoidCallback onSwitchPlan;
  final VoidCallback onOpenMemo;
  final VoidCallback onImportExport;

  @override
  Widget build(BuildContext context) {
    final items = [
      _PlanActionItem(
        key: const ValueKey('plan-action-switch-plan'),
        icon: const Icon(LucideIcons.list, size: 20),
        title: l10n.planSwitchPlan,
        onTap: onSwitchPlan,
      ),
      _PlanActionItem(
        key: const ValueKey('plan-action-cache-references'),
        icon: isCachingReferences
            ? const SizedBox.square(
                dimension: 19,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.cloudDownload, size: 20),
        title: l10n.planCacheReferences,
        onTap: onCacheReferences,
      ),
      _PlanActionItem(
        key: const ValueKey('plan-action-memo'),
        icon: const Icon(LucideIcons.stickyNote, size: 20),
        title: l10n.planActionMemo,
        onTap: onOpenMemo,
      ),
      _PlanActionItem(
        key: const ValueKey('plan-action-import-export'),
        icon: const Icon(LucideIcons.import, size: 20),
        title: l10n.planActionImportExport,
        onTap: onImportExport,
      ),
    ];
    return Container(
      key: const ValueKey('plan-actions-panel'),
      clipBehavior: Clip.antiAlias,
      // A full-width strip under the app bar, closed by a row divider.
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: rowDividerSide),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Large text: four labels no longer fit in one row; 2 + 2 keeps
          // them readable instead of cutting them off.
          final textScale = MediaQuery.textScalerOf(context).scale(11) / 11;
          final perItem = constraints.maxWidth / items.length;
          if (items.length <= 3 || perItem >= 58 * textScale) {
            return _planActionRow(items);
          }
          return Column(
            key: const ValueKey('plan-actions-two-rows'),
            mainAxisSize: MainAxisSize.min,
            children: [
              _planActionRow(items.sublist(0, 2)),
              const RowDivider(),
              _planActionRow(items.sublist(2)),
            ],
          );
        },
      ),
    );
  }
}

Widget _planActionRow(List<Widget> items) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const _PlanActionDivider(),
          Expanded(child: items[i]),
        ],
      ],
    ),
  );
}

class _PlanActionItem extends StatelessWidget {
  const _PlanActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final Widget icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final themedIcon = IconTheme(
      data: IconThemeData(color: AppColors.accentStrongForeground),
      child: icon,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              themedIcon,
              const SizedBox(height: 6),
              Tooltip(
                message: title,
                excludeFromSemantics: true,
                child: Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanActionDivider extends StatelessWidget {
  const _PlanActionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: AppColors.divider);
  }
}

enum _AreaAction { rename, anchor, order, manage, delete, auto, nearest, box }

PopupMenuItem<_AreaAction> _areaItem(
  _AreaAction action,
  IconData icon,
  String label, {
  Color? color,
}) {
  return PopupMenuItem(
    value: action,
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Flexible(
          child: Text(label, style: TextStyle(color: color)),
        ),
      ],
    ),
  );
}

/// Bulk actions for the selected spots, on an ink rule above the nav bar.
class _EditBar extends StatelessWidget {
  const _EditBar({
    required this.hasSelection,
    required this.onMove,
    required this.onComplete,
    required this.onDelete,
  });

  final bool hasSelection;
  final VoidCallback onMove;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('plan-edit-bar'),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.ink)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: hasSelection ? onMove : null,
                icon: const Icon(LucideIcons.folderInput, size: 18),
                label: Text(l10n.pointManagerMove),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: hasSelection ? onComplete : null,
                icon: const Icon(LucideIcons.check, size: 18),
                label: Text(l10n.planEditMarkVisited),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: hasSelection ? onDelete : null,
                icon: const Icon(LucideIcons.trash2, size: 18),
                label: Text(l10n.commonDelete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSwitcher extends StatelessWidget {
  const _GroupSwitcher({
    required this.groups,
    required this.selectedIndex,
    required this.showProgressRing,
    required this.onSelectGroup,
    required this.onCreateGroup,
    required this.onAreaAction,
  });

  final ValueChanged<_AreaAction> onAreaAction;
  final List<PlanGroupBucket> groups;
  final int selectedIndex;
  final bool showProgressRing;
  final ValueChanged<PlanGroupBucket> onSelectGroup;
  final Future<PilgrimagePlanGroup?> Function() onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final group = groups[selectedIndex];
    return Padding(
      key: const ValueKey('plan-group-switcher'),
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: selectedIndex == 0
                ? null
                : () => onSelectGroup(groups[selectedIndex - 1]),
            icon: const Icon(LucideIcons.chevronLeft),
            tooltip: l10n.planPreviousArea,
          ),
          // The area name is a picker, unframed like the plan title.
          Expanded(
            child: InkWell(
              key: const ValueKey('plan-area-picker'),
              onTap: () => _showGroupPicker(context),
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.chevronDown, size: 18),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: selectedIndex == groups.length - 1
                ? null
                : () => onSelectGroup(groups[selectedIndex + 1]),
            icon: const Icon(LucideIcons.chevronRight),
            tooltip: l10n.planNextArea,
          ),
          PopupMenuButton<_AreaAction>(
            key: const ValueKey('plan-area-actions'),
            tooltip: l10n.planGroupManagerAreaActions,
            icon: const Icon(LucideIcons.ellipsisVertical),
            onSelected: onAreaAction,
            itemBuilder: (context) => [
              if (group.isUngrouped) ...[
                _areaItem(
                  _AreaAction.auto,
                  LucideIcons.wandSparkles,
                  l10n.anitabiMapImportAutoGroup,
                ),
                _areaItem(
                  _AreaAction.nearest,
                  LucideIcons.locateFixed,
                  l10n.pointManagerNearestAssign,
                ),
                _areaItem(
                  _AreaAction.box,
                  LucideIcons.scan,
                  l10n.pointManagerBoxAssign,
                ),
              ] else ...[
                _areaItem(
                  _AreaAction.rename,
                  LucideIcons.pencil,
                  l10n.planGroupManagerRename,
                ),
                _areaItem(
                  _AreaAction.anchor,
                  LucideIcons.flag,
                  l10n.planGroupManagerSetAnchor,
                ),
                _areaItem(
                  _AreaAction.order,
                  LucideIcons.arrowUpDown,
                  group.isManualOrder
                      ? l10n.planGroupManagerSwitchToUnordered
                      : l10n.planGroupManagerSwitchToManualOrder,
                ),
              ],
              _areaItem(
                _AreaAction.manage,
                LucideIcons.layers,
                l10n.pointManagerGroupManagement,
              ),
              if (!group.isUngrouped)
                _areaItem(
                  _AreaAction.delete,
                  LucideIcons.trash2,
                  l10n.planGroupManagerDeleteArea,
                  color: AppColors.error,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGroupPicker(BuildContext context) {
    showPlanGroupPickerSheet(
      context: context,
      groups: groups,
      selectedGroupId: groups[selectedIndex].id,
      showProgressRing: showProgressRing,
      onSelectGroup: onSelectGroup,
      onCreateGroup: onCreateGroup,
    );
  }
}

class _PlanGroupControls extends StatelessWidget {
  const _PlanGroupControls({
    required this.locationError,
    required this.group,
    required this.showMap,
    required this.sortMode,
    required this.sortDescending,
    required this.mapHeightRatio,
    required this.settings,
    required this.showVirtualLocation,
    required this.isLocating,
    required this.currentLocation,
    required this.selectedPointId,
    required this.completedPointIds,
    required this.onSetSortMode,
    required this.onToggleSortDirection,
    required this.onToggleMap,
    required this.onResizeMap,
    required this.onToggleVirtualLocation,
    required this.onSelectPoint,
  });

  final PlanGroupBucket group;
  final String? locationError;
  final bool showMap;
  final PointSortMode sortMode;
  final bool sortDescending;
  final double mapHeightRatio;
  final AppSettings settings;
  final bool showVirtualLocation;
  final bool isLocating;
  final LatLng? currentLocation;
  final String? selectedPointId;
  final Set<String> completedPointIds;
  final ValueChanged<PointSortMode> onSetSortMode;
  final VoidCallback onToggleSortDirection;
  final VoidCallback onToggleMap;
  final void Function(double deltaY, double viewportHeight) onResizeMap;
  final VoidCallback onToggleVirtualLocation;
  final ValueChanged<PilgrimagePoint> onSelectPoint;

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final safePadding = MediaQuery.paddingOf(context);
    final maxMapHeight =
        (viewportHeight -
                safePadding.top -
                safePadding.bottom -
                kToolbarHeight -
                kBottomNavigationBarHeight -
                210)
            .clamp(150.0, 490.0);
    final mapHeight = (viewportHeight * mapHeightRatio).clamp(
      150.0,
      maxMapHeight,
    );
    // The controls inset 12; the map runs full width like the list.
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: _SortOrderControl(
                    mode: sortMode,
                    descending: sortDescending,
                    onChanged: onSetSortMode,
                    onToggleDirection: onToggleSortDirection,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onToggleMap,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(74, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: Icon(
                    showMap ? LucideIcons.map : LucideIcons.map,
                    size: 18,
                  ),
                  label: Text(showMap ? l10n.planHideMap : l10n.planMap),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (showMap) ...[
            if (locationError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  locationError!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            _PlanInlineMap(
              group: group,
              completedPointIds: completedPointIds,
              selectedPointId: selectedPointId,
              showVirtualLocation: showVirtualLocation,
              isLocating: isLocating,
              currentLocation: currentLocation,
              height: mapHeight,
              settings: settings,
              onSelectPoint: onSelectPoint,
              onToggleVirtualLocation: onToggleVirtualLocation,
              onDrag: (deltaY) => onResizeMap(deltaY, viewportHeight),
            ),
            _MapResizeHandle(
              onDrag: (deltaY) => onResizeMap(deltaY, viewportHeight),
            ),
          ],
        ],
      ),
    );
  }
}

class _SortOrderControl extends StatelessWidget {
  const _SortOrderControl({
    required this.mode,
    required this.descending,
    required this.onChanged,
    required this.onToggleDirection,
  });

  final PointSortMode mode;
  final bool descending;
  final ValueChanged<PointSortMode> onChanged;
  final VoidCallback onToggleDirection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          children: [
            Expanded(
              child: MenuAnchor(
                builder: closesOnBack((context, controller, child) {
                  return InkWell(
                    borderRadius: BorderRadius.zero,
                    onTap: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.arrowUpDown, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _sortModeLabel(mode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          const Icon(LucideIcons.chevronDown, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(LucideIcons.listOrdered),
                    onPressed: () => onChanged(PointSortMode.plan),
                    child: Text(l10n.planSortDefaultOrder),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(LucideIcons.navigation),
                    onPressed: () => onChanged(PointSortMode.distance),
                    child: Text(l10n.planSortByDistanceFromHere),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
              child: VerticalDivider(width: 1, color: AppColors.divider),
            ),
            Tooltip(
              message: _sortDirectionTooltip(mode, descending),
              child: InkWell(
                borderRadius: BorderRadius.zero,
                onTap: onToggleDirection,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    descending ? LucideIcons.arrowDown : LucideIcons.arrowUp,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _sortModeLabel(PointSortMode mode) {
  return switch (mode) {
    PointSortMode.plan => l10n.planSortDefault,
    PointSortMode.distance => l10n.planSortDistance,
  };
}

String _sortDirectionTooltip(PointSortMode mode, bool descending) {
  return switch (mode) {
    PointSortMode.plan =>
      descending ? l10n.planSortReversed : l10n.planSortForward,
    PointSortMode.distance =>
      descending ? l10n.planSortFarToNear : l10n.planSortNearToFar,
  };
}

class _PlanInlineMap extends StatefulWidget {
  const _PlanInlineMap({
    required this.group,
    required this.completedPointIds,
    required this.selectedPointId,
    required this.showVirtualLocation,
    required this.isLocating,
    required this.currentLocation,
    required this.height,
    required this.settings,
    required this.onSelectPoint,
    required this.onToggleVirtualLocation,
    required this.onDrag,
  });

  final PlanGroupBucket group;
  final Set<String> completedPointIds;
  final String? selectedPointId;
  final bool showVirtualLocation;
  final bool isLocating;
  final LatLng? currentLocation;
  final double height;
  final AppSettings settings;
  final ValueChanged<PilgrimagePoint> onSelectPoint;
  final VoidCallback onToggleVirtualLocation;
  final ValueChanged<double> onDrag;

  @override
  State<_PlanInlineMap> createState() => _PlanInlineMapState();
}

class _PlanInlineMapState extends State<_PlanInlineMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant _PlanInlineMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentLocation = widget.currentLocation;
    if (widget.showVirtualLocation &&
        currentLocation != null &&
        !oldWidget.showVirtualLocation) {
      _mapController.move(currentLocation, _mapController.camera.zoom);
      return;
    }

    if (widget.group.id != oldWidget.group.id) {
      _showGroup();
    } else if (widget.selectedPointId != oldWidget.selectedPointId) {
      final point = _selectedPoint;
      if (point != null &&
          !_mapController.camera.visibleBounds.contains(point.position)) {
        _mapController.move(point.position, _mapController.camera.zoom);
      }
    }
  }

  /// Frames every spot of the area; null when it has fewer than two.
  CameraFit? get _areaFit {
    final coordinates = [
      for (final point in widget.group.points)
        if (point.hasCoordinate) point.position,
    ];
    if (coordinates.length < 2) {
      return null;
    }
    return CameraFit.coordinates(
      coordinates: coordinates,
      padding: const EdgeInsets.all(36),
      maxZoom: 16,
    );
  }

  void _showGroup() {
    final fit = _areaFit;
    if (fit == null) {
      _mapController.move(_initialCenter, 15.2);
    } else {
      _mapController.fitCamera(fit);
    }
  }

  PilgrimagePoint? get _selectedPoint {
    final selectedPointId = widget.selectedPointId;
    if (selectedPointId == null) {
      return null;
    }
    for (final point in widget.group.points) {
      if (point.id == selectedPointId && point.hasCoordinate) {
        return point;
      }
    }
    return null;
  }

  LatLng get _initialCenter {
    final selectedPoint = _selectedPoint;
    if (selectedPoint != null) {
      return selectedPoint.position;
    }
    if (widget.showVirtualLocation && widget.currentLocation != null) {
      return widget.currentLocation!;
    }
    return groupMapCenter(widget.group);
  }

  @override
  Widget build(BuildContext context) {
    final mapPoints = selectedItemsLast<PilgrimagePoint>(
      widget.group.points.where((point) => point.hasCoordinate),
      isSelected: (point) => point.id == widget.selectedPointId,
    );

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: rowDividerSide),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 15.2,
                  // Opening the map shows the whole area, as switching does.
                  initialCameraFit: _areaFit,
                  minZoom: 4,
                  maxZoom: widget.settings.mapMaxZoom.toDouble(),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  configuredMapTileLayer(widget.settings),
                  MarkerLayer(
                    markers: [
                      for (final point in mapPoints)
                        Marker(
                          point: point.position,
                          width: scaledMapMarkerDimension(
                            point.id == widget.selectedPointId ? 34 : 28,
                            widget.settings.mapMarkerScale,
                          ),
                          height: scaledMapMarkerDimension(
                            point.id == widget.selectedPointId ? 34 : 28,
                            widget.settings.mapMarkerScale,
                          ),
                          child: ScaledMapMarker(
                            scale: widget.settings.mapMarkerScale,
                            baseWidth: point.id == widget.selectedPointId
                                ? 34
                                : 28,
                            baseHeight: point.id == widget.selectedPointId
                                ? 34
                                : 28,
                            child: GestureDetector(
                              onTap: () => widget.onSelectPoint(point),
                              child: _MapPointMarker(
                                key: ValueKey('plan-map-marker-${point.id}'),
                                selected: point.id == widget.selectedPointId,
                                completed: widget.completedPointIds.contains(
                                  point.id,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.showVirtualLocation &&
                          widget.currentLocation != null)
                        Marker(
                          point: widget.currentLocation!,
                          width: scaledMapMarkerDimension(
                            36,
                            widget.settings.mapMarkerScale,
                          ),
                          height: scaledMapMarkerDimension(
                            36,
                            widget.settings.mapMarkerScale,
                          ),
                          child: ScaledMapMarker(
                            scale: widget.settings.mapMarkerScale,
                            baseWidth: 36,
                            baseHeight: 36,
                            child: const _CurrentLocationDot(),
                          ),
                        ),
                    ],
                  ),
                  configuredMapAttribution(widget.settings),
                ],
              ),
              Positioned(
                left: 10,
                top: 10,
                right: 56,
                child: IgnorePointer(
                  child: _MapCompactSummary(group: widget.group),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: _MapFloatingIconButton(
                  tooltip: widget.showVirtualLocation
                      ? l10n.planHideLocation
                      : l10n.planShowLocation,
                  icon: widget.isLocating
                      ? null
                      : widget.showVirtualLocation
                      ? LucideIcons.locateFixed
                      : LucideIcons.locateFixed,
                  onTap: widget.isLocating
                      ? null
                      : widget.onToggleVirtualLocation,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _MapResizeHotZone(onDrag: widget.onDrag),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapCompactSummary extends StatelessWidget {
  const _MapCompactSummary({required this.group});

  final PlanGroupBucket group;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        border: Border.all(color: AppColors.ink),
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          l10n.planAreaProgress(
            group.anchorLabel,
            group.completedCount,
            group.points.length,
            group.orderModeLabel,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _MapResizeHandle extends StatelessWidget {
  const _MapResizeHandle({required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
      child: SizedBox(
        height: 10,
        width: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 48,
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapResizeHotZone extends StatelessWidget {
  const _MapResizeHotZone({required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
      child: const SizedBox(height: 24, width: double.infinity),
    );
  }
}

class _MapPointMarker extends StatelessWidget {
  const _MapPointMarker({
    required this.selected,
    required this.completed,
    super.key,
  });

  final bool selected;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final markerColor = selected
        ? MapColors.accentDark
        : completed
        ? AppColors.textSecondary
        : MapColors.accent;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: selected ? 2.5 : 2),
      ),
      child: Icon(
        completed ? LucideIcons.check : LucideIcons.mapPin,
        size: selected ? 19 : 15,
        color: AppColors.isDark ? MapColors.onAccent : Colors.white,
      ),
    );
  }
}

class _CurrentLocationDot extends StatelessWidget {
  const _CurrentLocationDot();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const SizedBox(width: 16, height: 16),
        ),
      ),
    );
  }
}

class _MapFloatingIconButton extends StatelessWidget {
  const _MapFloatingIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.zero,
        child: InkWell(
          borderRadius: BorderRadius.zero,
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: icon == null
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _EmptyPlanCard extends StatelessWidget {
  const _EmptyPlanCard({required this.onAddPoints});

  final VoidCallback onAddPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        border: Border(top: sectionRuleSide, bottom: rowDividerSide),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.package, color: AppColors.accentForeground),
              const SizedBox(width: 10),
              Text(
                l10n.planNoSpotsYet,
                style: TextStyle(
                  color: AppColors.accentStrongForeground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _OnboardingTimeline(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('plan-add-points'),
              onPressed: onAddPoints,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(LucideIcons.mapPinPlus, size: 20),
              label: Text(l10n.planAddSpots),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingTimeline extends StatelessWidget {
  const _OnboardingTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OnboardingStep(
          number: 1,
          title: l10n.planOnboardingFindTitle,
          body: l10n.planOnboardingFindBody,
        ),
        _OnboardingStep(
          number: 2,
          title: l10n.planOnboardingSpotsTitle,
          body: l10n.planOnboardingSpotsBody,
        ),
        _OnboardingStep(
          number: 3,
          title: l10n.planOnboardingShootTitle,
          body: l10n.planOnboardingShootBody,
          isLast: true,
        ),
      ],
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.number,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final int number;
  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: AppColors.onAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 26,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkHeader extends StatelessWidget {
  const _WorkHeader({required this.plan});

  final PilgrimagePlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        border: Border(top: sectionRuleSide, bottom: rowDividerSide),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            constraints: const BoxConstraints(minWidth: 52),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(
              LucideIcons.clapperboard,
              color: AppColors.accentStrongForeground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.planSummary(plan.points.length, _workCountText(plan)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _workCountText(PilgrimagePlan plan) {
    final count = plan.works.isNotEmpty
        ? plan.works.length
        : plan.points.map((point) => point.work.id).toSet().length;
    return l10n.planWorkCount(count);
  }
}

class _PlanPointTile extends StatelessWidget {
  const _PlanPointTile({
    required this.controller,
    required this.point,
    required this.status,
    required this.recordCount,
    required this.onTap,
    required this.onOpenCamera,
    required this.onComplete,
    required this.onReopen,
    this.editing = false,
    this.selected = false,
    this.reorderIndex,
    this.onLongPress,
    super.key,
  });

  final bool editing;
  final bool selected;

  /// Set when the row can be dragged; the grip starts the drag.
  final int? reorderIndex;
  final VoidCallback? onLongPress;
  final PilgrimagePlanController controller;
  final PilgrimagePoint point;
  final VisitStatus status;
  final int recordCount;
  final VoidCallback onTap;
  final VoidCallback onOpenCamera;
  final VoidCallback onComplete;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);
    final visited = status == VisitStatus.completed;
    // Repeated row actions stay frameless, as Tsumiki's quiet keys.
    final keyStyle = IconButton.styleFrom(
      fixedSize: const Size(48, 48),
      minimumSize: const Size(48, 48),
    );

    return Material(
      // The next stop sits on the accent wash; rows are split by rules.
      color: selected || status == VisitStatus.current
          ? AppColors.accentWash
          : AppColors.surface,
      shape: Border(bottom: BorderSide(color: AppColors.divider)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.fromLTRB(editing ? 0 : 12, 10, 4, 10),
          child: Row(
            children: [
              if (editing) Checkbox(value: selected, onChanged: (_) => onTap()),
              // The anime frame at its own 16:9, not cropped to a square.
              SizedBox(
                width: 72,
                height: 41,
                child: ColoredBox(
                  color: colors.background,
                  child: _PlanPointThumbnail(
                    controller: controller,
                    point: point,
                    placeholder: Icon(
                      colors.icon,
                      color: colors.foreground,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        color: visited
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: visited ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      point.work.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              if (editing)
                if (reorderIndex case final index?)
                  ReorderableDragStartListener(
                    index: index,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        LucideIcons.gripVertical,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink()
              else ...[
                const SizedBox(width: 4),
                IconButton(
                  style: keyStyle,
                  tooltip: visited ? l10n.planUndoCheckIn : l10n.planComplete,
                  onPressed: visited ? onReopen : onComplete,
                  icon: Icon(
                    visited ? LucideIcons.rotateCcw : LucideIcons.check,
                    size: 20,
                  ),
                ),
                IconButton(
                  style: keyStyle,
                  color: AppColors.accentForeground,
                  tooltip: l10n.planShootReference,
                  onPressed: onOpenCamera,
                  icon: SizedBox(
                    width: 22,
                    height: 22,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Center(child: Icon(LucideIcons.camera, size: 20)),
                        if (recordCount > 0)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: _PointRecordBadge(stacked: recordCount > 1),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _PointStatusColors _statusColors(VisitStatus status) {
    return switch (status) {
      VisitStatus.current => _PointStatusColors(
        background: AppColors.accent,
        foreground: Colors.white,
        border: AppColors.accent,
        icon: LucideIcons.flag,
      ),
      VisitStatus.completed => _PointStatusColors(
        background: AppColors.surfaceMuted,
        foreground: AppColors.textSecondary,
        border: AppColors.border,
        icon: LucideIcons.circleCheckBig,
      ),
      VisitStatus.pending => _PointStatusColors(
        background: AppColors.surfaceMuted,
        foreground: AppColors.textTertiary,
        border: AppColors.border,
        icon: LucideIcons.mapPin,
      ),
    };
  }
}

class _PlanPointThumbnail extends StatelessWidget {
  const _PlanPointThumbnail({
    required this.controller,
    required this.point,
    required this.placeholder,
  });

  final PilgrimagePlanController controller;
  final PilgrimagePoint point;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final repository = controller.repository;
    final remoteImageUrl = hasRemoteReferenceImage(point)
        ? point.referenceImageUrl
        : null;
    if (repository == null) {
      return ReferenceThumbnail(
        localPath: point.referenceThumbnailPath,
        imageUrl: remoteImageUrl,
        placeholder: placeholder,
      );
    }
    return AutoCachingReferenceThumbnail(
      planId: controller.plan.id,
      point: point,
      repository: repository,
      onPlanUpdated: controller.replacePlan,
      placeholder: placeholder,
    );
  }
}

class _PointRecordBadge extends StatelessWidget {
  const _PointRecordBadge({required this.stacked});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('plan-point-shot-badge'),
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.42)),
      ),
      child: Icon(
        stacked ? LucideIcons.images : LucideIcons.image,
        size: 10,
        color: AppColors.accentStrongForeground,
      ),
    );
  }
}

class _PointStatusColors {
  _PointStatusColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;
}
