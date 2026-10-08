import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/rules.dart';
import '../widgets/app_motion.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import '../data/anitabi_image_source_scope.dart';
import '../data/pilgrimage_repository.dart';
import '../widgets/snackbar_helper.dart';
import '../records/gallery_saver_stub.dart'
    if (dart.library.io) '../records/gallery_saver_io.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../records/visit_record_photo_stub.dart'
    if (dart.library.io) '../records/visit_record_photo_io.dart';
import '../widgets/image_viewer_screen.dart';
import '../data/bounded_image_decoder.dart';
import '../widgets/bounded_image.dart';
import '../widgets/reference_image_placeholder.dart';
import '../widgets/app_back_button.dart';
import '../widgets/reference_image_source_stub.dart'
    if (dart.library.io) '../widgets/reference_image_source_io.dart';
import 'auto_comparison_gallery_backup.dart';
import 'camerawesome_reference_screen.dart' show referenceModeDisplayLabel;
import 'photo_location.dart';
import 'photo_location_save_stub.dart'
    if (dart.library.io) 'photo_location_save_io.dart';
import 'photo_location_status_panel.dart';
import 'visit_record_save_assets.dart';
import '../map/current_location_resolver.dart';
import '../l10n/l10n.dart';

enum VisitRecordConfirmationResult { saved, completed }

class VisitRecordConfirmationScreen extends StatefulWidget {
  const VisitRecordConfirmationScreen({
    required this.point,
    required this.controller,
    required this.photoPath,
    required this.referenceMode,
    this.referenceBytes,
    this.referenceImagePath,
    this.referenceImageUrl,
    this.capturedAtOverride,
    this.settings = const AppSettings(),
    this.saveVisitPhotoToGallery = false,
    this.autoSaveComparisonToGallery = false,
    this.photoLocationStrategy = PhotoLocationStrategy.disabled,
    this.writePhotoLocation,
    this.resolvePhotoLocation,
    this.pendingPhotoLocation,
    this.prepareLocation = preparePhotoLocation,
    this.prepareReference = prepareReferenceImage,
    this.discardSourcePhoto,
    this.savePhotoToGallery = saveImageToGallery,
    this.backupComparison,
    this.retainPhotoPreview = retainPhotoPreviewUntilRead,
    super.key,
  });

  final PilgrimagePoint point;
  final PilgrimagePlanController? controller;
  final String photoPath;
  final String referenceMode;
  final Uint8List? referenceBytes;
  final String? referenceImagePath;
  final String? referenceImageUrl;
  final DateTime? capturedAtOverride;
  final AppSettings settings;
  final bool saveVisitPhotoToGallery;
  final bool autoSaveComparisonToGallery;
  final PhotoLocationStrategy photoLocationStrategy;
  final PhotoLocationWriter? writePhotoLocation;
  final Future<PhotoLocationData> Function()? resolvePhotoLocation;
  final PhotoLocationData? pendingPhotoLocation;
  final PhotoLocationPreparer prepareLocation;
  final ReferenceImagePreparer prepareReference;
  final Future<void> Function()? discardSourcePhoto;
  final Future<bool> Function(String) savePhotoToGallery;
  final Future<AutoComparisonGalleryResult> Function(PilgrimageVisitRecord)?
  backupComparison;
  final Future<void> Function(String, BuildContext) retainPhotoPreview;

  @override
  State<VisitRecordConfirmationScreen> createState() =>
      _VisitRecordConfirmationScreenState();
}

class _VisitRecordConfirmationScreenState
    extends State<VisitRecordConfirmationScreen> {
  bool _saving = false;
  String? _savingStage;
  bool _locating = false;
  String? _locationStatus;
  int _locationRequest = 0;
  PhotoLocationData? _pendingLocation;
  PreparedPhotoLocation? _preparedPhoto;
  PreparedRecordImage? _referenceDraft;
  PilgrimageVisitRecord? _savedRecord;
  bool _recordCommitUncertain = false;
  bool _sourceDiscarded = false;
  Future<bool>? _previewReadComplete;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.discardSourcePhoto != null) {
      _previewReadComplete ??=
          Future.sync(
            () => widget.retainPhotoPreview(widget.photoPath, context),
          ).then(
            (_) => true,
            onError: (Object error, StackTrace stack) {
              debugPrint('Could not confirm preview read completion: $error');
              return false;
            },
          );
    }
  }

  @override
  void dispose() {
    _locationRequest++;
    if (!_saving) unawaited(_cleanupDrafts(includeSource: true));
    super.dispose();
  }

  Future<void> _cleanupDrafts({required bool includeSource}) async {
    if (_recordCommitUncertain) return;
    Future<void> discard(Future<void> Function()? action) async {
      try {
        await action?.call();
      } catch (error) {
        debugPrint('Could not clean confirmation draft: $error');
      }
    }

    final record = _savedRecord;
    if (record == null) {
      final photo = _preparedPhoto;
      final reference = _referenceDraft;
      _preparedPhoto = null;
      _referenceDraft = null;
      await discard(photo?.discard);
      await discard(reference?.discard);
    }
    if (includeSource &&
        !_sourceDiscarded &&
        (record == null || record.photoPath != widget.photoPath)) {
      _sourceDiscarded = true;
      // Route pop completes before its reverse animation and before a pending
      // bounded provider read. Both the preview owner and its read must finish first.
      if (await _previewReadComplete == false) return;
      await discard(widget.discardSourcePhoto);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.photoLocationStrategy != PhotoLocationStrategy.disabled) {
      _pendingLocation = widget.pendingPhotoLocation;
      if (_pendingLocation != null) {
        _locationStatus = l10n.visitRecordConfirmationLocationReady;
      }
    }
    // "Use recent location" is resolved after capture too, so a stale fix
    // never delays the shutter; a fresh last-known fix returns immediately.
    final resolveOnOpen = switch (widget.photoLocationStrategy) {
      PhotoLocationStrategy.waitOnConfirmation => true,
      PhotoLocationStrategy.useRecentLocation => _pendingLocation == null,
      _ => false,
    };
    if (resolveOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolvePhotoLocation();
      });
    }
  }

  Future<PhotoLocationData> _locatePhoto() {
    final resolver = widget.resolvePhotoLocation;
    if (resolver != null) {
      return resolver();
    }
    return widget.photoLocationStrategy ==
            PhotoLocationStrategy.useRecentLocation
        ? resolveRecentPhotoLocation()
        : resolveFreshPhotoLocation();
  }

  Future<void> _resolvePhotoLocation() async {
    if (_locating || !mounted) {
      return;
    }
    final request = ++_locationRequest;
    setState(() {
      _locating = true;
      _locationStatus = l10n.visitRecordConfirmationLocating;
    });
    try {
      final location = await _locatePhoto();
      if (!mounted || request != _locationRequest) {
        return;
      }
      setState(() {
        _locating = false;
        _pendingLocation = location;
        _locationStatus = l10n.visitRecordConfirmationLocationReady;
      });
    } on CurrentLocationException catch (error) {
      if (!mounted || request != _locationRequest) {
        return;
      }
      setState(() {
        _locating = false;
        _locationStatus = currentLocationFailureMessage(error);
      });
    } catch (_) {
      if (!mounted || request != _locationRequest) {
        return;
      }
      setState(() {
        _locating = false;
        _locationStatus = l10n.visitRecordConfirmationLocationFailed;
      });
    }
  }

  Future<void> _save({required bool completePoint}) async {
    final controller = widget.controller;
    if (!mounted ||
        _saving ||
        _locating ||
        _recordCommitUncertain ||
        _savedRecord != null) {
      return;
    }
    if (controller?.repository == null) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.visitRecordConfirmationStorageUnavailable,
      );
      return;
    }

    setState(() {
      _saving = true;
      _savingStage = l10n.visitRecordConfirmationStageSaving;
    });

    try {
      await controller!.loadVisitRecords();
      if (!mounted) return;
      final existingIds = controller.visitRecords.map((r) => r.id).toSet();
      final referenceBytes = widget.referenceBytes;
      if (referenceBytes != null && _referenceDraft == null) {
        _referenceDraft = await widget.prepareReference(referenceBytes);
      }
      if (!mounted) return;
      final location = _pendingLocation;
      if (location != null && _preparedPhoto == null) {
        if (mounted) {
          setState(
            () =>
                _savingStage = l10n.visitRecordConfirmationStageWritingLocation,
          );
        }
        final writer = widget.writePhotoLocation;
        _preparedPhoto = writer == null
            ? PreparedPhotoLocation(path: widget.photoPath, written: false)
            : await widget.prepareLocation(
                sourcePath: widget.photoPath,
                location: location,
                writer: writer,
              );
      }
      if (!mounted) return;
      if (mounted) {
        setState(() => _savingStage = l10n.visitRecordConfirmationStageSaving);
      }
      final photoPath = _preparedPhoto?.path ?? widget.photoPath;
      final fallbackReferencePath =
          referenceImageLocalPathCanDisplay(widget.referenceImagePath)
          ? widget.referenceImagePath
          : null;
      if (_savedRecord == null) {
        // From this point a failing response may still mean a committed record.
        _recordCommitUncertain = true;
        try {
          _savedRecord = await controller.createVisitRecord(
            point: widget.point,
            photoPath: photoPath,
            referenceImagePath: _referenceDraft?.path ?? fallbackReferencePath,
            referenceImageUrl:
                _referenceDraft == null && fallbackReferencePath == null
                ? widget.referenceImageUrl
                : null,
            referenceMode: widget.referenceMode,
            capturedAt: widget.capturedAtOverride,
          );
        } on VisitRecordNotCommittedException {
          _recordCommitUncertain = false;
          rethrow;
        } catch (_) {
          // A positive read can recover a lost response. A negative/cached read
          // cannot prove that a remote commit did not happen.
          await controller.loadVisitRecords();
          final matches = controller.visitRecords
              .where(
                (record) =>
                    !existingIds.contains(record.id) &&
                    record.pointId == widget.point.id &&
                    record.photoPath == photoPath,
              )
              .toList();
          _savedRecord = matches.length == 1 ? matches.single : null;
          if (_savedRecord == null) rethrow;
        }
        if (_savedRecord == null) throw StateError('Record not confirmed');
        _recordCommitUncertain = false;
      }
      final record = _savedRecord!;
      var attemptedGalleryBackup = false;
      var galleryBackupSucceeded = false;
      if (widget.saveVisitPhotoToGallery) {
        if (mounted) {
          setState(
            () => _savingStage = l10n.visitRecordConfirmationStageBackingUp,
          );
        }
        attemptedGalleryBackup = true;
        try {
          galleryBackupSucceeded = await widget.savePhotoToGallery(
            record.photoPath,
          );
        } catch (_) {
          galleryBackupSucceeded = false;
        }
      }

      AutoComparisonGalleryResult? comparisonBackupResult;
      if (widget.autoSaveComparisonToGallery) {
        if (mounted) {
          setState(
            () => _savingStage = l10n.visitRecordConfirmationStageComparison,
          );
        }
        try {
          comparisonBackupResult = widget.backupComparison != null
              ? await widget.backupComparison!(record)
              : await autoSaveComparisonImageToGallery(
                  record: record,
                  point: widget.point,
                  settings: widget.settings,
                  loadCurrentSettings: controller.repository!.loadAppSettings,
                  pointReferenceFullImagePath: widget.referenceImagePath,
                  pointReferenceImageUrl: widget.referenceImageUrl,
                );
        } catch (_) {
          comparisonBackupResult = const AutoComparisonGalleryResult(
            AutoComparisonGalleryStatus.renderFailed,
          );
        }
      }

      String? nextPointName;
      var completed = false;
      var completionFailed = false;
      if (completePoint) {
        if (mounted) {
          setState(
            () => _savingStage = l10n.visitRecordConfirmationStageUpdatingSpot,
          );
        }
        try {
          await controller.completePointAndWait(widget.point);
          completed = true;
          nextPointName = controller.currentPoint?.name;
        } catch (_) {
          completionFailed = true;
        }
      }

      if (!mounted) {
        return;
      }
      var message = _saveSuccessMessage(
        completePoint: completed,
        nextPointName: nextPointName,
        attemptedGalleryBackup: attemptedGalleryBackup,
        galleryBackupSucceeded: galleryBackupSucceeded,
        comparisonBackupResult: comparisonBackupResult,
      );
      if (_preparedPhoto?.written == false) {
        message += l10n.visitRecordConfirmationLocationWriteFailed;
      }
      if (completionFailed) {
        message += l10n.visitRecordConfirmationCompleteFailed;
      }
      ScaffoldMessenger.of(
        context,
      ).showStatusSnack(kind: AppStatusBannerKind.success, title: message);
      setState(() => _saving = false);
      if (completed) {
        Navigator.of(context).pop(VisitRecordConfirmationResult.completed);
      } else {
        Navigator.of(context).pop(VisitRecordConfirmationResult.saved);
      }
    } catch (error) {
      debugPrint('Visit record save failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: _recordCommitUncertain
              ? l10n.visitRecordConfirmationSaveUncertain
              : l10n.visitRecordConfirmationSaveFailed,
        );
      }
    } finally {
      await _cleanupDrafts(includeSource: !mounted);
      if (mounted) {
        setState(() {
          _saving = false;
          _savingStage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _saving) {
          ScaffoldMessenger.of(context).showStatusSnack(
            kind: AppStatusBannerKind.running,
            title: l10n.visitRecordConfirmationSavingWait,
            icon: LucideIcons.save,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: appBackButtonIfCanPop(context),
          title: Text(l10n.visitRecordConfirmationTitle),
        ),
        body: ListView(
          // No gutter: the info panel's lines run edge to edge, everything
          // else carries the 12dp inset.
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          children: [
            for (final child in <Widget>[
              Text(
                widget.point.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.point.work.title} / ${widget.point.displayEpisodeLabel}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              AbsorbPointer(
                absorbing: _saving,
                child: _ComparisonPanel(
                  photoPath: widget.photoPath,
                  referenceBytes: widget.referenceBytes,
                  referenceImagePath: widget.referenceImagePath,
                  referenceImageUrl: widget.referenceImageUrl,
                ),
              ),
              const SizedBox(height: 16),
              _InfoPanel(referenceMode: widget.referenceMode),
              if (_locationStatus != null) ...[
                const SizedBox(height: 12),
                PhotoLocationStatusPanel(
                  label: _locationStatus!,
                  loading: _locating,
                  onSkip:
                      !_saving &&
                          !_recordCommitUncertain &&
                          (_locating || _pendingLocation != null)
                      ? () {
                          if (_saving || _recordCommitUncertain) return;
                          setState(() {
                            _locationRequest += 1;
                            _locating = false;
                            _pendingLocation = null;
                            _locationStatus =
                                l10n.visitRecordConfirmationLocationSkipped;
                          });
                        }
                      : null,
                ),
              ],
              AppReveal(
                visible: _savingStage != null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: AppContentFade(
                    revision: _savingStage,
                    child: _SavingProgressPanel(label: _savingStage ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saving || _locating || _recordCommitUncertain
                    ? null
                    : () => _save(completePoint: false),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.save, size: 18),
                label: Text(
                  _saving
                      ? l10n.visitRecordConfirmationSavingButton
                      : l10n.visitRecordConfirmationSave,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _saving || _locating || _recordCommitUncertain
                    ? null
                    : () => _save(completePoint: true),
                icon: const Icon(LucideIcons.circleCheckBig, size: 18),
                label: Text(l10n.visitRecordConfirmationSaveAndComplete),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving
                    ? null
                    : () {
                        if (!_saving) Navigator.of(context).pop();
                      },
                child: Text(l10n.commonCancel),
              ),
            ])
              child is _InfoPanel
                  ? child
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: child,
                    ),
          ],
        ),
      ),
    );
  }
}

bool shouldAutoSaveVisitPhotoToGallery(AppSettings settings) {
  if (!settings.saveVisitPhotoToGallery || kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

String _saveSuccessMessage({
  required bool completePoint,
  required String? nextPointName,
  required bool attemptedGalleryBackup,
  required bool galleryBackupSucceeded,
  required AutoComparisonGalleryResult? comparisonBackupResult,
}) {
  final base = completePoint
      ? l10n.visitRecordConfirmationSavedAndCompleted
      : l10n.visitRecordConfirmationSaved;
  final backupText = attemptedGalleryBackup
      ? (galleryBackupSucceeded
            ? l10n.visitRecordConfirmationBackedUp
            : l10n.visitRecordConfirmationBackupFailed)
      : '';
  final comparisonText = _comparisonBackupMessage(comparisonBackupResult);
  final nextText = completePoint && nextPointName != null
      ? l10n.visitRecordConfirmationNext(nextPointName)
      : '';
  return '$base$backupText$comparisonText$nextText';
}

String _comparisonBackupMessage(AutoComparisonGalleryResult? result) {
  if (result == null) {
    return '';
  }
  if (result.message != null) {
    return l10n.visitRecordConfirmationDetail(result.message!);
  }
  return switch (result.status) {
    AutoComparisonGalleryStatus.saved =>
      l10n.visitRecordConfirmationComparisonSaved,
    AutoComparisonGalleryStatus.referenceUnavailable =>
      l10n.visitRecordConfirmationComparisonNoReference,
    AutoComparisonGalleryStatus.capturedPhotoUnavailable =>
      l10n.visitRecordConfirmationComparisonNoPhoto,
    AutoComparisonGalleryStatus.galleryFailed =>
      l10n.visitRecordConfirmationComparisonGalleryFailed,
    AutoComparisonGalleryStatus.renderFailed =>
      l10n.visitRecordConfirmationComparisonRenderFailed,
  };
}

Future<void> _showGallerySaveSheet(
  BuildContext context,
  String photoPath,
) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(LucideIcons.download),
            title: Text(l10n.visitRecordConfirmationSaveToGallery),
            onTap: () => Navigator.of(context).pop('save'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );

  if (action != 'save' || !context.mounted) return;

  final result = await saveImageToGalleryWithResult(photoPath);
  if (!context.mounted) return;

  showGallerySaveResult(ScaffoldMessenger.of(context), result);
}

class _ComparisonPanel extends StatelessWidget {
  const _ComparisonPanel({
    required this.photoPath,
    required this.referenceBytes,
    required this.referenceImagePath,
    required this.referenceImageUrl,
  });

  final String photoPath;
  final Uint8List? referenceBytes;
  final String? referenceImagePath;
  final String? referenceImageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ImageCompareTile(
          label: l10n.visitRecordConfirmationReferenceImage,
          child: _ReferencePreview(
            bytes: referenceBytes,
            imagePath: referenceImagePath,
            imageUrl: referenceImageUrl,
          ),
          onTap: () => ImageViewerScreen.show(
            context,
            bytes: referenceBytes,
            filePath: referenceImagePath,
            imageUrl: referenceImageUrl,
          ),
        ),
        const SizedBox(height: 12),
        _ImageCompareTile(
          label: l10n.visitRecordConfirmationPilgrimagePhoto,
          child: VisitRecordPhoto(
            path: photoPath,
            fit: BoxFit.contain,
            target: ImageDecodeTarget.panel,
          ),
          onTap: () => ImageViewerScreen.show(context, filePath: photoPath),
          onLongPress: () => _showGallerySaveSheet(context, photoPath),
        ),
      ],
    );
  }
}

class _ImageCompareTile extends StatelessWidget {
  const _ImageCompareTile({
    required this.label,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
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

class _ReferencePreview extends StatelessWidget {
  const _ReferencePreview({
    required this.bytes,
    required this.imagePath,
    required this.imageUrl,
  });

  final Uint8List? bytes;
  final String? imagePath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final localBytes = bytes;
    if (localBytes != null) {
      return BoundedImage(bytes: localBytes);
    }

    final localPath = imagePath;
    if (referenceImageLocalPathCanDisplay(localPath)) {
      return BoundedImage(path: localPath);
    }

    final url = imageUrl;
    if (url != null) {
      return BoundedImage(
        path: url,
        source: AnitabiImageSourceScope.of(context),
      );
    }

    return const _ReferencePlaceholder();
  }
}

class _ReferencePlaceholder extends StatelessWidget {
  const _ReferencePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ReferenceImagePlaceholder(
      state: ReferenceImagePlaceholderState.unavailable,
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.referenceMode});

  final String referenceMode;

  @override
  Widget build(BuildContext context) {
    // A one-row section: 2px ink rule on top, a divider beneath, no frame.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: sectionRuleSide, bottom: rowDividerSide),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.layers, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            l10n.visitRecordConfirmationReferenceMode,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          Text(
            referenceModeDisplayLabel(referenceMode),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingProgressPanel extends StatelessWidget {
  const _SavingProgressPanel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
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
        ],
      ),
    );
  }
}
