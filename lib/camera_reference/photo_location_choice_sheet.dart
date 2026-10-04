import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import '../plan/pilgrimage_models.dart';
import '../l10n/l10n.dart';

class PhotoLocationChoiceSheet extends StatelessWidget {
  const PhotoLocationChoiceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          key: const ValueKey('photo-location-choice-sheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.photoLocationChoiceTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.photoLocationChoiceChangeLater,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
            Text(
              l10n.photoLocationChoiceNoSpotCoordinates,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            _PhotoLocationChoiceTile(
              key: const ValueKey('photo-location-choice-recent'),
              icon: LucideIcons.history,
              title: l10n.photoLocationChoiceRecentTitle,
              subtitle: l10n.photoLocationChoiceRecentSubtitle,
              onTap: () => Navigator.of(
                context,
              ).pop(PhotoLocationStrategy.useRecentLocation),
            ),
            const SizedBox(height: 10),
            _PhotoLocationChoiceTile(
              key: const ValueKey('photo-location-choice-confirm'),
              icon: LucideIcons.locateFixed,
              title: l10n.photoLocationChoiceConfirmTitle,
              subtitle: l10n.photoLocationChoiceConfirmSubtitle,
              recommended: true,
              onTap: () => Navigator.of(
                context,
              ).pop(PhotoLocationStrategy.waitOnConfirmation),
            ),
            const SizedBox(height: 10),
            _PhotoLocationChoiceTile(
              key: const ValueKey('photo-location-choice-disabled'),
              icon: LucideIcons.mapPinOff,
              title: l10n.photoLocationChoiceDisabledTitle,
              onTap: () =>
                  Navigator.of(context).pop(PhotoLocationStrategy.disabled),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoLocationChoiceTile extends StatelessWidget {
  const _PhotoLocationChoiceTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.recommended = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        if (recommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.08),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.42),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.photoLocationChoiceRecommended,
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
