import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import 'app_motion.dart';

enum AppStatusBannerKind { running, success, warning, error }

const appStatusSnackDuration = Duration(seconds: 3);

String statusBannerSentence(String text) {
  if (text.endsWith('。') && !text.substring(0, text.length - 1).contains('。')) {
    return text.substring(0, text.length - 1);
  }
  // English: same rule, but keep "..." and multi-sentence text.
  if (text.endsWith('.') &&
      !text.endsWith('..') &&
      !text.substring(0, text.length - 1).contains('. ')) {
    return text.substring(0, text.length - 1);
  }
  return text;
}

/// Running banners show [icon] when the caller names one, else an hourglass.
/// The icon never comes from the title text, which is translated.
IconData statusBannerIcon({required AppStatusBannerKind kind, IconData? icon}) {
  if (icon != null) {
    return icon;
  }
  return switch (kind) {
    AppStatusBannerKind.success => LucideIcons.check,
    AppStatusBannerKind.warning => LucideIcons.triangleAlert,
    AppStatusBannerKind.error => LucideIcons.circleAlert,
    AppStatusBannerKind.running => LucideIcons.hourglass,
  };
}

SnackBar appStatusSnackBar({
  required AppStatusBannerKind kind,
  required String title,
  String? subtitle,
  IconData? icon,
  Duration duration = appStatusSnackDuration,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    behavior: SnackBarBehavior.floating,
    duration: duration,
    content: AppStatusBanner(
      kind: kind,
      title: title,
      subtitle: subtitle,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

Future<void> showStatusBannerOverlay({
  required BuildContext context,
  required Widget Function(BuildContext dialogContext) builder,
}) async {
  final scaffold = context.findAncestorWidgetOfExactType<Scaffold>();
  final navExtra = scaffold?.bottomNavigationBar == null
      ? 0.0
      : (NavigationBarTheme.of(context).height ?? 80);
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: AppMotion.durationOf(context, milliseconds: 180),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _AutoClosingStatusOverlay(
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + navExtra),
              child: SizedBox(
                width: double.infinity,
                child: builder(dialogContext),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AutoClosingStatusOverlay extends StatefulWidget {
  const _AutoClosingStatusOverlay({required this.child});

  final Widget child;

  @override
  State<_AutoClosingStatusOverlay> createState() =>
      _AutoClosingStatusOverlayState();
}

class _AutoClosingStatusOverlayState extends State<_AutoClosingStatusOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(appStatusSnackDuration, () {
      if (mounted) {
        final route = ModalRoute.of(context);
        final navigator = route?.navigator;
        if (route == null || navigator == null || !route.isActive) return;
        if (route.isCurrent) {
          navigator.pop();
        } else {
          // A newer page may cover this overlay; never pop that page.
          navigator.removeRoute(route);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AppStatusBanner extends StatelessWidget {
  const AppStatusBanner({
    super.key,
    required this.kind,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.footer,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.icon,
  });

  final AppStatusBannerKind kind;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? footer;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = AppStatusBannerPalette.of(kind);
    return Material(
      color: palette.background,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppContentFade(
                  revision: kind,
                  child: _StatusIcon(kind: kind, palette: palette, icon: icon),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusBannerSentence(title),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                      if (subtitleWidget != null ||
                          (subtitle != null && subtitle!.isNotEmpty)) ...[
                        const SizedBox(height: 2),
                        if (subtitleWidget != null)
                          subtitleWidget!
                        else
                          Text(
                            statusBannerSentence(subtitle!),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(width: 8),
                  _ActionButton(
                    buttonKey: actionKey,
                    label: actionLabel!,
                    color: palette.action,
                    onPressed: onAction ?? () {},
                  ),
                ],
              ],
            ),
            if (footer != null) ...[const SizedBox(height: 8), footer!],
          ],
        ),
      ),
    );
  }
}

class AppStatusBannerPalette {
  const AppStatusBannerPalette({
    required this.background,
    required this.border,
    required this.iconFill,
    required this.iconColor,
    required this.action,
  });

  final Color background;
  final Color border;
  final Color iconFill;
  final Color iconColor;
  final Color action;

  /// A popup on raise with a 1px ink frame. Only the icon carries the
  /// signal: accent for running and done, ochre for warnings, red for errors.
  factory AppStatusBannerPalette.of(AppStatusBannerKind kind) {
    final surface = AppColors.surface;
    final ink = AppColors.ink;
    return switch (kind) {
      AppStatusBannerKind.running => AppStatusBannerPalette(
        background: surface,
        border: ink,
        iconFill: AppColors.accentWash,
        iconColor: AppColors.accentForeground,
        action: ink,
      ),
      AppStatusBannerKind.success => AppStatusBannerPalette(
        background: surface,
        border: ink,
        iconFill: AppColors.accent,
        iconColor: AppColors.onAccent,
        action: ink,
      ),
      AppStatusBannerKind.warning => AppStatusBannerPalette(
        background: surface,
        border: ink,
        iconFill: AppColors.warning,
        iconColor: AppColors.foregroundOn(AppColors.warning),
        action: ink,
      ),
      AppStatusBannerKind.error => AppStatusBannerPalette(
        background: surface,
        border: ink,
        iconFill: AppColors.error,
        iconColor: AppColors.foregroundOn(AppColors.error),
        action: ink,
      ),
    };
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.kind, required this.palette, this.icon});

  final AppStatusBannerKind kind;
  final AppStatusBannerPalette palette;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (kind == AppStatusBannerKind.warning) {
      return Icon(LucideIcons.triangleAlert, size: 32, color: palette.iconFill);
    }
    if (kind == AppStatusBannerKind.error) {
      return Icon(LucideIcons.circleAlert, size: 32, color: palette.iconFill);
    }
    final resolved = statusBannerIcon(kind: kind, icon: icon);
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      color: palette.iconFill,
      child: Icon(resolved, size: 18, color: palette.iconColor),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.buttonKey,
  });

  final Key? buttonKey;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: buttonKey,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size(44, AppButtonStyles.compactHeight),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      child: Text(label),
    );
  }
}

class AppStatusBannerProgressLine extends StatelessWidget {
  const AppStatusBannerProgressLine({
    required this.countLabel,
    required this.percentLabel,
    required this.value,
    this.barKey,
    super.key,
  });

  final String countLabel;
  final String percentLabel;
  final double value;
  final Key? barKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          countLabel,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: LinearProgressIndicator(
              key: barKey,
              value: value,
              minHeight: 4,
              backgroundColor: AppColors.surfaceMuted,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentLabel,
          style: TextStyle(
            color: AppColors.accentForeground,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
