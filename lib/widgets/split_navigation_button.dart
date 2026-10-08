import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../app_theme.dart';
import '../l10n/l10n.dart';

class SplitNavigationButton extends StatelessWidget {
  const SplitNavigationButton({
    required this.inAppLabel,
    required this.onOpenInAppNavigation,
    required this.onOpenExternalNavigation,
    this.height = 44,
    this.walkIconSize = 24,
    this.inAppKey = const ValueKey('map-in-app-navigation-button'),
    this.externalKey = const ValueKey('map-external-navigation-button'),
    this.dividerKey = const ValueKey('map-navigation-button-divider'),
    super.key,
  });

  final String inAppLabel;
  final VoidCallback? onOpenInAppNavigation;
  final VoidCallback? onOpenExternalNavigation;
  final double height;
  final double walkIconSize;
  final Key inAppKey;
  final Key externalKey;
  final Key dividerKey;

  // Like the primary key, a pressed half inverts to ink.
  static WidgetStateProperty<Color?> get _overlayColor =>
      WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.pressed)
            ? AppColors.ink
            : Colors.transparent,
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled =
        onOpenInAppNavigation != null || onOpenExternalNavigation != null;
    final foregroundColor = enabled
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final backgroundColor = enabled
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.12);

    return Material(
      color: backgroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SplitNavHalf(
                buttonKey: inAppKey,
                enabled: onOpenInAppNavigation != null,
                label: l10n.splitNavigationButtonInApp(inAppLabel),
                onTap: onOpenInAppNavigation,
                iconColor: foregroundColor,
                child: _IconWithText(
                  icon: Icon(Icons.directions_walk, size: walkIconSize),
                  text: l10n.splitNavigationRouteShort,
                ),
              ),
            ),
            // A full-height seam between the two halves.
            ColoredBox(
              key: dividerKey,
              color: AppColors.divider,
              child: const SizedBox(width: 1),
            ),
            Expanded(
              child: _SplitNavHalf(
                buttonKey: externalKey,
                enabled: onOpenExternalNavigation != null,
                label: l10n.splitNavigationButtonExternal,
                onTap: onOpenExternalNavigation,
                iconColor: foregroundColor,
                child: _IconWithText(
                  icon: const Icon(LucideIcons.navigation, size: 21),
                  text: l10n.splitNavigationMapsShort,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitNavHalf extends StatelessWidget {
  const _SplitNavHalf({
    required this.buttonKey,
    required this.enabled,
    required this.label,
    required this.onTap,
    required this.iconColor,
    required this.child,
  });

  final Key buttonKey;
  final bool enabled;
  final String label;
  final VoidCallback? onTap;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: buttonKey,
            onTap: onTap,
            overlayColor: SplitNavigationButton._overlayColor,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Center(
              child: DefaultTextStyle.merge(
                style: TextStyle(color: iconColor),
                child: IconTheme(
                  data: IconThemeData(color: iconColor),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconWithText extends StatelessWidget {
  const _IconWithText({required this.icon, required this.text});

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
