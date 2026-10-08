import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/bounded_image_decoder.dart';
import '../widgets/rules.dart';
import '../widgets/bounded_image.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../records/visit_record_reference_bytes.dart';
import '../records/visit_record_photo_stub.dart'
    if (dart.library.io) '../records/visit_record_photo_io.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/app_back_button.dart';
import '../widgets/confirm_action_dialog.dart';
import 'color_adjustment.dart';
import 'color_grading_parameter_summary.dart';
import 'color_grading_params.dart';
import 'graded_photo_reclamation.dart';
import 'graded_photo_storage_stub.dart'
    if (dart.library.io) 'graded_photo_storage_io.dart';

class ColorGradingScreen extends StatefulWidget {
  const ColorGradingScreen({
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
  State<ColorGradingScreen> createState() => _ColorGradingScreenState();
}

class _ColorGradingScreenState extends State<ColorGradingScreen> {
  var _loading = true;
  var _matching = false;
  var _saving = false;
  var _showOriginal = false;
  var _intensity = 1.0;
  var _selectedMode = ColorMatchMode.standard;
  Uint8List? _capturedBytes;
  Uint8List? _referenceBytes;
  ColorGradingParams? _targetParams;
  int? _beforeScore;
  int? _afterScore;
  Object? _loadError;
  Object? _referenceError;
  var _resetPending = false;

  PilgrimageVisitRecord get _record => widget.record;

  ColorGradingParams get _activeParams {
    return ColorGradingParams.lerp(
      ColorGradingParams.defaults,
      _targetParams ?? ColorGradingParams.defaults,
      _intensity,
    );
  }

  int? get _currentToneScore {
    final before = _beforeScore;
    final after = _afterScore;
    if (before == null || after == null) {
      return null;
    }
    return (before + (after - before) * _intensity).round().clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _restoreSavedGrading();
    _loadImages();
  }

  void _restoreSavedGrading() {
    final savedMode = _record.colorGradingMode;
    if (savedMode != null) {
      _selectedMode = ColorMatchMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => ColorMatchMode.standard,
      );
    }

    _intensity = (_record.colorGradingIntensity ?? 1).clamp(0.0, 1.0);
    final paramsJson = _record.colorGradingParamsJson;
    if (paramsJson == null || paramsJson.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(paramsJson);
      if (decoded is Map<String, Object?>) {
        _targetParams = ColorGradingParams.fromJson(decoded);
      }
    } catch (_) {}
  }

  Future<void> _loadImages() async {
    try {
      final sourcePhotoPath = resolveVisitRecordGradingInputPath(_record);
      if (sourcePhotoPath == null) {
        throw StateError('Visit record photo is unavailable');
      }
      final capturedBytes = await readBoundedImageSource(sourcePhotoPath);
      await probeBoundedImage(capturedBytes);
      Uint8List? referenceBytes;
      Object? referenceError;
      try {
        referenceBytes = await _loadReferenceBytes();
        if (referenceBytes != null) await probeBoundedImage(referenceBytes);
      } catch (error) {
        // A missing reference disables matching, not edits to saved grading.
        referenceBytes = null;
        referenceError = error;
      }
      if (!mounted) {
        return;
      }

      setState(() {
        _capturedBytes = capturedBytes;
        _referenceBytes = referenceBytes;
        _referenceError = referenceError;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  Future<Uint8List?> _loadReferenceBytes() {
    return loadVisitRecordReferenceBytes(
      _record,
      fallbackReferenceImagePath: widget.fallbackReferenceImagePath,
      fallbackReferenceImageUrl: widget.fallbackReferenceImageUrl,
    );
  }

  Future<void> _runAutoMatch() async {
    if (!mounted || _matching || _saving) return;
    try {
      await _runAutoMatchUnchecked();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: error is ImageBudgetException
              ? error.message
              : l10n.colorGradingAutoMatchFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _matching = false);
    }
  }

  Future<void> _runAutoMatchUnchecked() async {
    final captured = _capturedBytes;
    final reference = _referenceBytes;
    final messenger = ScaffoldMessenger.of(context);
    if (captured == null) {
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.colorGradingPhotoReadFailed,
      );
      return;
    }
    if (reference == null) {
      final error = _referenceError;
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.warning,
        title: error is ImageBudgetException
            ? error.message
            : error == null
            ? l10n.colorGradingNoReferenceForMatch
            : l10n.colorGradingReferenceUnavailable,
      );
      return;
    }
    if (_matching) {
      return;
    }

    setState(() => _matching = true);
    final result = await autoMatchColorTone(
      capturedBytes: captured,
      referenceBytes: reference,
      mode: _selectedMode,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _matching = false;
      if (result != null) {
        _targetParams = result.targetParams;
        _selectedMode = result.mode;
        _beforeScore = result.beforeScore;
        _afterScore = result.afterScore;
        _intensity = 1.0;
        _resetPending = false;
      }
    });

    messenger.showStatusSnack(
      kind: result == null
          ? AppStatusBannerKind.error
          : AppStatusBannerKind.success,
      title: result == null
          ? l10n.colorGradingAutoMatchFailed
          : l10n.colorGradingAutoMatchDone,
    );
  }

  Future<void> _save() async {
    if (!mounted || _saving || _matching) return;
    try {
      await _saveUnchecked();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: error is ImageBudgetException
              ? error.message
              : l10n.colorGradingSaveFailedOriginalKept,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveUnchecked() async {
    final captured = _capturedBytes;
    final targetParams = _targetParams;
    final messenger = ScaffoldMessenger.of(context);
    if (captured == null || _saving) {
      return;
    }
    if (_resetPending) {
      setState(() => _saving = true);
      final updated = await clearGradedPhoto(
        repository: widget.controller.repository,
        previousGradedPath: _record.gradedPhotoPath,
        clear: () =>
            widget.controller.clearVisitRecordColorGrading(record: _record),
      );
      if (!mounted) {
        return;
      }

      setState(() => _saving = false);
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: l10n.colorGradingRestoredOriginal,
      );
      Navigator.of(context).pop(updated);
      return;
    }
    if (targetParams == null) {
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.warning,
        title: l10n.colorGradingMatchFirst,
      );
      return;
    }

    setState(() => _saving = true);
    final bytes = await renderGradedJpeg(
      imageBytes: captured,
      params: _activeParams,
    );
    final path = await saveGradedPhoto(bytes: bytes, recordId: _record.id);
    if (path == null) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.colorGradingSaveFailed,
      );
      return;
    }

    final updated = await commitGradedPhoto(
      repository: widget.controller.repository,
      newGradedPath: path,
      previousGradedPath: _record.gradedPhotoPath,
      update: () => widget.controller.updateVisitRecordColorGrading(
        record: _record,
        originalPhotoPath:
            resolveVisitRecordSourcePhotoPath(_record) ??
            _record.sourcePhotoPath,
        gradedPhotoPath: path,
        colorGradingMode: _selectedMode.name,
        colorGradingParamsJson: jsonEncode(targetParams.toJson()),
        colorGradingIntensity: _intensity,
      ),
    );
    if (!mounted) {
      return;
    }

    setState(() => _saving = false);
    messenger.showStatusSnack(
      kind: AppStatusBannerKind.success,
      title: l10n.colorGradingSaved,
    );
    Navigator.of(context).pop(updated);
  }

  void _reset() {
    setState(() {
      _targetParams = null;
      _beforeScore = null;
      _afterScore = null;
      _intensity = 1.0;
      _showOriginal = false;
      _resetPending = _record.hasColorGrading;
    });
  }

  Future<void> _confirmReset() async {
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.colorGradingResetTitle,
      message: l10n.colorGradingResetMessage,
      confirmLabel: l10n.colorGradingReset,
    );
    if (!confirmed || !mounted) {
      return;
    }
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(l10n.colorGradingTitle),
        actions: [
          IconButton(
            tooltip: l10n.colorGradingReset,
            onPressed: _confirmReset,
            icon: const Icon(LucideIcons.rotateCcw),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null || _capturedBytes == null) {
      return BoundedImageError(error: _loadError ?? StateError('照片读取失败'));
    }

    return ListView(
      // No gutter: section rules run edge to edge, content insets itself.
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _StackedPreview(
            referenceBytes: _referenceBytes,
            referenceError: _referenceError,
            capturedBytes: _capturedBytes!,
            activeParams: _activeParams,
            showOriginal: _showOriginal || _targetParams == null,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _OriginalHoldButton(
            enabled: _targetParams != null,
            showOriginal: _showOriginal,
            onChanged: (showOriginal) {
              setState(() => _showOriginal = showOriginal);
            },
          ),
        ),
        const SizedBox(height: 12),
        _ModeSelector(
          selectedMode: _selectedMode,
          hasSavedParams: _targetParams != null,
          onChanged: (mode) {
            setState(() {
              _selectedMode = mode;
              _targetParams = null;
              _beforeScore = null;
              _afterScore = null;
              _intensity = 1.0;
              _resetPending = false;
            });
          },
        ),
        if (_beforeScore != null && _afterScore != null) ...[
          const SizedBox(height: 12),
          _ScorePanel(
            beforeScore: _beforeScore!,
            currentToneScore: _currentToneScore ?? 0,
            afterScore: _afterScore!,
          ),
        ],
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FilledButton.icon(
            onPressed: _matching ? null : _runAutoMatch,
            icon: _matching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.wandSparkles, size: 18),
            label: Text(
              _matching
                  ? l10n.colorGradingMatching
                  : l10n.colorGradingAutoMatch,
            ),
          ),
        ),
        if (_targetParams != null) ...[
          const SizedBox(height: 12),
          ColorGradingParameterSummary(
            activeParams: _activeParams,
            intensity: _intensity,
            onIntensityChanged: (value) => setState(() => _intensity = value),
          ),
        ],
        if (_targetParams != null || _resetPending) ...[
          const SizedBox(height: 12),
          _SavePanel(saving: _saving, onSave: _save),
        ],
      ],
    );
  }
}

class _StackedPreview extends StatelessWidget {
  const _StackedPreview({
    required this.referenceBytes,
    required this.referenceError,
    required this.capturedBytes,
    required this.activeParams,
    required this.showOriginal,
  });

  final Uint8List? referenceBytes;
  final Object? referenceError;
  final Uint8List capturedBytes;
  final ColorGradingParams activeParams;
  final bool showOriginal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PreviewPane(
          label: l10n.colorGradingReference,
          child: referenceBytes == null
              ? referenceError == null
                    ? Center(child: Text(l10n.colorGradingNoReference))
                    : BoundedImageError(error: referenceError!)
              : BoundedImage(bytes: referenceBytes!),
        ),
        const SizedBox(height: 8),
        _PreviewPane(
          label: showOriginal
              ? l10n.colorGradingOriginal
              : l10n.colorGradingGraded,
          child: showOriginal
              ? BoundedImage(bytes: capturedBytes)
              : _GradedPhotoPreview(
                  capturedBytes: capturedBytes,
                  params: activeParams,
                ),
        ),
      ],
    );
  }
}

/// Shows the color-matrix preview immediately (exact for the linear
/// adjustments) and, when tone zones or RGB curves are active, swaps in a
/// debounced low-resolution render of the same path used when saving.
class _GradedPhotoPreview extends StatefulWidget {
  const _GradedPhotoPreview({
    required this.capturedBytes,
    required this.params,
  });

  final Uint8List capturedBytes;
  final ColorGradingParams params;

  @override
  State<_GradedPhotoPreview> createState() => _GradedPhotoPreviewState();
}

class _GradedPhotoPreviewState extends State<_GradedPhotoPreview> {
  static const _renderDelay = Duration(milliseconds: 250);

  Future<GradingPreviewSource>? _source;
  Timer? _debounce;
  ui.Image? _rendered;
  ColorGradingParams? _renderedParams;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    _scheduleRender();
  }

  @override
  void didUpdateWidget(covariant _GradedPhotoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.capturedBytes, widget.capturedBytes)) {
      _source = null;
      _clearRendered();
      _scheduleRender();
    } else if (oldWidget.params != widget.params) {
      _scheduleRender();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _generation += 1;
    _clearRendered();
    super.dispose();
  }

  void _clearRendered() {
    _rendered?.dispose();
    _rendered = null;
    _renderedParams = null;
  }

  void _scheduleRender() {
    _debounce?.cancel();
    _generation += 1;
    if (!widget.params.hasNonLinearAdjustments) {
      // The matrix is exact here; drop the stale render to free its memory.
      _clearRendered();
      return;
    }
    final params = widget.params;
    final generation = _generation;
    _debounce = Timer(_renderDelay, () => _render(params, generation));
  }

  Future<void> _render(ColorGradingParams params, int generation) async {
    ui.Image? image;
    try {
      final source = await (_source ??= prepareGradingPreviewSource(
        widget.capturedBytes,
      ));
      if (!mounted || generation != _generation) return;
      image = await renderGradedPreviewImage(source: source, params: params);
    } catch (error) {
      // Keep the matrix approximation if the low-resolution render fails.
      debugPrint('Color grading preview render failed: $error');
      return;
    }
    if (!mounted || generation != _generation) {
      image.dispose();
      return;
    }
    setState(() {
      _rendered?.dispose();
      _rendered = image;
      _renderedParams = params;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rendered = _rendered;
    if (rendered != null && _renderedParams == widget.params) {
      return RawImage(image: rendered, fit: BoxFit.contain);
    }
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(widget.params.toColorMatrix()),
      child: BoundedImage(bytes: widget.capturedBytes),
    );
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: ColoredBox(
          color: AppColors.surfaceMuted,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: child),
              Positioned(
                left: 8,
                top: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.cameraDarkSurface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
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

class _OriginalHoldButton extends StatelessWidget {
  const _OriginalHoldButton({
    required this.enabled,
    required this.showOriginal,
    required this.onChanged,
  });

  final bool enabled;
  final bool showOriginal;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled ? (_) => onChanged(true) : null,
      onPointerUp: enabled ? (_) => onChanged(false) : null,
      onPointerCancel: enabled ? (_) => onChanged(false) : null,
      child: OutlinedButton.icon(
        onPressed: enabled ? () {} : null,
        icon: Icon(showOriginal ? LucideIcons.eye : LucideIcons.eye),
        label: Text(
          showOriginal
              ? l10n.colorGradingShowingOriginal
              : l10n.colorGradingHoldForOriginal,
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.hasSavedParams,
    required this.onChanged,
  });

  final ColorMatchMode selectedMode;
  final bool hasSavedParams;
  final ValueChanged<ColorMatchMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(border: Border(top: sectionRuleSide)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.colorGradingMatchMode,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in ColorMatchMode.values)
                ChoiceChip(
                  label: Text(mode.label),
                  selected: selectedMode == mode,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(mode),
                  // Ground and edges come from the chip theme.
                  labelStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(LucideIcons.info, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasSavedParams
                      ? l10n.colorGradingParamsReady
                      : l10n.colorGradingMatchToSave,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({
    required this.beforeScore,
    required this.currentToneScore,
    required this.afterScore,
  });

  final int beforeScore;
  final int currentToneScore;
  final int afterScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(border: Border(top: sectionRuleSide)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.colorGradingToneMatch,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ScoreValue(label: l10n.colorGradingOriginal, score: beforeScore),
              Icon(
                LucideIcons.arrowRight,
                size: 18,
                color: AppColors.textSecondary,
              ),
              _ScoreValue(
                label: l10n.colorGradingCurrent,
                score: currentToneScore,
              ),
              Icon(
                LucideIcons.arrowRight,
                size: 18,
                color: AppColors.textSecondary,
              ),
              _ScoreValue(label: '100%', score: afterScore),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreValue extends StatelessWidget {
  const _ScoreValue({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$score',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavePanel extends StatelessWidget {
  const _SavePanel({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(border: Border(top: sectionRuleSide)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.colorGradingSaveResult,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.colorGradingSaveDescription,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.save, size: 18),
            label: Text(
              saving
                  ? l10n.colorGradingSaving
                  : l10n.colorGradingSaveColorMatch,
            ),
          ),
        ],
      ),
    );
  }
}
