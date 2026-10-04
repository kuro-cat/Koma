import 'dart:convert';

import '../data/local_asset_size_stub.dart'
    if (dart.library.io) '../data/local_asset_size_io.dart';
import '../l10n/l10n.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/reference_image_status.dart';
import 'plan_export_v2.dart';

class PlanExportSizeEstimate {
  const PlanExportSizeEstimate({
    required this.knownBytes,
    required this.missingFullReferenceCount,
    required this.missingThumbnailCount,
    required this.missingUserReferenceCount,
    required this.missingVisitPhotoCount,
    required this.missingGradedPhotoCount,
    required this.hasUnknownLocalAssets,
  });

  final int knownBytes;
  final int missingFullReferenceCount;
  final int missingThumbnailCount;
  final int missingUserReferenceCount;
  final int missingVisitPhotoCount;
  final int missingGradedPhotoCount;
  final bool hasUnknownLocalAssets;

  bool get hasMissingCriticalAssets =>
      missingUserReferenceCount > 0 ||
      missingVisitPhotoCount > 0 ||
      missingGradedPhotoCount > 0;

  /// The messages behind [hasMissingCriticalAssets].
  List<String> get criticalDetailMessages => [
    if (missingUserReferenceCount > 0)
      l10n.planExportSizeEstimatorUserReferencesMissing(
        missingUserReferenceCount,
      ),
    if (missingVisitPhotoCount > 0)
      l10n.planExportSizeEstimatorVisitPhotosMissing(missingVisitPhotoCount),
    if (missingGradedPhotoCount > 0)
      l10n.planExportSizeEstimatorGradedPhotosMissing(missingGradedPhotoCount),
  ];

  List<String> get detailMessages => [
    if (missingThumbnailCount > 0)
      l10n.planExportSizeEstimatorThumbnailsNotCached(missingThumbnailCount),
    if (missingFullReferenceCount > 0)
      l10n.planExportSizeEstimatorFullReferencesToDownload(
        missingFullReferenceCount,
      ),
    ...criticalDetailMessages,
    if (hasUnknownLocalAssets) l10n.planExportSizeEstimatorUnknownLocalAssets,
  ];

  String get label {
    final size = _formatBytes(knownBytes);
    final details = detailMessages;
    if (details.isNotEmpty) {
      return l10n.planExportSizeEstimatorLabelWithDetails(
        size,
        details.join(l10n.planExportSizeEstimatorDetailSeparator),
      );
    }
    return l10n.planExportSizeEstimatorLabel(size);
  }
}

Future<PlanExportSizeEstimate> estimatePlanExportV2Size({
  required PilgrimagePlan plan,
  required List<PilgrimageVisitRecord> visitRecords,
  required PlanExportV2Options options,
}) async {
  var knownBytes = 0;
  var missingFullReferenceCount = 0;
  var missingThumbnailCount = 0;
  var missingUserReferenceCount = 0;
  var missingVisitPhotoCount = 0;
  var missingGradedPhotoCount = 0;
  var hasUnknownLocalAssets = false;

  knownBytes += _utf8Length(_roughJsonForPlan(plan, options));
  if (options.includeRecords) {
    knownBytes += _utf8Length(_roughJsonForRecords(visitRecords));
  }
  knownBytes += _roughCsvSize(
    plan,
    visitRecords,
    includeRecords: options.includeRecords,
  );
  knownBytes += 4096;

  Future<bool> addLocalAsset(String? path, {bool markUnknown = true}) async {
    final size = await localAssetSize(path);
    if (size == null) {
      if (markUnknown && path != null && path.isNotEmpty) {
        hasUnknownLocalAssets = true;
      }
      return false;
    }
    knownBytes += size;
    return true;
  }

  for (final point in plan.points) {
    final isLocalUpload = isLocalUploadedReference(point);
    final thumbnailSize = await localAssetSize(point.referenceThumbnailPath);
    if (thumbnailSize == null) {
      if (isLocalUpload ||
          hasRemoteReferenceImage(point) ||
          _hasPath(point.referenceThumbnailPath)) {
        missingThumbnailCount += 1;
      }
    } else {
      knownBytes += thumbnailSize;
    }

    if (isLocalUpload) {
      final hasFullReference = await addLocalAsset(
        point.referenceFullImagePath,
        markUnknown: false,
      );
      if (!hasFullReference) {
        missingUserReferenceCount += 1;
      }
    } else if (options.includeFullReferenceCache) {
      final fullSize = await localAssetSize(point.referenceFullImagePath);
      if (fullSize == null) {
        if (hasRemoteReferenceImage(point)) {
          missingFullReferenceCount += 1;
        } else if (point.referenceFullImagePath != null) {
          hasUnknownLocalAssets = true;
        }
      } else {
        knownBytes += fullSize;
      }
    }
  }

  if (options.includeRecords) {
    for (final record in visitRecords) {
      if (!await addLocalAsset(record.photoPath, markUnknown: false)) {
        missingVisitPhotoCount += 1;
      }
      if (_hasPath(record.gradedPhotoPath) &&
          !await addLocalAsset(record.gradedPhotoPath, markUnknown: false)) {
        missingGradedPhotoCount += 1;
      }
      if (_hasPath(record.alignedPhotoPath) &&
          !await addLocalAsset(record.alignedPhotoPath, markUnknown: false)) {
        missingGradedPhotoCount += 1;
      }
    }
  }

  return PlanExportSizeEstimate(
    knownBytes: knownBytes,
    missingFullReferenceCount: missingFullReferenceCount,
    missingThumbnailCount: missingThumbnailCount,
    missingUserReferenceCount: missingUserReferenceCount,
    missingVisitPhotoCount: missingVisitPhotoCount,
    missingGradedPhotoCount: missingGradedPhotoCount,
    hasUnknownLocalAssets: hasUnknownLocalAssets,
  );
}

String _roughJsonForPlan(PilgrimagePlan plan, PlanExportV2Options options) {
  return jsonEncode({
    'plan': {
      'id': plan.id,
      'name': plan.name,
      'area': plan.area,
      'works': plan.works.length,
      'points': plan.points.length,
      'groups': plan.groups.length,
      'completedPointIds': plan.completedPointIds.length,
    },
    'mode': options.exportMode,
  });
}

String _roughJsonForRecords(List<PilgrimageVisitRecord> records) {
  return jsonEncode({
    'records': records
        .map(
          (record) => {
            'id': record.id,
            'pointId': record.pointId,
            'photoPath': record.photoPath,
            'capturedAt': record.capturedAt.toIso8601String(),
          },
        )
        .toList(growable: false),
  });
}

int _roughCsvSize(
  PilgrimagePlan plan,
  List<PilgrimageVisitRecord> records, {
  required bool includeRecords,
}) {
  final pointText = plan.points
      .map((point) => '${point.work.title},${point.name},${point.subtitle}')
      .join('\n');
  final recordText = includeRecords
      ? records.map((record) => '${record.id},${record.photoPath}').join('\n')
      : '';
  return _utf8Length('$pointText\n$recordText');
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  final kib = bytes / 1024;
  if (kib < 1024) {
    return '${kib.toStringAsFixed(kib < 10 ? 1 : 0)} KB';
  }
  final mib = kib / 1024;
  if (mib < 1024) {
    return '${mib.toStringAsFixed(mib < 10 ? 1 : 0)} MB';
  }
  final gib = mib / 1024;
  return '${gib.toStringAsFixed(gib < 10 ? 1 : 0)} GB';
}

int _utf8Length(String value) => utf8.encode(value).length;

bool _hasPath(String? path) => path != null && path.trim().isNotEmpty;
