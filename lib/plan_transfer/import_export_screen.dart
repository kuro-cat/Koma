import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_selector/file_selector.dart' as file_selector;

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../l10n/l10n.dart';
import '../platform/platform_flags_stub.dart'
    if (dart.library.io) '../platform/platform_flags_io.dart';
import '../plan/pilgrimage_models.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/route_planner_skill_hint.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/app_back_button.dart';
import 'my_maps_csv_export.dart';
import 'plan_export_delivery.dart';
import 'plan_export_delivery_result.dart';
import 'plan_export_size_estimator.dart';
import 'plan_export_v2.dart';
import 'plan_import_file_stub.dart'
    if (dart.library.io) 'plan_import_file_io.dart';
import 'plan_import_package.dart';
import 'plan_import_preview_screen.dart';
import 'plan_link_import_screen.dart';
import 'plan_import_stream.dart';
import 'plan_package.dart' show seichiPlanFileExtension, seichiPlanMimeType;
import 'plan_transfer_background.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({
    required this.plan,
    required this.repository,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  var _mode = PlanExportV2Mode.planOnly;
  var _includeFullReferenceCache = false;
  var _exporting = false;
  var _importing = false;
  var _exportGeneration = 0;
  var _estimateGeneration = 0;
  PlanExportSizeEstimate? _sizeEstimate;
  var _estimatingSize = false;
  PlanTransferCancellation? _importCancellation;
  PlanTransferCancellation? _exportCancellation;

  bool get _usesExternalIosImport => isIosPlatform;

  @override
  void initState() {
    super.initState();
    _refreshSizeEstimate();
  }

  @override
  void dispose() {
    _exportGeneration++;
    _estimateGeneration++;
    _importCancellation?.cancel();
    _exportCancellation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_exporting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(onPressed: _handleBack),
          title: Text(l10n.importExportTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _PlanExportSummary(plan: widget.plan),
            const SizedBox(height: 16),
            _SectionTitle(
              icon: LucideIcons.import,
              title: l10n.importExportImportSection,
              subtitle: _usesExternalIosImport
                  ? l10n.importExportImportSubtitleIos
                  : l10n.importExportImportSubtitle,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: _importing
                  ? LucideIcons.hourglass
                  : _usesExternalIosImport
                  ? LucideIcons.externalLink
                  : LucideIcons.import,
              title: _importing
                  ? l10n.importExportReading
                  : _usesExternalIosImport
                  ? l10n.importExportOpenFromOtherApp
                  : l10n.importExportImportFile,
              subtitle: _usesExternalIosImport
                  ? l10n.importExportOpenFromOtherAppSubtitle
                  : l10n.importExportImportFileSubtitle,
              enabled: !_exporting && !_importing,
              onTap: _usesExternalIosImport
                  ? _showExternalIosImportHelp
                  : _importFromFile,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: LucideIcons.link,
              title: l10n.importExportImportFromLink,
              subtitle: l10n.importExportImportFromLinkSubtitle,
              enabled: !_exporting && !_importing,
              onTap: _importFromLink,
            ),
            const SizedBox(height: 10),
            RoutePlannerSkillCard(repository: widget.repository),
            const SizedBox(height: 20),
            _SectionTitle(
              icon: LucideIcons.package,
              title: l10n.importExportPackageSection,
              subtitle: l10n.importExportPackageSubtitle,
            ),
            const SizedBox(height: 10),
            _BackupOptions(
              mode: _mode,
              includeFullReferenceCache: _includeFullReferenceCache,
              sizeEstimate: _sizeEstimate,
              estimatingSize: _estimatingSize,
              exporting: _exporting || _importing,
              onModeChanged: (mode) {
                setState(() => _mode = mode);
                _refreshSizeEstimate();
              },
              onFullReferenceChanged: (value) {
                setState(() => _includeFullReferenceCache = value);
                _refreshSizeEstimate();
              },
              onExport: _exportV2,
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              icon: LucideIcons.map,
              title: 'Google My Maps',
              subtitle: l10n.importExportMyMapsSubtitle,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: _exporting ? LucideIcons.hourglass : LucideIcons.table2,
              title: l10n.importExportMyMapsExport,
              subtitle: l10n.importExportMyMapsExportSubtitle,
              enabled: !_exporting && !_importing,
              onTap: _exportMyMapsCsv,
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    final messenger = ScaffoldMessenger.of(context);
    if (_exporting) {
      _exportGeneration++;
      _exportCancellation?.cancel();
      setState(() => _exporting = false);
      messenger.showReplacingSnackBar(
        appStatusSnackBar(
          kind: AppStatusBannerKind.running,
          title: l10n.importExportExportCanceled,
          icon: LucideIcons.circleX,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _importFromFile() async {
    if (_usesExternalIosImport) {
      _showExternalIosImportHelp();
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final cancellation = PlanTransferCancellation();
    _importCancellation = cancellation;
    setState(() => _importing = true);
    try {
      final file = await file_selector.openFile(
        acceptedTypeGroups: const [
          file_selector.XTypeGroup(
            label: 'MiriaGo plan package',
            extensions: [seichiPlanFileExtension],
            mimeTypes: [
              miriagoExportPackageMimeType,
              'application/zip',
              'application/x-zip-compressed',
              seichiPlanMimeType,
              'application/octet-stream',
              'application/json',
              'text/json',
              'text/plain',
            ],
          ),
        ],
      );
      if (file == null) {
        return;
      }
      final PlanImportPackage importPackage;
      if (canReadPlanImportFromPath(file.path)) {
        // Native pickers hand over a local file: the worker isolate reads it
        // (with the same size limit) instead of receiving a copy of up to
        // 128 MiB from the UI isolate.
        importPackage = await readPlanImportPackageFromPath(
          file.path,
          sourceName: file.name,
          cancellation: cancellation,
        );
      } else {
        const limits = PlanImportLimits();
        final size = await file.length();
        if (size > limits.maxCompressedBytes) {
          throw PlanImportLimitException(
            l10n.planImportPackageResourceArchiveBytes,
            size,
            limits.maxCompressedBytes,
          );
        }
        final bytes = await readBoundedPlanImportStream(file.openRead());
        if (!mounted || cancellation.isCancelled) {
          return;
        }
        importPackage = await readPlanImportPackageInBackground(
          bytes,
          sourceName: file.name,
          cancellation: cancellation,
        );
      }
      if (!mounted) {
        return;
      }
      final imported = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => PlanImportPreviewScreen(
            importPackage: importPackage,
            repository: widget.repository,
          ),
        ),
      );
      if (imported == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } on PlanTransferCancelledException {
      return;
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: error is PlanImportLimitException
            ? error.message
            : l10n.importExportReadFailed,
      );
    } finally {
      if (identical(_importCancellation, cancellation)) {
        _importCancellation = null;
      }
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  Future<void> _importFromLink() async {
    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PlanLinkImportScreen(repository: widget.repository),
      ),
    );
    if (imported == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _showExternalIosImportHelp() async {
    await showInfoActionDialog(
      context,
      title: l10n.importExportOpenFromOtherApp,
      message: l10n.importExportIosHelpMessage,
    );
  }

  Future<void> _exportV2() async {
    await _runExport((generation) async {
      final exportedAt = DateTime.now();
      final options = PlanExportV2Options(
        mode: _mode,
        includeFullReferenceCache: _includeFullReferenceCache,
      );
      final records = await widget.repository.loadVisitRecords(widget.plan.id);
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final shouldContinue = await _confirmExportResourceRisks(
        records: records,
        options: options,
      );
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      if (!shouldContinue) {
        throw const PlanExportCanceledException();
      }
      final fileName = suggestPlanExportV2FileName(
        plan: widget.plan,
        exportedAt: exportedAt,
      );
      final destination = await preparePlanExportDestination(
        fileName: fileName,
        mimeType: miriagoExportPackageMimeType,
        extension: seichiPlanFileExtension,
      );
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final cancellation = PlanTransferCancellation();
      _exportCancellation?.cancel();
      _exportCancellation = cancellation;
      final PlanExportV2Result package;
      try {
        package = await buildPlanExportV2Package(
          plan: widget.plan,
          visitRecords: records,
          options: options,
          exportedAt: exportedAt,
          cancellation: cancellation,
        );
      } on PlanTransferCancelledException {
        throw const _ExportAbortedException();
      } finally {
        if (identical(_exportCancellation, cancellation)) {
          _exportCancellation = null;
        }
      }
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final result = await deliverPlanExport(
        bytes: package.bytes,
        fileName: package.fileName,
        mimeType: miriagoExportPackageMimeType,
        shareSubject: widget.plan.name,
        shareText: l10n.importExportShareText(widget.plan.name),
        extension: seichiPlanFileExtension,
        destination: destination,
      );
      return _PlanExportRunResult(
        result,
        package.warnings,
        package.warningCounts,
      );
    }, successMessage: l10n.importExportPackageExported);
  }

  Future<bool> _confirmExportResourceRisks({
    required List<PilgrimageVisitRecord> records,
    required PlanExportV2Options options,
  }) async {
    final estimate = await estimatePlanExportV2Size(
      plan: widget.plan,
      visitRecords: records,
      options: options,
    );
    if (mounted) {
      setState(() => _sizeEstimate = estimate);
    }
    if (!estimate.hasMissingCriticalAssets || !mounted) {
      return true;
    }

    final messages = estimate.criticalDetailMessages;
    final shouldExport = await showConfirmActionDialog(
      context,
      title: l10n.importExportMissingAssetsTitle,
      message: messages.join('\n'),
      confirmLabel: l10n.importExportContinueExport,
      notice: l10n.importExportMissingAssetsNotice,
    );
    return shouldExport;
  }

  Future<void> _refreshSizeEstimate() async {
    final generation = ++_estimateGeneration;
    setState(() {
      _estimatingSize = true;
    });
    try {
      final records = _mode == PlanExportV2Mode.planWithRecords
          ? await widget.repository.loadVisitRecords(widget.plan.id)
          : const <PilgrimageVisitRecord>[];
      final estimate = await estimatePlanExportV2Size(
        plan: widget.plan,
        visitRecords: records,
        options: PlanExportV2Options(
          mode: _mode,
          includeFullReferenceCache: _includeFullReferenceCache,
        ),
      );
      if (!mounted || generation != _estimateGeneration) {
        return;
      }
      setState(() {
        _sizeEstimate = estimate;
        _estimatingSize = false;
      });
    } catch (_) {
      if (!mounted || generation != _estimateGeneration) {
        return;
      }
      setState(() {
        _sizeEstimate = null;
        _estimatingSize = false;
      });
    }
  }

  Future<void> _exportMyMapsCsv() async {
    await _runExport((generation) async {
      final export = buildMyMapsCsvExport(plan: widget.plan);
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final destination = await preparePlanExportDestination(
        fileName: export.fileName,
        mimeType: export.mimeType,
        extension: myMapsCsvExtension,
      );
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final result = await deliverPlanExport(
        bytes: export.bytes,
        fileName: export.fileName,
        mimeType: export.mimeType,
        shareSubject: widget.plan.name,
        shareText: l10n.importExportMyMapsShareText(widget.plan.name),
        extension: myMapsCsvExtension,
        destination: destination,
      );
      return _PlanExportRunResult(
        result,
        export.skippedPointCount == 0
            ? const []
            : [l10n.importExportPendingCoordinateWarning],
        export.skippedPointCount == 0
            ? const {}
            : {'pendingCoordinate': export.skippedPointCount},
      );
    }, successMessage: l10n.importExportMyMapsExported);
  }

  Future<void> _runExport(
    Future<_PlanExportRunResult> Function(int generation) action, {
    required String successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final generation = ++_exportGeneration;
    setState(() => _exporting = true);
    messenger.showReplacingSnackBar(
      appStatusSnackBar(
        kind: AppStatusBannerKind.running,
        title: l10n.importExportExporting,
        icon: LucideIcons.share2,
      ),
    );
    try {
      final result = await action(generation);
      if (!_isCurrentExport(generation)) {
        return;
      }
      if (result.delivery.action == PlanExportDeliveryAction.canceled) {
        messenger.showReplacingSnackBar(
          appStatusSnackBar(
            kind: AppStatusBannerKind.running,
            title: l10n.importExportExportCanceled,
            icon: LucideIcons.circleX,
          ),
        );
        return;
      }
      messenger.showReplacingSnackBar(result.statusSnackBar(successMessage));
    } on PlanExportCanceledException {
      if (!_isCurrentExport(generation)) {
        return;
      }
      messenger.showReplacingSnackBar(
        appStatusSnackBar(
          kind: AppStatusBannerKind.running,
          title: l10n.importExportExportCanceled,
          icon: LucideIcons.circleX,
        ),
      );
    } on _ExportAbortedException {
      return;
    } catch (error, stackTrace) {
      debugPrint('Plan export failed: $error');
      debugPrint(stackTrace.toString());
      if (!_isCurrentExport(generation)) {
        return;
      }
      messenger.showReplacingSnackBar(
        appStatusSnackBar(
          kind: AppStatusBannerKind.error,
          title: l10n.importExportExportFailed,
          subtitle: l10n.importExportTryAgainLater,
        ),
      );
    } finally {
      if (_isCurrentExport(generation)) {
        setState(() => _exporting = false);
      }
    }
  }

  bool _isCurrentExport(int generation) {
    return mounted && generation == _exportGeneration;
  }
}

class _ExportAbortedException implements Exception {
  const _ExportAbortedException();
}

class _PlanExportRunResult {
  const _PlanExportRunResult(
    this.delivery, [
    this.warnings = const <String>[],
    this.warningCounts = const <String, int>{},
  ]);

  final PlanExportDeliveryResult delivery;
  final List<String> warnings;
  final Map<String, int> warningCounts;

  SnackBar statusSnackBar(String title) {
    if (warnings.isEmpty) {
      return appStatusSnackBar(
        kind: AppStatusBannerKind.success,
        title: title,
        subtitle: switch (delivery.action) {
          PlanExportDeliveryAction.saved => l10n.importExportSavedLocally,
          PlanExportDeliveryAction.shared => l10n.importExportShared,
          PlanExportDeliveryAction.canceled => null,
        },
      );
    }
    final summary = _warningSummary(warningCounts);
    return appStatusSnackBar(
      kind: AppStatusBannerKind.warning,
      title: title,
      subtitle: summary.isEmpty ? l10n.importExportSomeAssetsSkipped : summary,
    );
  }
}

String _warningSummary(Map<String, int> counts) {
  final parts = <String>[];

  void add(String key, String Function(int count) message) {
    final count = counts[key] ?? 0;
    if (count > 0) {
      parts.add(message(count));
    }
  }

  add(
    PlanExportWarningType.userReferenceMissing.key,
    l10n.importExportWarnUserReferenceMissing,
  );
  add(
    PlanExportWarningType.thumbnailMissing.key,
    l10n.importExportWarnThumbnailMissing,
  );
  add(
    PlanExportWarningType.fullReferenceDownloadFailed.key,
    l10n.importExportWarnFullReferenceDownloadFailed,
  );
  add(
    PlanExportWarningType.fullReferenceMissing.key,
    l10n.importExportWarnFullReferenceMissing,
  );
  add(
    PlanExportWarningType.visitPhotoMissing.key,
    l10n.importExportWarnVisitPhotoMissing,
  );
  add(
    PlanExportWarningType.gradedPhotoMissing.key,
    l10n.importExportWarnGradedPhotoMissing,
  );
  add('pendingCoordinate', l10n.importExportWarnPendingCoordinate);

  return parts.join(l10n.importExportWarningSeparator);
}

class _PlanExportSummary extends StatelessWidget {
  const _PlanExportSummary({required this.plan});

  final PilgrimagePlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(
              LucideIcons.archive,
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
                  '${l10n.importExportAreaCount(plan.groups.length)} / '
                  '${l10n.importExportSpotCount(plan.points.length)}',
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accentStrongForeground, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackupOptions extends StatelessWidget {
  const _BackupOptions({
    required this.mode,
    required this.includeFullReferenceCache,
    required this.sizeEstimate,
    required this.estimatingSize,
    required this.exporting,
    required this.onModeChanged,
    required this.onFullReferenceChanged,
    required this.onExport,
  });

  final PlanExportV2Mode mode;
  final bool includeFullReferenceCache;
  final PlanExportSizeEstimate? sizeEstimate;
  final bool estimatingSize;
  final bool exporting;
  final ValueChanged<PlanExportV2Mode> onModeChanged;
  final ValueChanged<bool> onFullReferenceChanged;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              return SegmentedButton<PlanExportV2Mode>(
                direction: constraints.maxWidth < 260 * textScale
                    ? Axis.vertical
                    : Axis.horizontal,
                segments: [
                  ButtonSegment(
                    value: PlanExportV2Mode.planOnly,
                    icon: const Icon(LucideIcons.route),
                    label: Text(l10n.importExportPlanOnly),
                  ),
                  ButtonSegment(
                    value: PlanExportV2Mode.planWithRecords,
                    icon: const Icon(LucideIcons.folders),
                    label: Text(l10n.importExportPlanWithRecords),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: exporting
                    ? null
                    : (values) => onModeChanged(values.first),
              );
            },
          ),
          const SizedBox(height: 10),
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              key: const ValueKey('export-include-reference-cache'),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) return null;
                return states.contains(WidgetState.selected)
                    ? AppColors.onAccent
                    : AppColors.accentForeground;
              }),
              trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) return null;
                return AppColors.accentForeground;
              }),
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.importExportIncludeFullReference,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              subtitle: Text(l10n.importExportIncludeFullReferenceSubtitle),
              value: includeFullReferenceCache,
              onChanged: exporting ? null : onFullReferenceChanged,
            ),
          ),
          const SizedBox(height: 2),
          _ExportSizeEstimateRow(
            estimate: sizeEstimate,
            estimating: estimatingSize,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: exporting ? null : onExport,
            icon: exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.share2, size: 18),
            label: Text(
              exporting
                  ? l10n.importExportExportingButton
                  : l10n.importExportExportPackage,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportSizeEstimateRow extends StatelessWidget {
  const _ExportSizeEstimateRow({
    required this.estimate,
    required this.estimating,
  });

  final PlanExportSizeEstimate? estimate;
  final bool estimating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (estimating)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(LucideIcons.package, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            estimating
                ? l10n.importExportEstimating
                : estimate?.label ?? l10n.importExportEstimateUnavailable,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.surface : AppColors.surfaceMuted,
      borderRadius: BorderRadius.zero,
      child: InkWell(
        borderRadius: BorderRadius.zero,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled
                    ? AppColors.accentStrongForeground
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: enabled ? AppColors.textSecondary : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
