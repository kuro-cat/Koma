import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../app_theme.dart';

enum ReferenceImagePlaceholderState { loading, unavailable, empty }

class ReferenceImagePlaceholder extends StatelessWidget {
  const ReferenceImagePlaceholder({
    this.state = ReferenceImagePlaceholderState.unavailable,
    this.compact = false,
    this.iconColor,
    super.key,
  });

  final ReferenceImagePlaceholderState state;
  final bool compact;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      ReferenceImagePlaceholderState.loading =>
        l10n.referenceImagePlaceholderLoading,
      ReferenceImagePlaceholderState.unavailable =>
        l10n.referenceImagePlaceholderUnavailable,
      ReferenceImagePlaceholderState.empty =>
        l10n.referenceImagePlaceholderEmpty,
    };

    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 6 : 14),
          child: compact
              ? Icon(
                  LucideIcons.image,
                  color: iconColor ?? AppColors.accentStrongForeground,
                  size: 28,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state == ReferenceImagePlaceholderState.loading)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    else
                      Icon(
                        LucideIcons.image,
                        color: iconColor ?? AppColors.accentStrongForeground,
                        size: 32,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
