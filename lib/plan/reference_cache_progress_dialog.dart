import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../widgets/app_status_banner.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/koma_mascot.dart';
import 'reference_full_cache_runner.dart';
import 'pilgrimage_models.dart';
import '../l10n/l10n.dart';

typedef ReferenceCacheRun =
    Future<void> Function(ValueChangedProgress onProgress);

/// Task state outlives its dismissible progress view.
class ReferenceCacheTask extends ChangeNotifier {
  static final _tasks = Expando<Map<String, ReferenceCacheTask>>();

  static ReferenceCacheTask forPlan(Object repository, String planId) {
    final tasks = _tasks[repository] ??= {};
    return tasks.putIfAbsent(planId, ReferenceCacheTask.new);
  }

  ReferenceFullCacheProgress? progress;
  PilgrimagePlan? updatedPlan;
  bool isRunning = false;
  bool hasError = false;

  /// Set by [cancel]; the run stops starting new downloads.
  bool cancelled = false;

  /// Share of the offline map saved while it downloads, after the images;
  /// null before that.
  double? mapProgress;

  /// Whether the offline map was saved; null when it wasn't attempted.
  bool? mapSaved;
  Future<void> _finished = Future.value();
  Future<void> get finished => _finished;

  Future<void> start(ReferenceCacheRun run) {
    if (isRunning) return _finished;
    final done = Completer<void>();
    _finished = done.future;
    isRunning = true;
    hasError = false;
    cancelled = false;
    mapProgress = null;
    mapSaved = null;
    updatedPlan = null;
    progress = ReferenceFullCacheProgress(total: progress?.total ?? 0);
    notifyListeners();
    unawaited(_execute(run, done));
    return _finished;
  }

  ReferenceCacheStatus get status {
    final progress = this.progress;
    if (isRunning || progress == null) return ReferenceCacheStatus.running;
    if (hasError) return ReferenceCacheStatus.failed;
    if (cancelled) return ReferenceCacheStatus.cancelled;
    if (progress.failed == 0) return ReferenceCacheStatus.success;
    if (progress.succeeded == 0) return ReferenceCacheStatus.failed;
    return ReferenceCacheStatus.partial;
  }

  void reportMapProgress(double done) {
    mapProgress = done;
    _notification.updateMap(done);
    notifyListeners();
  }

  /// Heading for the finished run.
  String get title =>
      mapSaved == true &&
          (status == ReferenceCacheStatus.success ||
              status == ReferenceCacheStatus.partial)
      ? l10n.offlineSavedTitle
      : _titleFor(status);

  /// What the finished run did, for the dialog and the notification.
  String get summary {
    final progress = this.progress;
    if (hasError || progress == null) {
      return l10n.referenceCacheProgressInterrupted;
    }
    return [
      if (progress.total > 0)
        _subtitleFor(
          status: status,
          total: progress.total,
          succeeded: progress.succeeded,
          failed: progress.failed,
        ),
      if (mapSaved case final saved?)
        saved ? l10n.offlineMapSaved : l10n.offlineMapNotSaved,
    ].join('\n');
  }

  void cancel() {
    if (!isRunning || cancelled) return;
    cancelled = true;
    notifyListeners();
  }

  Future<void> _execute(ReferenceCacheRun run, Completer<void> done) async {
    _notification.start(this);
    try {
      await run((value) {
        progress = value;
        _notification.update(value);
        notifyListeners();
      });
    } catch (_) {
      hasError = true;
    } finally {
      isRunning = false;
      _notification.finish(this);
      notifyListeners();
      done.complete();
    }
  }

  final _notification = _CacheNotification();
}

/// The Android foreground service that keeps caching alive with the screen
/// locked, and its progress and result notifications.
class _CacheNotification {
  static const _channel = MethodChannel('seichi/reference_cache_service');

  /// Tasks the notification's Cancel button stops.
  static final _running = <ReferenceCacheTask>{};
  static var _handlerSet = false;

  int? _lastPercent;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void start(ReferenceCacheTask task) {
    _lastPercent = null;
    if (!_supported) return;
    _running.add(task);
    if (!_handlerSet) {
      _handlerSet = true;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'cancel') {
          for (final task in _running.toList()) {
            task.cancel();
          }
        }
      });
    }
    _send('start', {
      'channelName': l10n.planCacheReferences,
      'title': l10n.referenceCacheProgressRunning,
      'cancelLabel': l10n.commonCancel,
    });
  }

  void update(ReferenceFullCacheProgress progress) {
    // Android drops rapid notification updates, so send one per percent.
    final percent = progress.total == 0
        ? 0
        : progress.processed * 100 ~/ progress.total;
    if (percent == _lastPercent) return;
    _lastPercent = percent;
    _send('update', {'processed': progress.processed, 'total': progress.total});
  }

  void updateMap(double done) {
    final percent = (done * 100).round();
    // Image percents run 0 to 100 first; map percents are kept apart.
    if (percent + 1000 == _lastPercent) return;
    _lastPercent = percent + 1000;
    _send('update', {
      'processed': percent,
      'total': 100,
      'title': l10n.offlineMapSaving,
    });
  }

  void finish(ReferenceCacheTask task) {
    _running.remove(task);
    _send('finish', {'title': task.title, 'text': task.summary});
  }

  void _send(String method, Map<String, Object?> arguments) {
    if (!_supported) return;
    // Best effort: caching never depends on its notification.
    unawaited(
      _channel.invokeMethod<void>(method, arguments).catchError((Object _) {}),
    );
  }
}

Future<void> showReferenceCacheProgressDialog({
  required BuildContext context,
  required ReferenceCacheRun run,
  ReferenceCacheTask? task,
  bool startOnOpen = true,
}) async {
  final activeTask = task ?? ReferenceCacheTask();
  // Stays up while caching runs; "Run in background" is the only way out.
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ReferenceCacheProgressDialog(
      run: run,
      task: activeTask,
      startOnOpen: startOnOpen,
    ),
  );
  await activeTask.finished;
}

class ReferenceCacheProgressDialog extends StatefulWidget {
  const ReferenceCacheProgressDialog({
    required this.run,
    this.task,
    this.startOnOpen = true,
    super.key,
  });

  final ReferenceCacheRun run;
  final ReferenceCacheTask? task;
  final bool startOnOpen;

  @override
  State<ReferenceCacheProgressDialog> createState() =>
      _ReferenceCacheProgressDialogState();
}

enum ReferenceCacheStatus { running, success, partial, failed, cancelled }

class _ReferenceCacheProgressDialogState
    extends State<ReferenceCacheProgressDialog> {
  late final _task = widget.task ?? ReferenceCacheTask();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.startOnOpen && !_task.isRunning) {
        _task.start(widget.run);
      }
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _task,
    builder: (context, _) {
      final progress = _task.progress;
      final status = _task.status;
      return _CacheProgressCard(
        status: status,
        mapProgress: _task.mapProgress,
        title: _task.title,
        summary: _task.summary,
        total: progress?.total ?? 0,
        processed: progress?.processed ?? 0,
        succeeded: progress?.succeeded ?? 0,
        failed: progress?.failed ?? 0,
        interrupted: _task.hasError,
        onClose: () => Navigator.of(context).pop(),
        onRetry:
            status == ReferenceCacheStatus.partial ||
                status == ReferenceCacheStatus.failed
            ? () => _task.start(widget.run)
            : null,
      );
    },
  );
}

class _CacheProgressCard extends StatelessWidget {
  const _CacheProgressCard({
    required this.status,
    required this.mapProgress,
    required this.title,
    required this.summary,
    required this.total,
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.onClose,
    this.onRetry,
    this.interrupted = false,
  });

  final ReferenceCacheStatus status;
  final int total;
  final int processed;
  final int succeeded;
  final int failed;
  final VoidCallback onClose;
  final VoidCallback? onRetry;
  final bool interrupted;
  final double? mapProgress;
  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final running = status == ReferenceCacheStatus.running;
    final mapProgress = this.mapProgress;
    final fraction = mapProgress != null
        ? mapProgress.clamp(0.0, 1.0)
        : total == 0
        ? 0.0
        : (processed / total).clamp(0.0, 1.0);
    final secondaryStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 13,
      height: 1.35,
      letterSpacing: 0,
    );
    final retryLabel = switch (status) {
      ReferenceCacheStatus.failed => l10n.referenceCacheProgressRetryAll,
      ReferenceCacheStatus.partial => l10n.referenceCacheProgressRetryFailed,
      _ => null,
    };

    return Dialog(
      key: const ValueKey('reference-cache-progress-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: KomaMascot(
                  height: 150,
                  still: !running,
                  ground: AppColors.surface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                running && mapProgress != null ? l10n.offlineMapSaving : title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: status == ReferenceCacheStatus.failed
                      ? AppColors.error
                      : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              if (running) ...[
                AppStatusBannerProgressLine(
                  countLabel: mapProgress != null
                      ? l10n.offlineMapLabel
                      : '$processed / $total',
                  percentLabel: '${(fraction * 100).round()}%',
                  value: fraction,
                  barKey: const ValueKey('reference-cache-progress-bar'),
                ),
                const SizedBox(height: 12),
                Text(l10n.referenceCacheProgressTip, style: secondaryStyle),
              ] else
                Text(
                  summary,
                  textAlign: TextAlign.center,
                  style: secondaryStyle,
                ),
              const SizedBox(height: 18),
              if (retryLabel != null)
                AppDialogActionRow(
                  cancelLabel: l10n.commonClose,
                  confirmLabel: retryLabel,
                  onCancel: onClose,
                  onConfirm: onRetry!,
                )
              else
                OutlinedButton(
                  key: ValueKey(
                    running
                        ? 'reference-cache-background'
                        : 'reference-cache-close',
                  ),
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    running
                        ? l10n.referenceCacheProgressBackground
                        : l10n.commonClose,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _titleFor(ReferenceCacheStatus status) {
  return switch (status) {
    ReferenceCacheStatus.running => l10n.referenceCacheProgressRunning,
    ReferenceCacheStatus.success => l10n.referenceCacheProgressDone,
    ReferenceCacheStatus.partial => l10n.referenceCacheProgressDone,
    ReferenceCacheStatus.failed => l10n.referenceCacheProgressFailedTitle,
    ReferenceCacheStatus.cancelled => l10n.referenceCacheProgressCancelledTitle,
  };
}

String _subtitleFor({
  required ReferenceCacheStatus status,
  required int total,
  required int succeeded,
  required int failed,
}) {
  return switch (status) {
    ReferenceCacheStatus.running => '$succeeded / $total',
    ReferenceCacheStatus.success => l10n.referenceCacheProgressSuccessSummary(
      succeeded,
      total,
    ),
    ReferenceCacheStatus.partial || ReferenceCacheStatus.failed =>
      l10n.referenceCacheProgressPartialSummary(succeeded, total, failed),
    ReferenceCacheStatus.cancelled =>
      l10n.referenceCacheProgressCancelledSummary(succeeded, total),
  };
}
