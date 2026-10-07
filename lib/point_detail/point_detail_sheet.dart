import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';

import '../app_theme.dart';
import '../data/user_reference_image_stub.dart'
    if (dart.library.io) '../data/user_reference_image_io.dart';
import '../map/navigation_route_confirm_screen.dart';
import '../widgets/snackbar_helper.dart';
import '../map/map_navigation_launcher.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../plan/plan_group_picker_sheet.dart';
import '../plan/plan_group_utils.dart';
import '../records/visit_record_photo_stub.dart'
    if (dart.library.io) '../records/visit_record_photo_io.dart';
import '../widgets/copyable_text.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/image_viewer_screen.dart';
import '../widgets/responsive_button.dart';
import '../widgets/split_navigation_button.dart';
import '../plan/reference_image_status.dart';
import '../widgets/reference_thumbnail_stub.dart'
    if (dart.library.io) '../widgets/reference_thumbnail_io.dart';
import '../l10n/l10n.dart';

enum PointDetailActionScope { visit, manage, assign }

class PointDetailSheet extends StatelessWidget {
  const PointDetailSheet({
    required this.point,
    required this.status,
    required this.onReplaceReference,
    this.onSetCurrent,
    this.onOpenCamera,
    this.onComplete,
    this.actionScope = PointDetailActionScope.visit,
    this.groups = const [],
    this.groupBuckets = const [],
    this.onMoveToGroup,
    this.onCreateGroup,
    this.records = const [],
    this.onOpenRecords,
    this.onOpenRecord,
    this.onEditPoint,
    this.onDelete,
    this.navigationApp = NavigationApp.googleMaps,
    this.navigationLauncher = const MapNavigationLauncher(),
    this.settings = const AppSettings(),
    this.planController,
    super.key,
  });

  final PilgrimagePoint point;
  final VisitStatus status;
  final VoidCallback? onSetCurrent;
  final VoidCallback? onOpenCamera;
  final VoidCallback? onComplete;
  final Future<void> Function(
    PilgrimagePoint point,
    StoredUserReferenceImage image,
  )
  onReplaceReference;
  final PointDetailActionScope actionScope;
  final List<PilgrimagePlanGroup> groups;
  final List<PlanGroupBucket> groupBuckets;
  final Future<void> Function(PilgrimagePoint point, String? groupId)?
  onMoveToGroup;
  final Future<PilgrimagePlanGroup?> Function()? onCreateGroup;
  final List<PilgrimageVisitRecord> records;
  final VoidCallback? onOpenRecords;
  final ValueChanged<PilgrimageVisitRecord>? onOpenRecord;
  final VoidCallback? onEditPoint;
  final Future<void> Function(PilgrimagePoint point)? onDelete;
  final NavigationApp navigationApp;
  final MapNavigationLauncher navigationLauncher;
  final AppSettings settings;
  final PilgrimagePlanController? planController;

  static Future<void> show(
    BuildContext context, {
    required PilgrimagePoint point,
    required VisitStatus status,
    required Future<void> Function(
      PilgrimagePoint point,
      StoredUserReferenceImage image,
    )
    onReplaceReference,
    VoidCallback? onSetCurrent,
    VoidCallback? onOpenCamera,
    VoidCallback? onComplete,
    PointDetailActionScope actionScope = PointDetailActionScope.visit,
    List<PilgrimagePlanGroup> groups = const [],
    List<PlanGroupBucket> groupBuckets = const [],
    Future<void> Function(PilgrimagePoint point, String? groupId)?
    onMoveToGroup,
    Future<PilgrimagePlanGroup?> Function()? onCreateGroup,
    List<PilgrimageVisitRecord> records = const [],
    VoidCallback? onOpenRecords,
    ValueChanged<PilgrimageVisitRecord>? onOpenRecord,
    VoidCallback? onEditPoint,
    Future<void> Function(PilgrimagePoint point)? onDelete,
    NavigationApp navigationApp = NavigationApp.googleMaps,
    AppSettings settings = const AppSettings(),
    PilgrimagePlanController? planController,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return PointDetailSheet(
          point: point,
          status: status,
          onSetCurrent: onSetCurrent,
          onOpenCamera: onOpenCamera,
          onComplete: onComplete,
          onReplaceReference: onReplaceReference,
          actionScope: actionScope,
          groups: groups,
          groupBuckets: groupBuckets,
          onMoveToGroup: onMoveToGroup,
          onCreateGroup: onCreateGroup,
          records: records,
          onOpenRecords: onOpenRecords,
          onOpenRecord: onOpenRecord,
          onEditPoint: onEditPoint,
          onDelete: onDelete,
          navigationApp: navigationApp,
          settings: settings,
          planController: planController,
        );
      },
    );
  }

  Future<void> _replaceReferenceImage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !context.mounted) {
      return;
    }

    void showStatus(AppStatusBannerKind kind, String title) {
      if (messenger.mounted) {
        messenger.showStatusSnack(kind: kind, title: title);
      }
    }

    messenger.showStatusSnack(
      kind: AppStatusBannerKind.running,
      title: l10n.pointDetailReplacingReference,
      icon: LucideIcons.arrowLeftRight,
    );
    // Every exit below replaces the running banner so it can never stick.
    StoredUserReferenceImage? stored;
    try {
      stored = await storeUserReferenceImage(
        sourcePath: picked.path,
        pointId: point.id,
      );
    } catch (_) {
      showStatus(
        AppStatusBannerKind.error,
        l10n.pointDetailReplaceReferenceFailed,
      );
      return;
    }
    if (stored == null) {
      showStatus(
        AppStatusBannerKind.error,
        l10n.pointDetailReplaceReferenceFailed,
      );
      return;
    }
    if (!context.mounted) {
      // The sheet closed before anything was committed: drop the copy.
      await deleteStoredUserReferenceImage(stored);
      showStatus(
        AppStatusBannerKind.warning,
        l10n.pointDetailReplaceReferenceCanceled,
      );
      return;
    }

    try {
      await onReplaceReference(point, stored);
    } catch (_) {
      // The save may have committed before the error surfaced (e.g. while
      // re-reading the plan), so the stored image is kept, never deleted.
      showStatus(
        AppStatusBannerKind.error,
        l10n.pointDetailReplaceReferenceFailed,
      );
      return;
    }

    showStatus(AppStatusBannerKind.success, l10n.pointDetailReferenceReplaced);
    if (context.mounted) {
      navigator.pop();
    }
  }

  Future<void> _openExternalNavigation(BuildContext context) async {
    if (!point.hasCoordinate) {
      return;
    }
    var opened = false;
    try {
      opened = await navigationLauncher.openWalking(point, navigationApp);
    } catch (_) {
      // Platform launchers can throw instead of returning false.
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.pointDetailOpenNavigationFailed(navigationApp.label),
      );
    }
  }

  Future<void> _openInAppNavigation(BuildContext context) async {
    if (!point.hasCoordinate) {
      return;
    }
    final navigator = Navigator.of(context);
    final tour = inAppNavigationTourFor(point: point, buckets: groupBuckets);
    final route = NavigationRouteConfirmScreen.route(
      point: point,
      settings: settings,
      groupName: tour.groupName,
      stops: tour.stops,
      planController: planController,
    );
    navigator.pop();
    await navigator.push<void>(route);
  }

  Future<void> _showMoveGroupSheet(BuildContext context) async {
    final moveToGroup = onMoveToGroup;
    if (moveToGroup == null) {
      return;
    }
    await _showPlanMoveGroupSheet(context, moveToGroup);
  }

  Future<void> _showPlanMoveGroupSheet(
    BuildContext context,
    Future<void> Function(PilgrimagePoint point, String? groupId) moveToGroup,
  ) async {
    const ungroupedOptionId = '__ungrouped__';
    final pickerGroups = sortGroupsByPlanOrder(groups);
    final selectedGroupId = await showPlanGroupSelectionSheet(
      context: context,
      title: l10n.pointDetailMoveToArea,
      subtitle: l10n.pointDetailMoveToAreaHint,
      selectedOptionId: point.groupId ?? ungroupedOptionId,
      options: [
        PlanGroupSelectionOption(
          id: ungroupedOptionId,
          title: l10n.pointDetailNotInArea,
        ),
        for (final group in pickerGroups)
          PlanGroupSelectionOption(id: group.id, title: group.name),
      ],
      onCreateOption: onCreateGroup == null
          ? null
          : () async {
              final created = await onCreateGroup!();
              return created == null
                  ? null
                  : PlanGroupSelectionOption(
                      id: created.id,
                      title: created.name,
                    );
            },
    );
    if (!context.mounted || selectedGroupId == null) {
      return;
    }

    final groupId = selectedGroupId == ungroupedOptionId
        ? null
        : selectedGroupId;
    await moveToGroup(point, groupId);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.84;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: sheetHeight,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReferenceColumn(
                      point: point,
                      status: status,
                      onReplace: () => _replaceReferenceImage(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _StatusBadge(
                                  key: const ValueKey(
                                    'point-detail-status-badge',
                                  ),
                                  status: status,
                                ),
                                const Expanded(child: SizedBox.shrink()),
                                if (onDelete != null)
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: _DeletePointButton(
                                      key: ValueKey(point.id),
                                      point: point,
                                      onDelete: onDelete!,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          CopyableText(
                            text: point.name,
                            copyLabel: l10n.pointDetailCopySpotName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            joinLabels([
                              point.work.title,
                              point.displaySubtitle,
                            ]),
                            maxLines: 2,
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
                const SizedBox(height: 16),
                _InfoRow(
                  icon: LucideIcons.clapperboard,
                  label: l10n.pointDetailWorkLabel,
                  value: joinLabels([
                    point.work.title,
                    point.work.displaySubtitle,
                  ]),
                ),
                if (point.displayEpisodeLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: LucideIcons.film,
                    label: l10n.pointDetailSceneLabel,
                    value: point.displayEpisodeLabel,
                  ),
                ],
                const SizedBox(height: 8),
                _InfoRow(
                  icon: LucideIcons.mapPin,
                  label: l10n.pointDetailCoordinatesLabel,
                  value: point.hasCoordinate
                      ? '${point.position.latitude.toStringAsFixed(5)}, ${point.position.longitude.toStringAsFixed(5)}'
                      : l10n.pointDetailCoordinatesMissing,
                ),
                const SizedBox(height: 8),
                _GroupInfoRow(
                  groupName: _groupName,
                  anchorLabel: _groupAnchorLabel,
                  onMove: onMoveToGroup == null
                      ? null
                      : () => _showMoveGroupSheet(context),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: LucideIcons.image,
                  label: l10n.pointDetailReferenceLabel,
                  value: point.referenceLabel,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: LucideIcons.fileCode,
                  label: l10n.pointDetailSourceLabel,
                  value: _sourceText,
                ),
                if (point.sourceId != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: LucideIcons.tag,
                    label: 'ID',
                    value: point.sourceId!,
                  ),
                ],
                if (point.sourceUrl != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: LucideIcons.link,
                    label: l10n.pointDetailLinkLabel,
                    value: point.sourceUrl!,
                  ),
                ],
                if (point.note?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: LucideIcons.stickyNote,
                    label: l10n.pointDetailNoteLabel,
                    value: point.note!,
                  ),
                ],
                if (records.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _PointRecordsPreview(
                    records: records,
                    onOpenRecords: onOpenRecords == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            onOpenRecords!();
                          },
                    onOpenRecord: onOpenRecord == null
                        ? null
                        : (record) {
                            Navigator.of(context).pop();
                            onOpenRecord!(record);
                          },
                  ),
                ],
                const SizedBox(height: 18),
                _PointDetailActions(
                  scope: actionScope,
                  status: status,
                  onOpenInAppNavigation: point.hasCoordinate
                      ? () => _openInAppNavigation(context)
                      : null,
                  onOpenExternalNavigation: point.hasCoordinate
                      ? () => _openExternalNavigation(context)
                      : null,
                  onOpenCamera: onOpenCamera == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onOpenCamera!();
                        },
                  onSetCurrent: onSetCurrent == null || !point.hasCoordinate
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onSetCurrent!();
                        },
                  statusAction: onComplete == null ? null : _statusAction,
                  onEditPoint: onEditPoint == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onEditPoint!();
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _sourceText {
    return switch (point.source) {
      PointSource.anitabi => 'Anitabi / ${point.referenceLabel}',
      PointSource.manual => l10n.pointDetailManualSource(point.referenceLabel),
    };
  }

  _PointStatusAction get _statusAction {
    return switch (status) {
      VisitStatus.completed => _PointStatusAction(
        label: l10n.pointDetailUndoCheckIn,
        shortLabel: l10n.pointDetailUndoShort,
        icon: LucideIcons.undo2,
        onTap: onComplete!,
      ),
      VisitStatus.current => _PointStatusAction(
        label: l10n.pointDetailMarkDone,
        shortLabel: l10n.pointDetailMarkDoneShort,
        icon: LucideIcons.circleCheckBig,
        onTap: onComplete!,
      ),
      VisitStatus.pending => _PointStatusAction(
        label: l10n.pointDetailMarkDone,
        shortLabel: l10n.pointDetailMarkDoneShort,
        icon: LucideIcons.circleCheckBig,
        onTap: onComplete!,
      ),
    };
  }

  String get _groupName {
    final groupId = point.groupId;
    if (groupId == null) {
      return l10n.pointDetailNotInArea;
    }
    return groups
        .firstWhere(
          (group) => group.id == groupId,
          orElse: () => PilgrimagePlanGroup(
            id: groupId,
            name: l10n.pointDetailUnknownArea,
            orderIndex: 0,
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .name;
  }

  String get _groupAnchorLabel {
    final groupId = point.groupId;
    if (groupId == null) {
      return l10n.pointDetailNoAnchor;
    }
    final group = groups.where((group) => group.id == groupId).firstOrNull;
    final anchorName = group?.anchorName;
    if (anchorName == null || anchorName.trim().isEmpty) {
      return l10n.pointDetailNoAnchor;
    }
    return anchorName;
  }
}

class _DeletePointButton extends StatefulWidget {
  const _DeletePointButton({
    required this.point,
    required this.onDelete,
    super.key,
  });

  final PilgrimagePoint point;
  final Future<void> Function(PilgrimagePoint point) onDelete;

  @override
  State<_DeletePointButton> createState() => _DeletePointButtonState();
}

class _DeletePointButtonState extends State<_DeletePointButton> {
  bool _busy = false;
  bool _deleted = false;

  Future<void> _deletePoint() async {
    if (_busy || _deleted) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      return;
    }
    final navigator = Navigator.of(context);
    final point = widget.point;
    final deletePoint = widget.onDelete;
    setState(() => _busy = true);

    try {
      final confirmed = await showConfirmActionDialog(
        context,
        title: l10n.pointDetailDeleteSpot,
        message: l10n.pointDetailDeleteSpotMessage(point.name),
        confirmLabel: l10n.pointDetailDeleteSpot,
        destructive: true,
        emphasizedValues: [point.name],
      );
      if (!confirmed || !mounted || !route.isActive || !route.isCurrent) {
        return;
      }

      await deletePoint(point);
      if (!mounted) {
        return;
      }
      _deleted = true;
      // A dismissed sheet stays mounted during its exit animation.
      if (route.isActive && route.isCurrent) {
        navigator.pop();
      } else if (route.isActive) {
        navigator.removeRoute(route);
      }
    } catch (_) {
      if (!mounted || !route.isActive || !route.isCurrent) {
        return;
      }
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.pointDetailDeleteSpotFailed,
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _busy
        ? l10n.pointDetailDeletingSpot
        : (_deleted ? l10n.pointDetailSpotDeleted : l10n.pointDetailDeleteSpot);
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: IconButton(
          key: const ValueKey('point-detail-delete'),
          onPressed: _busy || _deleted ? null : _deletePoint,
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            foregroundColor: AppColors.error,
            minimumSize: Size.zero,
          ),
          constraints: const BoxConstraints.expand(),
          padding: EdgeInsets.zero,
          icon: const Icon(LucideIcons.trash2, size: 16),
        ),
      ),
    );
  }
}

class _PointDetailActions extends StatelessWidget {
  const _PointDetailActions({
    required this.scope,
    required this.status,
    required this.onOpenInAppNavigation,
    required this.onOpenExternalNavigation,
    required this.onOpenCamera,
    required this.onSetCurrent,
    required this.statusAction,
    required this.onEditPoint,
  });

  final PointDetailActionScope scope;
  final VisitStatus status;
  final VoidCallback? onOpenInAppNavigation;
  final VoidCallback? onOpenExternalNavigation;
  final VoidCallback? onOpenCamera;
  final VoidCallback? onSetCurrent;
  final _PointStatusAction? statusAction;
  final VoidCallback? onEditPoint;

  @override
  Widget build(BuildContext context) {
    final canNavigate =
        onOpenInAppNavigation != null || onOpenExternalNavigation != null;
    // Matches the theme's 48dp keys so both halves of a row line up.
    final actionHeight =
        48 + Theme.of(context).visualDensity.baseSizeAdjustment.dy;
    final actionStyle = OutlinedButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    final primaryActions = <Widget>[
      SplitNavigationButton(
        inAppLabel: canNavigate
            ? l10n.pointDetailNavigate
            : l10n.pointDetailNoCoordinates,
        onOpenInAppNavigation: onOpenInAppNavigation,
        onOpenExternalNavigation: onOpenExternalNavigation,
        height: actionHeight,
        inAppKey: const ValueKey('point-detail-in-app-navigation-button'),
        externalKey: const ValueKey('point-detail-external-navigation-button'),
        dividerKey: const ValueKey('point-detail-navigation-button-divider'),
      ),
      if (scope == PointDetailActionScope.visit && onOpenCamera != null) ...[
        OutlinedButton(
          onPressed: onOpenCamera,
          style: actionStyle,
          child: ResponsiveButtonContent(
            icon: LucideIcons.camera,
            label: l10n.pointDetailShootReference,
            shortLabel: l10n.pointDetailShootShort,
            semanticLabel: l10n.pointDetailShootReference,
          ),
        ),
      ],
    ];

    final managementActions = <Widget>[
      if (scope != PointDetailActionScope.assign && onSetCurrent != null)
        OutlinedButton(
          onPressed: status == VisitStatus.current ? null : onSetCurrent,
          style: actionStyle,
          child: ResponsiveButtonContent(
            icon: LucideIcons.flag,
            label: l10n.pointDetailSetCurrent,
            shortLabel: l10n.pointDetailSetCurrentShort,
            semanticLabel: l10n.pointDetailSetCurrentTarget,
          ),
        ),
      if (scope != PointDetailActionScope.assign && statusAction != null) ...[
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            statusAction!.onTap();
          },
          style: actionStyle,
          child: ResponsiveButtonContent(
            icon: statusAction!.icon,
            label: statusAction!.label,
            shortLabel: statusAction!.shortLabel,
            semanticLabel: statusAction!.label,
          ),
        ),
      ],
    ];

    return Column(
      children: [
        _buildActionRow(primaryActions),
        if (managementActions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildActionRow(managementActions),
        ],
        if (onEditPoint != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('point-detail-edit'),
              onPressed: onEditPoint,
              style: actionStyle,
              icon: const Icon(LucideIcons.edit, size: 18),
              label: Text(l10n.pointDetailEditSpot),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionRow(List<Widget> actions) {
    if (actions.length == 1) {
      return SizedBox(width: double.infinity, child: actions.single);
    }
    return ResponsiveTwoButtonRow(first: actions[0], second: actions[1]);
  }
}

class _PointStatusAction {
  const _PointStatusAction({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final VoidCallback onTap;
}

class _ReferenceColumn extends StatelessWidget {
  const _ReferenceColumn({
    required this.point,
    required this.status,
    required this.onReplace,
  });

  final PilgrimagePoint point;
  final VisitStatus status;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final remoteImageUrl = hasRemoteReferenceImage(point)
        ? point.referenceImageUrl
        : null;
    final color = switch (status) {
      VisitStatus.current => AppColors.accent,
      VisitStatus.completed => AppColors.textSecondary,
      VisitStatus.pending => AppColors.accentDark,
    };

    return SizedBox(
      width: 76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => ImageViewerScreen.show(
              context,
              filePath: point.referenceFullImagePath,
              imageUrl: remoteImageUrl,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  border: Border.all(color: AppColors.border),
                ),
                child: ReferenceThumbnail(
                  localPath: point.referenceThumbnailPath,
                  imageUrl: remoteImageUrl,
                  fit: BoxFit.cover,
                  placeholder: Icon(LucideIcons.image, color: color, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: OutlinedButton(
              onPressed: onReplace,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              child: Text(l10n.pointDetailReplace),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupInfoRow extends StatelessWidget {
  const _GroupInfoRow({
    required this.groupName,
    required this.anchorLabel,
    required this.onMove,
  });

  final String groupName;
  final String anchorLabel;
  final VoidCallback? onMove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(LucideIcons.grid2X2, color: AppColors.textSecondary, size: 19),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            l10n.pointDetailArea,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CopyableText(
                text: groupName,
                copyLabel: l10n.pointDetailArea,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              CopyableText(
                text: anchorLabel,
                copyLabel: l10n.pointDetailAreaAnchor,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        if (onMove != null) ...[
          const SizedBox(width: 8),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: onMove,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              child: Text(l10n.pointDetailChange),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, super.key});

  final VisitStatus status;

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      VisitStatus.current => l10n.pointDetailStatusCurrent,
      VisitStatus.completed => l10n.pointDetailStatusCompleted,
      VisitStatus.pending => l10n.pointDetailStatusPending,
    };

    final color = switch (status) {
      VisitStatus.current => AppColors.accent,
      VisitStatus.completed => AppColors.textSecondary,
      VisitStatus.pending => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 19),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CopyableText(
            text: value,
            copyLabel: label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PointRecordsPreview extends StatelessWidget {
  const _PointRecordsPreview({
    required this.records,
    required this.onOpenRecords,
    required this.onOpenRecord,
  });

  final List<PilgrimageVisitRecord> records;
  final VoidCallback? onOpenRecords;
  final ValueChanged<PilgrimageVisitRecord>? onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final recentRecords = records.take(6).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.folders, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 6),
            Text(
              l10n.pointDetailRecordsCount(records.length),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            const Spacer(),
            if (onOpenRecords != null)
              TextButton.icon(
                onPressed: onOpenRecords,
                icon: const Icon(LucideIcons.chevronRight, size: 18),
                label: Text(l10n.pointDetailAll),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final record = recentRecords[index];
              final photoPath = resolveVisitRecordDisplayPhotoPath(record);
              return SizedBox(
                width: 92,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onOpenRecord == null
                        ? null
                        : () => onOpenRecord!(record),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            key: const ValueKey('point-record-preview-photo'),
                            borderRadius: BorderRadius.zero,
                            child: VisitRecordPhoto(path: photoPath),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRecordTime(record.capturedAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemCount: recentRecords.length,
          ),
        ),
      ],
    );
  }

  String _formatRecordTime(DateTime capturedAt) {
    final month = capturedAt.month.toString().padLeft(2, '0');
    final day = capturedAt.day.toString().padLeft(2, '0');
    final hour = capturedAt.hour.toString().padLeft(2, '0');
    final minute = capturedAt.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }
}
