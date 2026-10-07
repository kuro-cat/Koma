import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../settings/app_settings_updater.dart';
import 'confirm_action_dialog.dart';
import 'snackbar_helper.dart';

/// The AI agent skill that plans a pilgrimage and exports a .sjhplan.
const routePlannerSkillUrl =
    'https://github.com/BilyHurington/miriago-route-planner-skill';

String get routePlannerSkillTitle => l10n.routePlannerSkillHintTitle;

String get routePlannerSkillDescription =>
    l10n.routePlannerSkillHintDescription;

Future<void> _saveRoutePlannerSkillDismissal(
  PilgrimageRepository repository,
) async {
  final saved = await AppSettingsUpdater.update(
    repository,
    (settings) => settings.copyWith(routePlannerSkillPromotionDismissed: true),
  );
  if (!saved) throw StateError('settings not saved');
}

Future<void> openRoutePlannerSkillGuide(BuildContext context) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(routePlannerSkillUrl),
      mode: LaunchMode.externalApplication,
    );
  } on Object {
    opened = false;
  }
  if (!opened) {
    messenger?.showStatusSnack(
      kind: AppStatusBannerKind.error,
      title: l10n.routePlannerSkillHintOpenFailed,
      subtitle: routePlannerSkillUrl,
    );
  }
}

/// Introduces the skill once, the first time the user adds content.
Future<void> showRoutePlannerSkillIntroDialog(BuildContext context) async {
  final open = await showConfirmActionDialog(
    context,
    title: routePlannerSkillTitle,
    message: routePlannerSkillDescription,
    confirmLabel: l10n.routePlannerSkillHintViewGuide,
    cancelLabel: l10n.confirmActionGotIt,
  );
  if (open && context.mounted) {
    await openRoutePlannerSkillGuide(context);
  }
}

/// Card on the import/export page.
class RoutePlannerSkillCard extends StatefulWidget {
  const RoutePlannerSkillCard({required this.repository, super.key});

  final PilgrimageRepository repository;

  @override
  State<RoutePlannerSkillCard> createState() => _RoutePlannerSkillCardState();
}

class _RoutePlannerSkillCardState extends State<RoutePlannerSkillCard> {
  bool? _dismissed;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDismissal();
  }

  Future<void> _loadDismissal() async {
    try {
      final settings = await widget.repository.loadAppSettings();
      if (mounted) {
        setState(
          () => _dismissed = settings.routePlannerSkillPromotionDismissed,
        );
      }
    } on Object {
      if (mounted) setState(() => _dismissed = false);
    }
  }

  Future<void> _dismiss() async {
    setState(() => _saving = true);
    try {
      await _saveRoutePlannerSkillDismissal(widget.repository);
      if (mounted) setState(() => _dismissed = true);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.routePlannerSkillHintDismissFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed != false) return const SizedBox.shrink();

    return InkWell(
      key: const ValueKey('route-planner-skill-card'),
      borderRadius: BorderRadius.circular(8),
      onTap: () => openRoutePlannerSkillGuide(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.sparkles,
                  color: AppColors.accentStrongForeground,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    routePlannerSkillTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('route-planner-skill-dismiss'),
                  tooltip: l10n.commonClose,
                  visualDensity: VisualDensity.compact,
                  onPressed: _saving ? null : _dismiss,
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              routePlannerSkillDescription,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.45,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                l10n.routePlannerSkillHintTapForGuide,
                key: const ValueKey('route-planner-skill-open'),
                style: TextStyle(
                  color: AppColors.accentStrongForeground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-line pointer to the skill, for pages where a card would be too much.
class RoutePlannerSkillLink extends StatefulWidget {
  const RoutePlannerSkillLink({
    required this.lead,
    required this.repository,
    super.key,
  });

  /// Text before the link, e.g. "想省去手动整理？".
  final String lead;
  final PilgrimageRepository repository;

  @override
  State<RoutePlannerSkillLink> createState() => _RoutePlannerSkillLinkState();
}

class _RoutePlannerSkillLinkState extends State<RoutePlannerSkillLink> {
  bool? _dismissed;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDismissal();
  }

  Future<void> _loadDismissal() async {
    try {
      final settings = await widget.repository.loadAppSettings();
      if (mounted) {
        setState(
          () => _dismissed = settings.routePlannerSkillPromotionDismissed,
        );
      }
    } on Object {
      if (mounted) setState(() => _dismissed = false);
    }
  }

  Future<void> _dismiss() async {
    setState(() => _saving = true);
    try {
      await _saveRoutePlannerSkillDismissal(widget.repository);
      if (mounted) setState(() => _dismissed = true);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.routePlannerSkillHintDismissFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed != false) return const SizedBox.shrink();

    final style = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      height: 1.4,
      letterSpacing: 0,
    );
    return InkWell(
      key: const ValueKey('route-planner-skill-link'),
      borderRadius: BorderRadius.circular(6),
      onTap: () => openRoutePlannerSkillGuide(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                LucideIcons.sparkles,
                size: 14,
                color: AppColors.accentStrongForeground,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: style,
                  children: [
                    TextSpan(text: widget.lead),
                    TextSpan(
                      text: l10n.routePlannerSkillHintLinkText,
                      style: TextStyle(
                        color: AppColors.accentStrongForeground,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accentStrongForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('route-planner-skill-link-dismiss'),
              tooltip: l10n.commonClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              onPressed: _saving ? null : _dismiss,
              icon: const Icon(LucideIcons.x, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
