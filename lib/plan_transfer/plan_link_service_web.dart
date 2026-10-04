import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../desktop/tauri_bridge.dart';
import '../l10n/l10n.dart';
import 'plan_import_package.dart';
import 'plan_link.dart';
import 'plan_transfer_background.dart';

PlanLinkService createPlanLinkService() => _WebPlanLinkService();

/// The desktop app downloads through its launcher; the browser build cannot
/// read GitHub release downloads (no CORS headers) and only explains that.
class _WebPlanLinkService implements PlanLinkService {
  @override
  bool get available => isTauriLauncherAvailable;

  @override
  Future<String> fetchRelease(GitHubReleaseLink link) async {
    final http.Response response;
    try {
      response = await http
          .get(
            link.apiUri,
            headers: const {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 15));
    } on Object {
      throw PlanLinkException(l10n.planLinkCannotReachGitHub);
    }
    if (response.statusCode != 200) {
      throw gitHubReleaseError(response.statusCode);
    }
    return response.body;
  }

  @override
  Future<DownloadedPlanFile> download(
    Uri uri, {
    required String fileName,
    PlanLinkProgress? onProgress,
    PlanTransferCancellation? cancellation,
  }) async {
    if (!available) {
      throw PlanLinkException(l10n.planLinkServiceWebUnavailable);
    }
    final downloadId =
        '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 30)}';
    final download = downloadDesktopPlanPackage(
      url: uri.toString(),
      downloadId: downloadId,
    );
    var done = false;
    unawaited(
      cancellation?.whenCancelled.then((_) {
        if (!done) unawaited(cancelDesktopPlanDownload(downloadId));
      }),
    );
    final poll = Timer.periodic(const Duration(milliseconds: 300), (_) async {
      final progress = await desktopPlanDownloadProgress(
        downloadId,
      ).catchError((Object _) => null);
      if (progress != null && !done) {
        onProgress?.call(progress.received, progress.total);
      }
    });
    try {
      final bytes = await download;
      cancellation?.throwIfCancelled();
      return DownloadedPlanFile(fileName: fileName, bytes: bytes);
    } on PlanTransferCancelledException {
      rethrow;
    } on Object catch (error) {
      if (cancellation?.isCancelled ?? false) {
        throw const PlanTransferCancelledException();
      }
      throw _launcherError(error.toString());
    } finally {
      done = true;
      poll.cancel();
    }
  }

  @override
  Future<PlanImportPackage> read(
    DownloadedPlanFile file, {
    String? entryName,
    PlanTransferCancellation? cancellation,
  }) {
    final bytes = file.bytes!;
    return runPlanTransferTask(
      () => readPlanImportPackageFromDownload(
        bytes,
        sourceName: file.fileName,
        entryName: entryName,
      ),
      cancellation: cancellation,
    );
  }

  @override
  Future<void> discard(DownloadedPlanFile file) async {}

  @override
  Future<void> sweep() async {}
}

Exception _launcherError(String message) {
  final status = RegExp(
    r'request failed: (\d{3})\b',
  ).firstMatch(message)?.group(1);
  if (status != null) {
    return planLinkHttpError(int.parse(status));
  }
  if (message.contains('response too large')) {
    return planLinkTooLarge;
  }
  if (message.contains('non-public') || message.contains('not allowed')) {
    return planLinkNotPublic;
  }
  return PlanLinkException(l10n.planLinkDownloadFailed);
}
