import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/foundation.dart';

import '../l10n/l10n.dart';
import '../app_theme.dart';
import '../data/anitabi_image_source_scope.dart';
import '../desktop/desktop_asset_image.dart';
import '../color_grading/color_grading_params.dart';
import '../align/align_photo_screen.dart';
import '../color_grading/color_grading_screen.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../plan/plan_group_utils.dart';
import '../plan/reference_image_status.dart';
import '../point_detail/point_detail_sheet.dart';
import '../settings/app_settings_updater.dart';
import '../widgets/copyable_text.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/app_back_button.dart';
import '../data/bounded_image_decoder.dart';
import '../widgets/bounded_image.dart';
import '../widgets/image_viewer_screen.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/reference_image_placeholder.dart';
import '../widgets/reference_image_source_stub.dart'
    if (dart.library.io) '../widgets/reference_image_source_io.dart';
import 'comparison_export_config.dart';
import 'comparison_export_sheet.dart';
import 'photo_compare_slider.dart';
import 'point_visit_records_screen.dart';
import 'visit_record_file_ops_stub.dart'
    if (dart.library.io) 'visit_record_file_ops_io.dart';
import 'visit_record_photo_stub.dart'
    if (dart.library.io) 'visit_record_photo_io.dart';

class VisitRecordDetailScreen extends StatefulWidget {
  const VisitRecordDetailScreen({
    required this.record,
    required this.point,
    required this.controller,
    required this.settings,
    required this.onDelete,
    super.key,
  });

  final PilgrimageVisitRecord record;
  final PilgrimagePoint? point;
  final PilgrimagePlanController controller;
  final AppSettings settings;
  final Future<void> Function() onDelete;

  @override
  State<VisitRecordDetailScreen> createState() =>
      _VisitRecordDetailScreenState();
}

class _VisitRecordDetailScreenState extends State<VisitRecordDetailScreen> {
  late PilgrimageVisitRecord _record = widget.record;
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final resolvedPoint = widget.point;
    final referenceImagePath = _resolvedReferenceImagePath(resolvedPoint);
    final referenceImageUrl = _resolvedReferenceImageUrl(resolvedPoint);
    final group = _groupFor(resolvedPoint);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: AppTheme.appBarHeight,
        leading: AppBackButton(
          key: const ValueKey('record-detail-back-button'),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.visitRecordDetailTitle),
        actions: [
          IconButton(
            tooltip: l10n.visitRecordDetailDeleteTooltip,
            onPressed: _deleting ? null : () => _confirmDelete(context),
            icon: const Icon(LucideIcons.trash2),
          ),
        ],
      ),
      body: ListView(
        key: const ValueKey('record-detail-scroll-view'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _RecordComparisonPanel(
            record: _record,
            referenceImagePath: referenceImagePath,
            referenceImageUrl: referenceImageUrl,
            settings: widget.settings,
            controller: widget.controller,
          ),
          const SizedBox(height: 16),
          if (resolvedPoint == null) ...[
            const _OrphanRecordNotice(),
            const SizedBox(height: 12),
          ],
          _RecordInfoDashboard(
            title: resolvedPoint?.name ?? _record.displayPointNameSnapshot,
            subtitle: resolvedPoint == null
                ? _recordSnapshotSubtitle(_record)
                : joinLabels([
                    resolvedPoint.work.title,
                    resolvedPoint.displaySubtitle,
                  ]),
            onHeaderTap: resolvedPoint == null
                ? null
                : () => _showPointDetail(resolvedPoint),
            children: [
              _DetailRow(
                icon: LucideIcons.calendarClock,
                label: l10n.visitRecordDetailCapturedAt,
                value: _formatDateTime(_record.capturedAt),
              ),
              if (resolvedPoint != null) ...[
                _DetailRow(
                  icon: LucideIcons.grid2X2,
                  label: l10n.visitRecordDetailArea,
                  value: _groupName(resolvedPoint, group),
                ),
                _DetailRow(
                  icon: LucideIcons.film,
                  label: l10n.visitRecordDetailScene,
                  value: resolvedPoint.displayEpisodeLabel,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _RecordActionPanel(
            onAlign: () => _openAlignment(context),
            onColorGrading: () => _openColorGrading(context),
            onExportComparison: () => _exportComparison(context, resolvedPoint),
          ),
        ],
      ),
    );
  }

  void _showPointDetail(PilgrimagePoint point) {
    PointDetailSheet.show(
      context,
      point: point,
      status: widget.controller.statusFor(point),
      onSetCurrent: () => widget.controller.setCurrentPoint(point),
      onOpenCamera: null,
      onComplete: () =>
          widget.controller.statusFor(point) == VisitStatus.completed
          ? widget.controller.reopenPoint(point)
          : widget.controller.completePoint(point),
      onReplaceReference: (point, image) => widget.controller.updatePoint(
        point.copyWith(
          referenceImageUrl: null,
          referenceThumbnailPath: image.thumbnailPath,
          referenceFullImagePath: image.fullImagePath,
        ),
      ),
      actionScope: PointDetailActionScope.manage,
      groups: widget.controller.plan.groups,
      groupBuckets: planGroupBuckets(
        widget.controller.plan,
        widget.controller.completedPointIds,
      ),
      onMoveToGroup: widget.controller.movePointToGroup,
      records: widget.controller.recordsForPoint(point.id),
      onOpenRecords: () => _openPointRecords(point),
      onOpenRecord: _openRelatedRecord,
      onDelete: widget.controller.deletePoint,
      navigationApp: widget.settings.navigationApp,
      settings: widget.settings,
    );
  }

  void _openPointRecords(PilgrimagePoint point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PointVisitRecordsScreen(
          point: point,
          controller: widget.controller,
          settings: widget.settings,
        ),
      ),
    );
  }

  void _openRelatedRecord(PilgrimageVisitRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitRecordDetailScreen(
          record: record,
          point: widget.controller.pointById(record.pointId),
          controller: widget.controller,
          settings: widget.settings,
          onDelete: () => widget.controller.deleteVisitRecord(record),
        ),
      ),
    );
  }

  Future<void> _openAlignment(BuildContext context) {
    final resolvedPoint = widget.point;
    return _openEditor(
      context,
      (_) => AlignPhotoScreen(
        record: _record,
        controller: widget.controller,
        fallbackReferenceImagePath: _resolvedReferenceImagePath(resolvedPoint),
        fallbackReferenceImageUrl: _resolvedReferenceImageUrl(resolvedPoint),
      ),
    );
  }

  Future<void> _openColorGrading(BuildContext context) {
    final resolvedPoint = widget.point;
    return _openEditor(
      context,
      (_) => ColorGradingScreen(
        record: _record,
        controller: widget.controller,
        fallbackReferenceImagePath: _resolvedReferenceImagePath(resolvedPoint),
        fallbackReferenceImageUrl: _resolvedReferenceImageUrl(resolvedPoint),
      ),
    );
  }

  /// Opens a photo editor that pops the updated record when it saves.
  Future<void> _openEditor(BuildContext context, WidgetBuilder builder) async {
    final updated = await Navigator.of(context).push<PilgrimageVisitRecord>(
      MaterialPageRoute<PilgrimageVisitRecord>(builder: builder),
    );
    if (updated == null || !mounted) {
      return;
    }
    setState(() => _record = updated);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (_deleting) return;
    var deleteFiles = false;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ConfirmActionDialog(
              title: l10n.visitRecordDetailDeleteTitle,
              message: l10n.visitRecordDetailDeleteMessage(
                l10n.visitRecordDetailDeleteTarget,
              ),
              confirmLabel: l10n.commonDelete,
              destructive: true,
              emphasizedValues: [l10n.visitRecordDetailDeleteTarget],
              additionalContent: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => deleteFiles = !deleteFiles),
                child: Row(
                  children: [
                    Checkbox(
                      value: deleteFiles,
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        return states.contains(WidgetState.selected)
                            ? ConfirmActionDialog.dangerColor
                            : Colors.transparent;
                      }),
                      side: BorderSide(color: AppColors.border, width: 1.5),
                      onChanged: (value) =>
                          setState(() => deleteFiles = value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.visitRecordDetailDeleteFiles,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (shouldDelete != true || !context.mounted) {
      return;
    }

    setState(() => _deleting = true);
    try {
      await widget.onDelete();
    } catch (_) {
      if (context.mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.visitRecordDetailDeleteFailed,
        );
      }
      return;
    }
    final repository = widget.controller.repository;
    if (deleteFiles && repository != null) {
      try {
        await deleteUnreferencedVisitRecordPhotos(
          record: _record,
          repository: repository,
        );
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showStatusSnack(
            kind: AppStatusBannerKind.warning,
            title: l10n.visitRecordDetailDeletedPartly,
          );
        }
      }
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _exportComparison(BuildContext context, PilgrimagePoint? resolvedPoint) {
    final capturedPath = resolveVisitRecordDisplayPhotoPath(_record);
    if (capturedPath == null) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.warning,
        title: l10n.visitRecordDetailPhotoUnavailable,
      );
      return;
    }

    final meta = <ComparisonMetadataField, String>{
      ComparisonMetadataField.capturedAt: _formatDateTime(_record.capturedAt),
    };

    if (resolvedPoint != null) {
      meta[ComparisonMetadataField.pointName] = resolvedPoint.name;
      meta[ComparisonMetadataField.workTitle] = resolvedPoint.work.title;
      meta[ComparisonMetadataField.episodeLabel] =
          resolvedPoint.displayEpisodeLabel;
      if (resolvedPoint.hasCoordinate) {
        meta[ComparisonMetadataField.coordinates] =
            '${resolvedPoint.position.latitude.toStringAsFixed(5)}, '
            '${resolvedPoint.position.longitude.toStringAsFixed(5)}';
      }
      if (resolvedPoint.sourceId != null) {
        meta[ComparisonMetadataField.anitabiId] = resolvedPoint.sourceId!;
      }
    } else {
      meta[ComparisonMetadataField.pointName] =
          _record.displayPointNameSnapshot;
      meta[ComparisonMetadataField.workTitle] =
          _record.displayWorkTitleSnapshot;
    }

    final repository = widget.controller.repository;
    if (repository == null) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.warning,
        title: l10n.visitRecordDetailNoPrefsStorage,
      );
      return;
    }

    ComparisonExportSheet.show(
      context,
      referenceImagePath: _resolvedReferenceImagePath(resolvedPoint),
      referenceImageUrl: _resolvedReferenceImageUrl(resolvedPoint),
      capturedPath: capturedPath,
      metadata: meta,
      colorGradingSummary: _colorGradingSummary(),
      repository: repository,
    );
  }

  String? _resolvedReferenceImagePath(PilgrimagePoint? resolvedPoint) {
    for (final path in [
      _record.referenceImagePath,
      resolvedPoint?.referenceFullImagePath,
    ].whereType<String>()) {
      if (visitRecordLocalFileExists(path) ||
          (kIsWeb && isDesktopAssetPath(path))) {
        return path;
      }
    }
    return null;
  }

  String? _resolvedReferenceImageUrl(PilgrimagePoint? resolvedPoint) {
    if (_record.referenceImageUrl != null) {
      return _record.referenceImageUrl;
    }
    if (resolvedPoint == null || !hasRemoteReferenceImage(resolvedPoint)) {
      return null;
    }
    return resolvedPoint.referenceImageUrl;
  }

  PilgrimagePlanGroup? _groupFor(PilgrimagePoint? point) {
    final groupId = point?.groupId;
    if (groupId == null) {
      return null;
    }
    return widget.controller.plan.groups
        .where((group) => group.id == groupId)
        .firstOrNull;
  }

  String _groupName(PilgrimagePoint point, PilgrimagePlanGroup? group) {
    if (point.groupId == null) {
      return l10n.visitRecordDetailUngrouped;
    }
    return group?.name ?? l10n.visitRecordDetailUnknownArea;
  }

  String? _colorGradingSummary() {
    final paramsJson = _record.colorGradingParamsJson;
    if (paramsJson == null || paramsJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(paramsJson);
      if (decoded is! Map) {
        return null;
      }
      final targetParams = ColorGradingParams.fromJson(
        Map<String, Object?>.from(decoded),
      );
      final intensity = (_record.colorGradingIntensity ?? 1).clamp(0.0, 1.0);
      final params = ColorGradingParams.lerp(
        ColorGradingParams.defaults,
        targetParams,
        intensity,
      );
      const threshold = 0.005;
      final defaults = ColorGradingParams.defaults;
      final parts = <String>[];

      String signed(double value) =>
          '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}';
      String plain(double value) => value.toStringAsFixed(2);
      bool changed(double value, double fallback) =>
          (value - fallback).abs() >= threshold;
      void addZeroBased(String label, double value, double fallback) {
        if (changed(value, fallback)) {
          parts.add('$label ${signed(value)}');
        }
      }

      addZeroBased(
        l10n.visitRecordDetailBrightness,
        params.brightness,
        defaults.brightness,
      );
      addZeroBased(
        l10n.visitRecordDetailExposure,
        params.exposure,
        defaults.exposure,
      );
      if (changed(params.contrast, defaults.contrast)) {
        parts.add(
          '${l10n.visitRecordDetailContrast} ${plain(params.contrast)}',
        );
      }
      if (changed(params.saturation, defaults.saturation)) {
        parts.add(
          '${l10n.visitRecordDetailSaturation} ${plain(params.saturation)}',
        );
      }
      addZeroBased(
        l10n.visitRecordDetailTemperature,
        params.temperature,
        defaults.temperature,
      );
      addZeroBased(l10n.visitRecordDetailTint, params.tint, defaults.tint);
      addZeroBased(
        l10n.visitRecordDetailHighlights,
        params.highlights,
        defaults.highlights,
      );
      addZeroBased(
        l10n.visitRecordDetailShadows,
        params.shadows,
        defaults.shadows,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveShadows('R'),
        params.redShadowCurve,
        defaults.redShadowCurve,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveMids('R'),
        params.redMidCurve,
        defaults.redMidCurve,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveHighlights('R'),
        params.redHighlightCurve,
        defaults.redHighlightCurve,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveShadows('G'),
        params.greenShadowCurve,
        defaults.greenShadowCurve,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveMids('G'),
        params.greenMidCurve,
        defaults.greenMidCurve,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveHighlights('G'),
        params.greenHighlightCurve,
        defaults.greenHighlightCurve,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveShadows('B'),
        params.blueShadowCurve,
        defaults.blueShadowCurve,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveMids('B'),
        params.blueMidCurve,
        defaults.blueMidCurve,
      );
      addZeroBased(
        l10n.visitRecordDetailCurveHighlights('B'),
        params.blueHighlightCurve,
        defaults.blueHighlightCurve,
      );

      if (parts.isEmpty) {
        return null;
      }
      return parts.join('  ');
    } catch (_) {
      return null;
    }
  }
}

class _RecordComparisonPanel extends StatefulWidget {
  const _RecordComparisonPanel({
    required this.record,
    required this.referenceImagePath,
    required this.referenceImageUrl,
    required this.settings,
    required this.controller,
  });

  final PilgrimageVisitRecord record;
  final String? referenceImagePath;
  final String? referenceImageUrl;
  final AppSettings settings;
  final PilgrimagePlanController controller;

  @override
  State<_RecordComparisonPanel> createState() => _RecordComparisonPanelState();
}

class _RecordComparisonPanelState extends State<_RecordComparisonPanel> {
  late RecordCompareMode _mode = AppSettingsUpdater.latest(
    widget.settings,
  ).recordCompareMode;

  bool get _hasReference =>
      referenceImageLocalPathCanDisplay(widget.referenceImagePath) ||
      widget.referenceImageUrl != null;

  /// Remembered for every record, like the map display switches.
  Future<void> _setMode(RecordCompareMode mode) async {
    final previous = _mode;
    setState(() => _mode = mode);
    final saved = await AppSettingsUpdater.update(
      widget.controller.repository,
      (current) => current.copyWith(recordCompareMode: mode),
    );
    if (!saved && mounted && _mode == mode) {
      setState(() => _mode = previous);
    }
  }

  void _openReference() => ImageViewerScreen.show(
    context,
    filePath: widget.referenceImagePath,
    imageUrl: widget.referenceImageUrl,
  );

  void _openPhoto() => ImageViewerScreen.show(
    context,
    filePath: resolveVisitRecordDisplayPhotoPath(widget.record),
  );

  @override
  Widget build(BuildContext context) {
    final photoPath = resolveVisitRecordDisplayPhotoPath(widget.record);
    // Without a reference there is nothing to slide against.
    final mode = _hasReference ? _mode : RecordCompareMode.stacked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasReference) ...[
          SegmentedButton<RecordCompareMode>(
            key: const ValueKey('record-compare-mode'),
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            segments: [
              ButtonSegment(
                value: RecordCompareMode.stacked,
                icon: const Icon(LucideIcons.rows2, size: 16),
                label: Text(l10n.visitRecordDetailModeStacked),
              ),
              ButtonSegment(
                value: RecordCompareMode.slider,
                icon: const Icon(LucideIcons.chevronsLeftRight, size: 16),
                label: Text(l10n.visitRecordDetailModeSlider),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => _setMode(selection.single),
          ),
          const SizedBox(height: 12),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: mode == RecordCompareMode.slider
              ? PhotoCompareSlider(
                  key: const ValueKey('record-compare-slider'),
                  reference: _RecordReferencePhoto(
                    path: widget.referenceImagePath,
                    url: widget.referenceImageUrl,
                    fit: BoxFit.cover,
                  ),
                  photo: VisitRecordPhoto(
                    path: photoPath,
                    fit: BoxFit.cover,
                    target: ImageDecodeTarget.panel,
                  ),
                  onTapReference: _openReference,
                  onTapPhoto: _openPhoto,
                )
              : Column(
                  key: const ValueKey('record-compare-stacked'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RecordImageTile(
                      label: l10n.visitRecordDetailReference,
                      onTap: _openReference,
                      child: _RecordReferencePhoto(
                        path: widget.referenceImagePath,
                        url: widget.referenceImageUrl,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RecordImageTile(
                      label: l10n.visitRecordDetailPhoto,
                      onTap: _openPhoto,
                      child: VisitRecordPhoto(
                        path: photoPath,
                        fit: BoxFit.contain,
                        target: ImageDecodeTarget.panel,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _RecordImageTile extends StatelessWidget {
  const _RecordImageTile({
    required this.label,
    required this.child,
    this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: child,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _RecordReferencePhoto extends StatelessWidget {
  const _RecordReferencePhoto({
    required this.path,
    required this.url,
    this.fit = BoxFit.contain,
  });

  final String? path;
  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final localPath = path;
    if (referenceImageLocalPathCanDisplay(localPath)) {
      return VisitRecordPhoto(
        path: localPath!,
        fit: fit,
        target: ImageDecodeTarget.panel,
      );
    }

    final imageUrl = url;
    if (imageUrl != null) {
      return BoundedImage(
        path: imageUrl,
        fit: fit,
        source: AnitabiImageSourceScope.of(context),
      );
    }

    return const _RecordReferencePlaceholder();
  }
}

class _RecordReferencePlaceholder extends StatelessWidget {
  const _RecordReferencePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ReferenceImagePlaceholder(
      state: ReferenceImagePlaceholderState.unavailable,
    );
  }
}

class _OrphanRecordNotice extends StatelessWidget {
  const _OrphanRecordNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.link2Off, color: AppColors.warning, size: 19),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.visitRecordDetailOrphan,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordInfoDashboard extends StatelessWidget {
  const _RecordInfoDashboard({
    required this.title,
    required this.subtitle,
    required this.children,
    this.onHeaderTap,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onHeaderTap != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      LucideIcons.chevronRight,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const _DashboardBorder(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (var index = 0; index < children.length; index += 1) ...[
                  if (index > 0) const _DashboardBorder(verticalMargin: 9),
                  children[index],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBorder extends StatelessWidget {
  const _DashboardBorder({this.verticalMargin = 0});

  final double verticalMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: verticalMargin),
      color: AppColors.border.withValues(alpha: 0.65),
    );
  }
}

class _RecordActionPanel extends StatelessWidget {
  const _RecordActionPanel({
    required this.onAlign,
    required this.onColorGrading,
    required this.onExportComparison,
  });

  final VoidCallback onAlign;
  final VoidCallback onColorGrading;
  final VoidCallback onExportComparison;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _RecordAction(
                    icon: LucideIcons.crop,
                    title: l10n.alignPhotoAction,
                    subtitle: l10n.alignPhotoActionSubtitle,
                    onTap: onAlign,
                  ),
                ),
                VerticalDivider(
                  width: 9,
                  indent: 8,
                  endIndent: 8,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _RecordAction(
                    icon: LucideIcons.wandSparkles,
                    title: l10n.visitRecordDetailColorMatchTitle,
                    subtitle: l10n.visitRecordDetailColorMatchSubtitle,
                    onTap: onColorGrading,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 9, indent: 8, endIndent: 8, color: AppColors.border),
          _RecordAction(
            icon: LucideIcons.share2,
            title: l10n.visitRecordDetailExportTitle,
            subtitle: l10n.visitRecordDetailExportSubtitle,
            onTap: onExportComparison,
          ),
        ],
      ),
    );
  }
}

class _RecordAction extends StatelessWidget {
  const _RecordAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
          width: 70,
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

String _formatDateTime(DateTime value) {
  final year = value.year.toString();
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

String _recordSnapshotSubtitle(PilgrimageVisitRecord record) {
  final workTitle = record.displayWorkTitleSnapshot;
  final pointSubtitle = record.displayPointSubtitleSnapshot;
  if (pointSubtitle.isEmpty) {
    return workTitle;
  }
  return '$workTitle / $pointSubtitle';
}
