import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import '../color_grading/color_adjustment.dart';
import '../color_grading/color_grading_params.dart';
import '../color_grading/graded_photo_reclamation.dart';
import '../color_grading/graded_photo_storage_stub.dart'
    if (dart.library.io) '../color_grading/graded_photo_storage_io.dart';
import '../data/bounded_image_decoder.dart';
import '../l10n/l10n.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../records/visit_record_photo_stub.dart'
    if (dart.library.io) '../records/visit_record_photo_io.dart';
import '../records/visit_record_reference_bytes.dart';
import '../widgets/app_back_button.dart';
import '../widgets/bounded_image.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/snackbar_helper.dart';
import 'photo_alignment.dart';

/// Lines a record's photo up under its reference frame and saves the
/// frame-shaped crop. The original photo is kept; saved color matching is
/// re-applied to the new crop.
class AlignPhotoScreen extends StatefulWidget {
  const AlignPhotoScreen({
    required this.record,
    required this.controller,
    this.fallbackReferenceImagePath,
    this.fallbackReferenceImageUrl,
    super.key,
  });

  final PilgrimageVisitRecord record;
  final PilgrimagePlanController controller;
  final String? fallbackReferenceImagePath;
  final String? fallbackReferenceImageUrl;

  @override
  State<AlignPhotoScreen> createState() => _AlignPhotoScreenState();
}

class _AlignPhotoScreenState extends State<AlignPhotoScreen> {
  static const _maxRotation = 15 * math.pi / 180;

  var _loading = true;
  var _saving = false;
  var _opacity = 0.5;
  var _difference = false;
  Object? _loadError;
  Uint8List? _photoBytes;
  ui.Image? _photo;
  ui.Image? _reference;
  PhotoAlignment? _alignment;
  PhotoAlignment? _gestureStart;
  Offset _gestureFocalStart = Offset.zero;

  PilgrimageVisitRecord get _record => widget.record;

  double get _photoAspect => _photo!.width / _photo!.height;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _photo?.dispose();
    _reference?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    ui.Image? photo;
    ui.Image? reference;
    try {
      final photoPath = resolveVisitRecordSourcePhotoPath(_record);
      if (photoPath == null) throw StateError(l10n.alignPhotoNoPhoto);
      final photoBytes = await readBoundedImageSource(photoPath);
      final referenceBytes = await loadVisitRecordReferenceBytes(
        _record,
        fallbackReferenceImagePath: widget.fallbackReferenceImagePath,
        fallbackReferenceImageUrl: widget.fallbackReferenceImageUrl,
      );
      if (referenceBytes == null) {
        throw StateError(l10n.alignPhotoNoReference);
      }
      photo = await decodeBoundedImage(
        photoBytes,
        target: ImageDecodeTarget.preview,
      );
      reference = await decodeBoundedImage(
        referenceBytes,
        target: ImageDecodeTarget.preview,
      );
      if (!mounted) {
        photo.dispose();
        reference.dispose();
        return;
      }
      final photoAspect = photo.width / photo.height;
      final frameAspect = reference.width / reference.height;
      setState(() {
        _photoBytes = photoBytes;
        _photo = photo;
        _reference = reference;
        _alignment =
            _savedAlignment(frameAspect)?.clamped(photoAspect: photoAspect) ??
            PhotoAlignment.cover(
              photoAspect: photoAspect,
              frameAspect: frameAspect,
            );
        _loading = false;
      });
    } catch (error) {
      photo?.dispose();
      reference?.dispose();
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  /// The record's saved alignment, if it was made against a frame of the
  /// same shape as the one loaded now.
  PhotoAlignment? _savedAlignment(double frameAspect) {
    final json = _record.alignmentJson;
    if (json == null || json.isEmpty) return null;
    try {
      final saved = PhotoAlignment.fromJson(
        Map<String, Object?>.from(jsonDecode(json) as Map),
      );
      return (saved.frameAspect - frameAspect).abs() < 0.01 ? saved : null;
    } catch (_) {
      return null;
    }
  }

  void _setAlignment(PhotoAlignment alignment) {
    setState(() => _alignment = alignment.clamped(photoAspect: _photoAspect));
  }

  void _onScaleStart(ScaleStartDetails details, double frameWidth) {
    _gestureStart = _alignment;
    _gestureFocalStart = details.localFocalPoint / frameWidth;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, double frameWidth) {
    final start = _gestureStart;
    if (start == null) return;
    // Keep the photo point that was under the fingers under the fingers.
    final focal = details.localFocalPoint / frameWidth;
    final scale = details.scale;
    _setAlignment(
      start.copyWith(
        scale: start.scale * scale,
        centerX: focal.dx + (start.centerX - _gestureFocalStart.dx) * scale,
        centerY: focal.dy + (start.centerY - _gestureFocalStart.dy) * scale,
      ),
    );
  }

  /// Rotates about the frame center so the framing doesn't drift.
  void _setRotation(double rotation) {
    final alignment = _alignment!;
    final delta = rotation - alignment.rotation;
    final pivotX = 0.5;
    final pivotY = alignment.frameHeight / 2;
    final dx = alignment.centerX - pivotX;
    final dy = alignment.centerY - pivotY;
    _setAlignment(
      alignment.copyWith(
        rotation: rotation,
        centerX: pivotX + math.cos(delta) * dx - math.sin(delta) * dy,
        centerY: pivotY + math.sin(delta) * dx + math.cos(delta) * dy,
      ),
    );
  }

  void _resetAlignment() {
    final alignment = _alignment!;
    setState(() {
      _alignment = PhotoAlignment.cover(
        photoAspect: _photoAspect,
        frameAspect: alignment.frameAspect,
      );
    });
  }

  Future<void> _save() => _commit(_saveUnchecked, l10n.alignPhotoSaved);

  Future<void> _confirmRemove() async {
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.alignPhotoRemoveTitle,
      message: l10n.alignPhotoRemoveMessage,
      confirmLabel: l10n.alignPhotoRemoveConfirm,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _commit(_removeUnchecked, l10n.alignPhotoRemoved);
  }

  Future<void> _commit(
    Future<PilgrimageVisitRecord?> Function() action,
    String successTitle,
  ) async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await action();
      if (!mounted) return;
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: successTitle,
      );
      Navigator.of(context).pop(updated);
    } catch (error) {
      if (!mounted) return;
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: error is ImageBudgetException
            ? error.message
            : l10n.alignPhotoSaveFailed,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<PilgrimageVisitRecord?> _saveUnchecked() async {
    final aligned = await renderAlignedJpeg(
      photoBytes: _photoBytes!,
      alignment: _alignment!,
    );
    final alignedPath = await saveGradedPhoto(
      bytes: aligned,
      recordId: _record.id,
      prefix: 'aligned',
    );
    if (alignedPath == null) throw StateError('Aligned photo was not saved');
    return _update(
      alignedPath: alignedPath,
      alignmentJson: jsonEncode(_alignment!.toJson()),
      gradedPath: await _regrade(aligned),
    );
  }

  Future<PilgrimageVisitRecord?> _removeUnchecked() async {
    return _update(
      alignedPath: null,
      alignmentJson: null,
      gradedPath: await _regrade(_photoBytes!),
    );
  }

  /// Stores the new crop (or none) and, if color matching was re-applied,
  /// the new graded photo; the files they replace are reclaimed.
  Future<PilgrimageVisitRecord?> _update({
    required String? alignedPath,
    required String? alignmentJson,
    required String? gradedPath,
  }) {
    return commitEditedPhotos(
      repository: widget.controller.repository,
      newPaths: [?alignedPath, ?gradedPath],
      previousPaths: [
        _record.alignedPhotoPath,
        if (gradedPath != null) _record.gradedPhotoPath,
      ],
      update: () => widget.controller.updateVisitRecordAlignment(
        record: _record,
        alignedPhotoPath: alignedPath,
        alignmentJson: alignmentJson,
        gradedPhotoPath: gradedPath ?? _record.gradedPhotoPath,
      ),
    );
  }

  /// Re-applies the record's saved color matching to [photo], since the
  /// graded photo was made from the old crop.
  Future<String?> _regrade(Uint8List photo) async {
    final paramsJson = _record.colorGradingParamsJson;
    if (!_record.hasColorGrading || paramsJson == null) return null;
    final params = ColorGradingParams.lerp(
      ColorGradingParams.defaults,
      ColorGradingParams.fromJson(
        Map<String, Object?>.from(jsonDecode(paramsJson) as Map),
      ),
      (_record.colorGradingIntensity ?? 1).clamp(0.0, 1.0),
    );
    final graded = await renderGradedJpeg(imageBytes: photo, params: params);
    return saveGradedPhoto(bytes: graded, recordId: _record.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(l10n.alignPhotoTitle),
        actions: [
          if (_alignment != null && _record.alignedPhotoPath != null)
            IconButton(
              tooltip: l10n.alignPhotoRemoveTitle,
              onPressed: _saving ? null : _confirmRemove,
              icon: const Icon(LucideIcons.trash2),
            ),
          if (_alignment != null)
            IconButton(
              tooltip: l10n.alignPhotoReset,
              onPressed: _saving ? null : _resetAlignment,
              icon: const Icon(LucideIcons.rotateCcw),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final alignment = _alignment;
    if (alignment == null) {
      return BoundedImageError(error: _loadError ?? StateError('No photo'));
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: alignment.frameAspect,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final frameWidth = constraints.maxWidth;
                    return GestureDetector(
                      onScaleStart: (details) =>
                          _onScaleStart(details, frameWidth),
                      onScaleUpdate: (details) =>
                          _onScaleUpdate(details, frameWidth),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _AlignmentPainter(
                          photo: _photo!,
                          reference: _reference!,
                          alignment: alignment,
                          opacity: _opacity,
                          difference: _difference,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.alignPhotoHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _LabeledSlider(
                  label: l10n.alignPhotoFrameOpacity,
                  valueLabel: '${(_opacity * 100).round()}%',
                  value: _opacity,
                  min: 0,
                  max: 1,
                  onChanged: (value) => setState(() => _opacity = value),
                ),
                _LabeledSlider(
                  label: l10n.alignPhotoRotation,
                  valueLabel:
                      '${(alignment.rotation * 180 / math.pi).toStringAsFixed(1)}°',
                  value: alignment.rotation.clamp(-_maxRotation, _maxRotation),
                  min: -_maxRotation,
                  max: _maxRotation,
                  onChanged: _setRotation,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.alignPhotoDifference),
                  subtitle: Text(l10n.alignPhotoDifferenceHint),
                  value: _difference,
                  onChanged: (value) => setState(() => _difference = value),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.crop, size: 18),
                  label: Text(
                    _saving ? l10n.alignPhotoSaving : l10n.alignPhotoSave,
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

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label)),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(
          width: 52,
          child: Text(valueLabel, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

class _AlignmentPainter extends CustomPainter {
  const _AlignmentPainter({
    required this.photo,
    required this.reference,
    required this.alignment,
    required this.opacity,
    required this.difference,
  });

  final ui.Image photo;
  final ui.Image reference;
  final PhotoAlignment alignment;
  final double opacity;
  final bool difference;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    paintAlignedPhoto(canvas, size, photo, alignment);
    if (opacity <= 0) return;
    canvas.drawImageRect(
      reference,
      Rect.fromLTWH(
        0,
        0,
        reference.width.toDouble(),
        reference.height.toDouble(),
      ),
      Offset.zero & size,
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, opacity)
        ..blendMode = difference ? BlendMode.difference : BlendMode.srcOver
        ..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_AlignmentPainter old) =>
      old.photo != photo ||
      old.reference != reference ||
      old.alignment != alignment ||
      old.opacity != opacity ||
      old.difference != difference;
}
