import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/snackbar_helper.dart';
import '../l10n/l10n.dart';

enum GallerySaveResult { saved, permissionDenied, failed }

/// Error codes the native savers use when photo library access is refused
/// (iOS: add-only photo access; Android 9 and earlier: storage).
const galleryPermissionDeniedCodes = {
  'PHOTO_PERMISSION_DENIED',
  'PERMISSION_DENIED',
};

/// Reports a manual "保存到相册"; a refused permission offers the system
/// settings, since asking again does nothing once it was declined.
void showGallerySaveResult(
  ScaffoldMessengerState messenger,
  GallerySaveResult result, {
  String? failedTitle,
}) {
  switch (result) {
    case GallerySaveResult.saved:
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: l10n.gallerySaveResultSaved,
      );
    case GallerySaveResult.permissionDenied:
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.gallerySaveResultPermissionTitle,
        subtitle: l10n.gallerySaveResultPermissionSubtitle,
        actionLabel: l10n.gallerySaveResultSettings,
        onAction: () {
          messenger.hideCurrentSnackBar();
          openAppSettings().catchError((Object _) => false);
        },
        // Screen reader users need time to reach the action.
        duration:
            MediaQuery.maybeAccessibleNavigationOf(messenger.context) ?? false
            ? const Duration(seconds: 30)
            : const Duration(seconds: 6),
      );
    case GallerySaveResult.failed:
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: failedTitle ?? l10n.gallerySaveResultFailed,
      );
  }
}
