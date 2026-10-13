import 'dart:async';

import 'package:flutter/material.dart';

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
  Future<void> _finished = Future.value();
  Future<void> get finished => _finished;

  Future<void> start(ReferenceCacheRun run) {
    if (isRunning) return _finished;
    final done = Completer<void>();
    _finished = done.future;
    isRunning = true;
    hasError = false;
    updatedPlan = null;
    progress = ReferenceFullCacheProgress(total: progress?.total ?? 0);
    notifyListeners();
    unawaited(_execute(run, done));
    return _finished;
  }

  Future<void> _execute(ReferenceCacheRun run, Completer<void> done) async {
    try {
      await run((value) {
        progress = value;
        notifyListeners();
      });
    } catch (_) {
      hasError = true;
    } finally {
      isRunning = false;
      notifyListeners();
      done.complete();
    }
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

enum _CacheDialogStatus { running, success, partial, failed }

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
      final status = _task.isRunning || progress == null
          ? _CacheDialogStatus.running
          : _task.hasError
          ? _CacheDialogStatus.failed
          : progress.failed == 0
          ? _CacheDialogStatus.success
          : progress.succeeded == 0
          ? _CacheDialogStatus.failed
          : _CacheDialogStatus.partial;
      return _CacheProgressCard(
        status: status,
        total: progress?.total ?? 0,
        processed: progress?.processed ?? 0,
        succeeded: progress?.succeeded ?? 0,
        failed: progress?.failed ?? 0,
        interrupted: _task.hasError,
        onClose: () => Navigator.of(context).pop(),
        onRetry:
            status == _CacheDialogStatus.partial ||
                status == _CacheDialogStatus.failed
            ? () => _task.start(widget.run)
            : null,
      );
    },
  );
}

class _CacheProgressCard extends StatelessWidget {
  const _CacheProgressCard({
    required this.status,
    required this.total,
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.onClose,
    this.onRetry,
    this.interrupted = false,
  });

  final _CacheDialogStatus status;
  final int total;
  final int processed;
  final int succeeded;
  final int failed;
  final VoidCallback onClose;
  final VoidCallback? onRetry;
  final bool interrupted;

  @override
  Widget build(BuildContext context) {
    final running = status == _CacheDialogStatus.running;
    final fraction = total == 0 ? 0.0 : (processed / total).clamp(0.0, 1.0);
    final secondaryStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 13,
      height: 1.35,
      letterSpacing: 0,
    );
    final retryLabel = switch (status) {
      _CacheDialogStatus.failed => l10n.referenceCacheProgressRetryAll,
      _CacheDialogStatus.partial => l10n.referenceCacheProgressRetryFailed,
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
                _titleFor(status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: status == _CacheDialogStatus.failed
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
                  countLabel: '$processed / $total',
                  percentLabel: '${(fraction * 100).round()}%',
                  value: fraction,
                  barKey: const ValueKey('reference-cache-progress-bar'),
                ),
                const SizedBox(height: 12),
                Text(l10n.referenceCacheProgressTip, style: secondaryStyle),
              ] else
                Text(
                  interrupted
                      ? l10n.referenceCacheProgressInterrupted
                      : _subtitleFor(
                          status: status,
                          total: total,
                          succeeded: succeeded,
                          failed: failed,
                        ),
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

String _titleFor(_CacheDialogStatus status) {
  return switch (status) {
    _CacheDialogStatus.running => l10n.referenceCacheProgressRunning,
    _CacheDialogStatus.success => l10n.referenceCacheProgressDone,
    _CacheDialogStatus.partial => l10n.referenceCacheProgressDone,
    _CacheDialogStatus.failed => l10n.referenceCacheProgressFailedTitle,
  };
}

String _subtitleFor({
  required _CacheDialogStatus status,
  required int total,
  required int succeeded,
  required int failed,
}) {
  return switch (status) {
    _CacheDialogStatus.running => '$succeeded / $total',
    _CacheDialogStatus.success => l10n.referenceCacheProgressSuccessSummary(
      succeeded,
      total,
    ),
    _CacheDialogStatus.partial || _CacheDialogStatus.failed =>
      l10n.referenceCacheProgressPartialSummary(succeeded, total, failed),
  };
}
