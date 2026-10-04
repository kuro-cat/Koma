import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../data/reference_asset_paths.dart';
import '../l10n/l10n.dart';
import '../widgets/app_back_button.dart';
import '../widgets/snackbar_helper.dart';
import 'plan_import_asset_restore.dart';
import 'plan_import_package.dart';

class PlanImportPreviewScreen extends StatefulWidget {
  const PlanImportPreviewScreen({
    required this.importPackage,
    required this.repository,
    super.key,
  });

  final PlanImportPackage importPackage;
  final PilgrimageRepository repository;

  @override
  State<PlanImportPreviewScreen> createState() =>
      _PlanImportPreviewScreenState();
}

class _PlanImportPreviewScreenState extends State<PlanImportPreviewScreen> {
  late var _includeRecords = widget.importPackage.hasVisitRecords;
  late var _includeAssets =
      widget.importPackage.hasRestorableAssets &&
      supportsPlanImportAssetRestore;
  var _importing = false;

  PlanImportPackage get _package => widget.importPackage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(l10n.planImportPreviewTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _PackageHeader(importPackage: _package),
          const SizedBox(height: 16),
          _StatsGrid(importPackage: _package),
          const SizedBox(height: 18),
          _SectionTitle(
            icon: LucideIcons.listChecks,
            title: l10n.planImportPreviewChooseContent,
            subtitle: l10n.planImportPreviewChooseContentSubtitle,
          ),
          const SizedBox(height: 10),
          _ImportOptionTile(
            icon: LucideIcons.route,
            title: l10n.planImportPreviewPlanStructure,
            subtitle: l10n.planImportPreviewPlanStructureSubtitle,
            value: true,
            enabled: false,
            onChanged: null,
          ),
          const SizedBox(height: 8),
          _ImportOptionTile(
            icon: LucideIcons.folders,
            title: l10n.planImportPreviewRecords,
            subtitle: _package.isLegacyJson
                ? l10n.planImportPreviewRecordsLegacy
                : _package.hasVisitRecords
                ? l10n.planImportPreviewRecordsCount(_package.visitRecordCount)
                : l10n.planImportPreviewRecordsNone,
            value: _includeRecords,
            enabled: !_importing && _package.hasVisitRecords,
            onChanged: (value) => setState(() => _includeRecords = value),
          ),
          const SizedBox(height: 8),
          _ImportOptionTile(
            icon: LucideIcons.images,
            title: l10n.planImportPreviewAssets,
            subtitle: _assetImportSubtitle,
            value: _includeAssets,
            enabled:
                !_importing &&
                _package.hasRestorableAssets &&
                supportsPlanImportAssetRestore,
            onChanged: (value) => setState(() => _includeAssets = value),
          ),
          if (_package.warnings.isNotEmpty) ...[
            const SizedBox(height: 18),
            _SectionTitle(
              icon: LucideIcons.triangleAlert,
              title: l10n.planImportPreviewPackageNotes,
              subtitle: l10n.planImportPreviewPackageNotesSubtitle,
            ),
            const SizedBox(height: 10),
            for (final warning in _package.warnings.take(6))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  warning,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: _importing ? null : _importSelected,
            icon: _importing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.download),
            label: Text(
              _importing
                  ? l10n.planImportPreviewImporting
                  : l10n.planImportPreviewImportSelected,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importSelected() async {
    setState(() => _importing = true);
    Map<String, String> restoredPaths = const {};
    var repositoryAttempted = false;
    var committed = false;
    try {
      restoredPaths = _includeAssets
          ? await restorePlanImportAssets(
              _package,
              includeRecords: _includeRecords,
            )
          : const <String, String>{};
      final restored = applyRestoredAssetPaths(
        importPackage: _package,
        restoredPaths: restoredPaths,
        includeRecords: _includeRecords,
      );
      repositoryAttempted = true;
      final importedPlan = await widget.repository.importPlanPackage(
        plan: restored.plan,
        visitRecords: restored.visitRecords,
      );
      committed = true;
      var finalizationFailed = false;
      if (restoredPaths is RestoredPlanImportAssets) {
        try {
          await restoredPaths.finalize();
        } catch (_) {
          finalizationFailed = true;
        }
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: restored.warnings.isEmpty && !finalizationFailed
            ? AppStatusBannerKind.success
            : AppStatusBannerKind.warning,
        title: finalizationFailed
            ? l10n.planImportPreviewImportedUnconfirmed(importedPlan.name)
            : restored.warnings.isEmpty
            ? l10n.planImportPreviewImported(importedPlan.name)
            : l10n.planImportPreviewImportedPartial(importedPlan.name),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      var cleanupIncomplete = false;
      if (!committed && restoredPaths.isNotEmpty) {
        try {
          if (restoredPaths is RestoredPlanImportAssets &&
              (!repositoryAttempted ||
                  (restoredPaths.canDiscardAfterRepositoryRead &&
                      await _assetsAreUnreferenced(restoredPaths)))) {
            await restoredPaths.discard();
          } else {
            cleanupIncomplete = true;
          }
        } catch (_) {
          cleanupIncomplete = true;
        }
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: cleanupIncomplete
            ? l10n.planImportPreviewCleanupIncomplete
            : l10n.planImportPreviewFailed,
      );
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  Future<bool> _assetsAreUnreferenced(Map<String, String> restoredPaths) async {
    final paths = restoredPaths.values
        .map(normalizeAssetPathSeparators)
        .toSet();
    bool referenced(String? path) =>
        path != null && paths.contains(normalizeAssetPathSeparators(path));
    // An import may commit and then fail while reading its result. Only remove
    // assets if a successful repository read proves they are not referenced.
    for (final plan in await widget.repository.loadPlans()) {
      for (final point in plan.points) {
        if (referenced(point.referenceThumbnailPath) ||
            referenced(point.referenceFullImagePath)) {
          return false;
        }
      }
      for (final record in await widget.repository.loadVisitRecords(plan.id)) {
        if (referenced(record.photoPath) ||
            referenced(record.originalPhotoPath) ||
            referenced(record.gradedPhotoPath) ||
            referenced(record.alignedPhotoPath) ||
            referenced(record.referenceImagePath)) {
          return false;
        }
      }
    }
    return true;
  }

  String get _assetImportSubtitle {
    if (!_package.hasAssets) {
      return l10n.planImportPreviewNoAssets;
    }
    if (!_package.hasRestorableAssets) {
      return l10n.planImportPreviewNoRestorableAssets;
    }
    if (!supportsPlanImportAssetRestore) {
      return l10n.planImportPreviewAssetsUnsupported(_package.totalAssetCount);
    }
    return l10n.planImportPreviewAssetsRestore(_package.totalAssetCount);
  }
}

class _PackageHeader extends StatelessWidget {
  const _PackageHeader({required this.importPackage});

  final PlanImportPackage importPackage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(LucideIcons.package, color: AppColors.accentDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  importPackage.package.plan.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${importPackage.versionLabel} / ${importPackage.sourceName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.importPackage});

  final PlanImportPackage importPackage;

  @override
  Widget build(BuildContext context) {
    final exportedAt = importPackage.exportedAt;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(
          label: l10n.planImportPreviewStatWorks,
          value: '${importPackage.workCount}',
        ),
        _StatChip(
          label: l10n.planImportPreviewStatAreas,
          value: '${importPackage.groupCount}',
        ),
        _StatChip(
          label: l10n.planImportPreviewStatSpots,
          value: '${importPackage.pointCount}',
        ),
        _StatChip(
          label: l10n.planImportPreviewStatRecords,
          value: '${importPackage.visitRecordCount}',
        ),
        _StatChip(
          label: l10n.planImportPreviewStatFiles,
          value: '${importPackage.totalAssetCount}',
        ),
        if (importPackage.appVersion != null)
          _StatChip(
            label: l10n.planImportPreviewStatVersion,
            value: importPackage.appVersion!,
          ),
        if (exportedAt != null)
          _StatChip(
            label: l10n.planImportPreviewStatExported,
            value:
                '${exportedAt.year}-${exportedAt.month.toString().padLeft(2, '0')}-${exportedAt.day.toString().padLeft(2, '0')}',
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0,
        ),
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
        Icon(icon, color: AppColors.accentDark, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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

class _ImportOptionTile extends StatelessWidget {
  const _ImportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled ? AppColors.accentDark : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
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
          Checkbox(
            value: value,
            onChanged: enabled
                ? (checked) {
                    if (checked != null) {
                      onChanged?.call(checked);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
