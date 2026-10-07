import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../map/map_colors.dart';
import '../data/app_file_reclamation.dart';
import '../data/bangumi_api_client.dart';
import '../data/anitabi_link_parser.dart';
import '../data/pilgrimage_repository.dart';
import '../desktop/desktop_asset_image.dart';
import '../data/user_reference_image_stub.dart'
    if (dart.library.io) '../data/user_reference_image_io.dart';
import '../map/map_tile_config.dart';
import '../map/map_marker_scale.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/reference_thumbnail_stub.dart'
    if (dart.library.io) '../widgets/reference_thumbnail_io.dart';
import '../widgets/image_viewer_screen.dart';
import '../widgets/app_scaled_route.dart';
import '../widgets/app_back_button.dart';
import '../widgets/responsive_button.dart';
import '../widgets/route_planner_skill_hint.dart';
import 'anitabi_map_import_screen.dart';
import 'coordinate_parser.dart';
import 'pending_reference_lifecycle.dart';
import 'pilgrimage_work_dropdown.dart';
import 'pilgrimage_models.dart';
import 'pilgrimage_work_cover.dart';
import 'reference_image_status.dart';
import 'work_manager_screen.dart';
import '../settings/app_settings_updater.dart';
import '../l10n/l10n.dart';

InputDecoration stableInputDecoration({
  required String labelText,
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    helperText: ' ',
  );
}

double _guideDialogHeight(BuildContext context, double contentHeight) {
  final viewportLimit = MediaQuery.sizeOf(context).height * 0.72;
  return viewportLimit < contentHeight ? viewportLimit : contentHeight;
}

Future<void> _pasteCoordinateFromClipboardInto({
  required BuildContext context,
  required TextEditingController latitudeController,
  required TextEditingController longitudeController,
  required VoidCallback onFilled,
  bool Function()? canApply,
}) async {
  LatLng? coordinate;
  try {
    coordinate = await parseClipboardCoordinate();
  } on Object {
    if (context.mounted && (canApply?.call() ?? true)) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.warning,
        title: l10n.addPointsClipboardReadFailed,
      );
    }
    return;
  }
  if (!context.mounted || !(canApply?.call() ?? true)) {
    return;
  }
  if (coordinate == null) {
    ScaffoldMessenger.of(context).showStatusSnack(
      kind: AppStatusBannerKind.warning,
      title: l10n.addPointsClipboardNoCoordinate,
    );
    return;
  }
  final parsed = coordinate;
  latitudeController.text = parsed.latitude.toStringAsFixed(6);
  longitudeController.text = parsed.longitude.toStringAsFixed(6);
  onFilled();
  ScaffoldMessenger.of(context).showStatusSnack(
    kind: AppStatusBannerKind.success,
    title: l10n.addPointsCoordinateFilled,
  );
}

InputDecoration _boxedFormDecoration({
  String? hintText,
  bool reserveHelperSpace = true,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: AppColors.textSecondary.withValues(alpha: 0.42),
      fontSize: 14,
      letterSpacing: 0,
    ),
    helperText: reserveHelperSpace ? ' ' : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.accent, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
    ),
  );
}

InputDecoration _workTypeDropdownDecoration() {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AppColors.surface,
    hoverColor: AppColors.accent.withValues(alpha: 0.035),
    helperText: ' ',
    contentPadding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.border, width: 1.4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.accent, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
    ),
  );
}

const _manualWorkSubjectTypes = [
  BangumiSubjectType.anime,
  BangumiSubjectType.game,
  BangumiSubjectType.book,
  BangumiSubjectType.music,
  BangumiSubjectType.real,
];

class AddPointsScreen extends StatefulWidget {
  AddPointsScreen({
    required this.plan,
    required this.repository,
    required this.settings,
    BangumiApiClient? bangumiApiClient,
    super.key,
  }) : bangumiApiClient = bangumiApiClient ?? BangumiApiClient();

  final PilgrimagePlan? plan;
  final PilgrimageRepository repository;
  final AppSettings settings;
  final BangumiApiClient bangumiApiClient;

  @override
  State<AddPointsScreen> createState() => _AddPointsScreenState();
}

class _AddPointsScreenState extends State<AddPointsScreen> {
  late PilgrimagePlan? _plan = widget.plan;
  var _didUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_introduceRoutePlannerSkill());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = _plan;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }

        Navigator.of(context).pop(_didUpdate);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: appBackButtonIfCanPop(context),
          title: Text(l10n.addPointsTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _FindSpotsPanel(
              enabled: currentPlan != null,
              onTap: currentPlan == null
                  ? null
                  : () => _openAnitabiMapImport(context, currentPlan),
            ),
            const SizedBox(height: 12),
            _AddPointPanel(
              manualEnabled: currentPlan != null,
              quickManualEnabled:
                  currentPlan != null && currentPlan.works.isNotEmpty,
              onManual: currentPlan == null
                  ? null
                  : () => _openManualPointForm(context, currentPlan),
              onQuickManual: currentPlan == null || currentPlan.works.isEmpty
                  ? null
                  : () => _openQuickManualPointForm(context, currentPlan),
            ),
            const SizedBox(height: 12),
            _LinkedWorksPanel(
              plan: currentPlan,
              onManage: currentPlan == null
                  ? null
                  : () => _openWorkManager(context, currentPlan),
              onBangumi: currentPlan == null
                  ? null
                  : () => _openBangumiSearch(context, currentPlan),
              onManual: currentPlan == null
                  ? null
                  : () => _openManualWorkForm(context, currentPlan),
            ),
            const SizedBox(height: 8),
            RoutePlannerSkillLink(
              lead: l10n.addPointsRoutePlannerLead,
              repository: widget.repository,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _introduceRoutePlannerSkill() async {
    final current = AppSettingsUpdater.latest(widget.settings);
    if (current.routePlannerSkillTipShown ||
        current.routePlannerSkillPromotionDismissed) {
      return;
    }
    // Mark it first so the introduction never repeats, whatever happens
    // while it is open.
    var alreadyShown = false;
    final saved = await AppSettingsUpdater.update(widget.repository, (latest) {
      alreadyShown =
          latest.routePlannerSkillTipShown ||
          latest.routePlannerSkillPromotionDismissed;
      return latest.copyWith(routePlannerSkillTipShown: true);
    });
    if (!saved || alreadyShown) {
      return;
    }
    if (!mounted) {
      return;
    }
    await showRoutePlannerSkillIntroDialog(context);
  }

  Future<void> _openWorkManager(
    BuildContext context,
    PilgrimagePlan plan,
  ) async {
    await Navigator.of(context).push<bool>(
      appScaledMaterialPageRoute<bool>(
        settings: widget.settings,
        builder: (_) => WorkManagerScreen(
          plan: plan,
          repository: widget.repository,
          settings: widget.settings,
          bangumiApiClient: widget.bangumiApiClient,
        ),
      ),
    );
    if (!context.mounted) {
      return;
    }

    await _reloadPlan(plan.id);
  }

  Future<void> _openBangumiSearch(
    BuildContext context,
    PilgrimagePlan plan,
  ) async {
    await Navigator.of(context).push<bool>(
      appScaledMaterialPageRoute<bool>(
        settings: widget.settings,
        builder: (_) => BangumiWorkSearchScreen(
          plan: plan,
          repository: widget.repository,
          bangumiApiClient: widget.bangumiApiClient,
        ),
      ),
    );
    if (context.mounted) {
      await _reloadPlan(plan.id);
    }
  }

  Future<void> _openManualWorkForm(
    BuildContext context,
    PilgrimagePlan plan,
  ) async {
    await Navigator.of(context).push<bool>(
      appScaledMaterialPageRoute<bool>(
        settings: widget.settings,
        builder: (_) => ManualWorkFormScreen(
          plan: plan,
          repository: widget.repository,
          settings: widget.settings,
        ),
      ),
    );
    if (context.mounted) {
      await _reloadPlan(plan.id);
    }
  }

  Future<void> _openAnitabiMapImport(
    BuildContext context,
    PilgrimagePlan plan,
  ) async {
    await Navigator.of(context).push<bool>(
      appScaledMaterialPageRoute<bool>(
        settings: widget.settings,
        builder: (_) => AnitabiMapImportScreen(
          plan: plan,
          repository: widget.repository,
          initialSettings: widget.settings,
        ),
      ),
    );
    if (!context.mounted) {
      return;
    }

    final changed = await _reloadPlan(plan.id);
    if (!context.mounted || !changed) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _openManualPointForm(
    BuildContext context,
    PilgrimagePlan plan,
  ) async {
    await Navigator.of(context).push<bool>(
      appScaledMaterialPageRoute<bool>(
        settings: widget.settings,
        builder: (_) => _ManualPointFormScreen(
          plan: plan,
          repository: widget.repository,
          settings: widget.settings,
        ),
      ),
    );
    if (!context.mounted) {
      return;
    }

    final changed = await _reloadPlan(plan.id);
    if (!context.mounted || !changed) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _openQuickManualPointForm(
    BuildContext context,
    PilgrimagePlan plan,
  ) async {
    final draft = await Navigator.of(context).push<_QuickManualPointDraft>(
      appScaledMaterialPageRoute<_QuickManualPointDraft>(
        settings: widget.settings,
        builder: (_) =>
            _QuickManualPointFormScreen(plan: plan, settings: widget.settings),
      ),
    );
    if (draft == null || !context.mounted) {
      return;
    }

    final now = DateTime.now();
    final point = PilgrimagePoint(
      id: 'manual-${now.microsecondsSinceEpoch}',
      work: draft.work,
      name: draft.name,
      subtitle: '',
      position: draft.position ?? PilgrimagePoint.pendingPosition,
      episodeLabel: '',
      referenceLabel: l10n.addPointsManualEntryReference,
      source: PointSource.manual,
    );
    try {
      await widget.repository.addPointToPlan(planId: plan.id, point: point);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.addPointsPointSaveFailed,
        );
      }
      return;
    }
    if (!context.mounted) {
      return;
    }

    final changed = await _reloadPlan(plan.id);
    if (!context.mounted || !changed) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<bool> _reloadPlan(String planId) async {
    final oldPlan = _plan;
    final plans = await widget.repository.loadPlans();
    if (!mounted) {
      return false;
    }
    final updatedPlan = plans.firstWhere((plan) => plan.id == planId);
    final changed =
        oldPlan == null ||
        oldPlan.works.length != updatedPlan.works.length ||
        oldPlan.points.length != updatedPlan.points.length ||
        oldPlan.groups.length != updatedPlan.groups.length;

    setState(() {
      _plan = updatedPlan;
      _didUpdate = _didUpdate || changed;
    });
    return changed;
  }
}

class BangumiWorkSearchScreen extends StatefulWidget {
  const BangumiWorkSearchScreen({
    required this.plan,
    required this.repository,
    required this.bangumiApiClient,
    this.pickOnly = false,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;
  final BangumiApiClient bangumiApiClient;

  /// Pops with the chosen work instead of adding it to the plan.
  final bool pickOnly;

  @override
  State<BangumiWorkSearchScreen> createState() =>
      BangumiWorkSearchScreenState();
}

class BangumiWorkSearchScreenState extends State<BangumiWorkSearchScreen> {
  final _queryController = TextEditingController();
  List<PilgrimageWork> _results = const [];
  Set<BangumiSubjectType> _selectedTypes = const {
    BangumiSubjectType.anime,
    BangumiSubjectType.game,
  };
  Object? _error;
  bool _isSearching = false;
  bool _isAdding = false;
  bool _didAdd = false;
  bool _isTypeFilterExpanded = true;
  final Set<String> _addedWorkIds = {};

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_handleQueryChanged);
  }

  void _handleQueryChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _clearQuery() {
    _queryController.clear();
  }

  @override
  void dispose() {
    _queryController.removeListener(_handleQueryChanged);
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty || _isSearching) {
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
      _isTypeFilterExpanded = false;
    });

    try {
      final results = await widget.bangumiApiClient.searchSubjects(
        query,
        types: _selectedTypes,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _results = results;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
        _results = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _addWork(PilgrimageWork work) async {
    if (_isAdding) {
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      await widget.repository.addWorkToPlan(planId: widget.plan.id, work: work);
      if (!mounted) {
        return;
      }

      setState(() {
        _didAdd = true;
        _addedWorkIds.add(work.id);
      });
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: l10n.addPointsWorkAdded(work.title),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.addPointsWorkAddFailed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(widget.pickOnly ? null : _didAdd);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addPointsSearchBangumiTitle),
          leading: AppBackButton(
            onPressed: () =>
                Navigator.of(context).pop(widget.pickOnly ? null : _didAdd),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _FormSection(
              children: [
                _ManualWorkLabeledField(
                  label: l10n.addPointsWorkNameLabel,
                  prominent: true,
                  child: TextField(
                    onTapOutside: dismissKeyboardOnTapOutside,
                    controller: _queryController,
                    decoration:
                        _boxedFormDecoration(
                          hintText: l10n.addPointsWorkNameSearchHint,
                          reserveHelperSpace: false,
                        ).copyWith(
                          suffixIcon: _queryController.text.isEmpty
                              ? null
                              : IconButton(
                                  key: const ValueKey(
                                    'bangumi-search-clear-button',
                                  ),
                                  tooltip: l10n.addPointsClearSearch,
                                  onPressed: _clearQuery,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 40,
                                    height: 46,
                                  ),
                                  icon: const Icon(LucideIcons.x, size: 19),
                                ),
                          suffixIconConstraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 46,
                          ),
                        ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSearching ? null : _search,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.search, size: 18),
                    label: Text(
                      _isSearching
                          ? l10n.addPointsSearching
                          : l10n.addPointsSearchWorks,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _BangumiTypeFilterDisclosure(
                  expanded: _isTypeFilterExpanded,
                  selectedTypes: _selectedTypes,
                  onToggle: () {
                    setState(() {
                      _isTypeFilterExpanded = !_isTypeFilterExpanded;
                    });
                  },
                  onChanged: (types) {
                    setState(() {
                      _selectedTypes = types;
                    });
                  },
                ),
                if (_results.isEmpty && _error == null) ...[
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.65),
                  ),
                  const SizedBox(height: 12),
                  const _BangumiSearchHintContent(),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null)
              _MessageCard(
                icon: LucideIcons.circleAlert,
                text: l10n.addPointsBangumiSearchFailed,
              )
            else if (_results.isNotEmpty)
              for (final work in _results) ...[
                _WorkResultCard(
                  work: work,
                  added: !widget.pickOnly && _hasWork(widget.plan, work),
                  disabled: _isAdding,
                  actionLabel: widget.pickOnly ? l10n.addPointsPickWork : null,
                  onAdd: widget.pickOnly
                      ? () => Navigator.of(context).pop(work)
                      : () => _addWork(work),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }

  bool _hasWork(PilgrimagePlan plan, PilgrimageWork work) {
    return _addedWorkIds.contains(work.id) ||
        plan.works.any((candidate) => candidate.id == work.id);
  }
}

class _BangumiTypeFilter extends StatelessWidget {
  const _BangumiTypeFilter({
    required this.selectedTypes,
    required this.onChanged,
  });

  final Set<BangumiSubjectType> selectedTypes;
  final ValueChanged<Set<BangumiSubjectType>> onChanged;

  static const _types = [
    BangumiSubjectType.anime,
    BangumiSubjectType.game,
    BangumiSubjectType.book,
    BangumiSubjectType.music,
    BangumiSubjectType.real,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < _types.length; index++) ...[
            Expanded(child: _buildTypeItem(_types[index])),
            if (index < _types.length - 1)
              VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeItem(BangumiSubjectType type) {
    final selected = selectedTypes.contains(type);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleType(type, selected),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  type.label,
                  maxLines: 1,
                  style: TextStyle(
                    color: selected
                        ? AppColors.accentDark
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
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

  void _toggleType(BangumiSubjectType type, bool selected) {
    final nextTypes = {...selectedTypes};
    if (selected) {
      if (nextTypes.length == 1) {
        return;
      }
      nextTypes.remove(type);
    } else {
      nextTypes.add(type);
    }
    onChanged(nextTypes);
  }
}

class _BangumiTypeFilterDisclosure extends StatelessWidget {
  const _BangumiTypeFilterDisclosure({
    required this.expanded,
    required this.selectedTypes,
    required this.onToggle,
    required this.onChanged,
  });

  final bool expanded;
  final Set<BangumiSubjectType> selectedTypes;
  final VoidCallback onToggle;
  final ValueChanged<Set<BangumiSubjectType>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              child: SizedBox(
                height: 42,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.addPointsFilterWorkTypes,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      Text(
                        l10n.addPointsSelectedTypeCount(selectedTypes.length),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 160),
                        child: Icon(
                          LucideIcons.chevronDown,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: _BangumiTypeFilter(
                      selectedTypes: selectedTypes,
                      onChanged: onChanged,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Asks for an Anitabi map link and pops with it once it names a work.
class AnitabiLinkInputScreen extends StatefulWidget {
  const AnitabiLinkInputScreen({
    required this.plan,
    required this.settings,
    super.key,
  });

  final PilgrimagePlan plan;
  final AppSettings settings;

  @override
  State<AnitabiLinkInputScreen> createState() => _AnitabiLinkInputScreenState();
}

class _AnitabiLinkInputScreenState extends State<AnitabiLinkInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _linkController.addListener(_handleLinkChanged);
  }

  void _handleLinkChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _clearLink() {
    _linkController.clear();
    _formKey.currentState?.reset();
  }

  @override
  void dispose() {
    _linkController.removeListener(_handleLinkChanged);
    _linkController.dispose();
    super.dispose();
  }

  void _openImport() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    final link = parseAnitabiImportLink(_linkController.text);
    if (link == null || link.bangumiId == null) {
      return;
    }
    Navigator.of(context).pop(link);
  }

  Future<void> _pasteLinkFromClipboard() async {
    ClipboardData? data;
    try {
      data = await Clipboard.getData(Clipboard.kTextPlain);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.warning,
          title: l10n.addPointsLinkClipboardReadFailed,
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.warning,
        title: l10n.addPointsLinkClipboardEmpty,
      );
      return;
    }
    _linkController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    final hasLinkText = _linkController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(l10n.addPointsLinkImportTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              l10n.addPointsAddingTo(widget.plan.name),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.addPointsAnitabiLinkLabel,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onTapOutside: dismissKeyboardOnTapOutside,
                    controller: _linkController,
                    decoration: InputDecoration(
                      hintText: l10n.addPointsAnitabiLinkHint,
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.48),
                        fontSize: 14,
                        letterSpacing: 0,
                      ),
                      helperText: ' ',
                      suffixIcon: IconButton(
                        key: const ValueKey('anitabi-link-input-action'),
                        onPressed: hasLinkText
                            ? _clearLink
                            : _pasteLinkFromClipboard,
                        tooltip: hasLinkText
                            ? l10n.addPointsClearInput
                            : l10n.addPointsPaste,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        icon: Icon(
                          hasLinkText
                              ? LucideIcons.x
                              : LucideIcons.clipboardPaste,
                          size: 20,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.accent,
                          width: 1.4,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.4,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    validator: _validateLink,
                    onFieldSubmitted: (_) => _openImport(),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openImport,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                      ),
                      icon: const Icon(LucideIcons.mapPinPlus, size: 21),
                      label: Text(
                        l10n.addPointsOpenAnitabiSpots,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _LinkExampleCard(
              siteBaseUrl: widget.settings.anitabiServiceConfig.siteBaseUrl,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateLink(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return l10n.addPointsLinkRequired;
    }
    final link = parseAnitabiImportLink(text);
    if (link == null) {
      return l10n.addPointsLinkInvalid;
    }
    if (link.bangumiId == null) {
      return l10n.addPointsLinkMissingWorkId;
    }
    return null;
  }
}

class _LinkExampleCard extends StatelessWidget {
  const _LinkExampleCard({required this.siteBaseUrl});

  final String siteBaseUrl;
  static const _bangumiId = 'bangumiId=186515';
  static const _middle = '&';
  static const _pointId = 'pid=95ff4037';
  static const _suffix = '&c=139.7226%2C35.7126&z=19.1';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addPointsLinkExampleTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          _ExampleLinkText(linkPrefix: '$siteBaseUrl/map?'),
          const SizedBox(height: 12),
          Text(
            l10n.addPointsLinkExampleBody,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleLinkText extends StatelessWidget {
  const _ExampleLinkText({required this.linkPrefix});

  final String linkPrefix;

  @override
  Widget build(BuildContext context) {
    final normalStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 13,
      fontFamily: 'monospace',
      height: 1.25,
      letterSpacing: 0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          runSpacing: 4,
          children: [
            _ExamplePlainText(text: linkPrefix, style: normalStyle),
            _highlight(_LinkExampleCard._bangumiId),
            _ExamplePlainText(
              text: _LinkExampleCard._middle,
              style: normalStyle,
            ),
          ],
        ),
        const SizedBox(height: 6),
        _ExampleNoteRow(normalStyle: normalStyle, linkPrefix: linkPrefix),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          runSpacing: 4,
          children: [
            _highlight(_LinkExampleCard._pointId),
            _ExamplePlainText(
              text: _LinkExampleCard._suffix,
              style: normalStyle,
            ),
          ],
        ),
      ],
    );
  }

  static Widget _highlight(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        softWrap: false,
        style: TextStyle(
          color: AppColors.accentDark,
          fontSize: 13,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ExampleNoteRow extends StatelessWidget {
  const _ExampleNoteRow({required this.normalStyle, required this.linkPrefix});

  final TextStyle normalStyle;
  final String linkPrefix;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textDirection = Directionality.of(context);
        final bangumiLeft = _measureTextWidth(
          linkPrefix,
          normalStyle,
          textDirection,
        );
        final bangumiNoteWidth =
            _measureTextWidth(
              l10n.addPointsLinkExampleBangumiIdNote,
              _ExampleNote.textStyle,
              textDirection,
            ) +
            _ExampleNote.horizontalPadding;
        final resolvedBangumiLeft = bangumiLeft.clamp(
          0,
          (constraints.maxWidth - bangumiNoteWidth).clamp(0, double.infinity),
        );

        return SizedBox(
          height: 18,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: _ExampleNote(text: l10n.addPointsLinkExampleSpotIdNote),
              ),
              Positioned(
                left: resolvedBangumiLeft.toDouble(),
                top: 0,
                child: _ExampleNote(
                  text: l10n.addPointsLinkExampleBangumiIdNote,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _measureTextWidth(
    String text,
    TextStyle style,
    TextDirection textDirection,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();
    return painter.width;
  }
}

class _ExamplePlainText extends StatelessWidget {
  const _ExamplePlainText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(text, softWrap: false, style: style),
    );
  }
}

class _ExampleNote extends StatelessWidget {
  const _ExampleNote({required this.text});

  static const horizontalPadding = 16.0;
  static TextStyle get textStyle => TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 0,
  );

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: textStyle),
    );
  }
}

class ManualWorkFormScreen extends StatefulWidget {
  const ManualWorkFormScreen({
    required this.plan,
    required this.repository,
    required this.settings,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;
  final AppSettings settings;

  @override
  State<ManualWorkFormScreen> createState() => ManualWorkFormScreenState();
}

class ManualWorkFormScreenState extends State<ManualWorkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _cityController = TextEditingController();
  BangumiSubjectType _selectedSubjectType = BangumiSubjectType.anime;
  bool _isSaving = false;
  bool _didAdd = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveWork() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final title = _titleController.text.trim();
      final subtitle = _subtitleController.text.trim();
      final city = _cityController.text.trim();
      final work = PilgrimageWork(
        id: 'manual-work-${now.microsecondsSinceEpoch}',
        title: title,
        subtitle: subtitle,
        city: city.isEmpty ? widget.plan.area : city,
        source: WorkSource.manual,
        bangumiSubjectType: _selectedSubjectType,
      );

      await widget.repository.addWorkToPlan(planId: widget.plan.id, work: work);
      if (!mounted) {
        return;
      }

      setState(() {
        _didAdd = true;
      });
      _titleController.clear();
      _subtitleController.clear();
      _cityController.clear();
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: l10n.addPointsWorkAdded(title),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.addPointsWorkSaveFailed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showFillingGuide() {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: _guideDialogHeight(context, 540),
          child: AppScaledOverlayContent(
            settings: widget.settings,
            child: const _ManualWorkFillingGuideSheet(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(_didAdd);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addPointsManualAddWork),
          leading: AppBackButton(
            onPressed: () => Navigator.of(context).pop(_didAdd),
          ),
          actions: [
            TextButton(
              key: const ValueKey('manual-work-filling-guide'),
              onPressed: _showFillingGuide,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentDark,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: ResponsiveButtonContent(
                icon: LucideIcons.bookOpen,
                iconSize: 17,
                label: l10n.addPointsFillingGuide,
                semanticLabel: l10n.addPointsFillingGuide,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _FormSection(
                children: [
                  _ManualWorkLabeledField(
                    label: l10n.addPointsWorkNameLabel,
                    required: true,
                    child: TextFormField(
                      onTapOutside: dismissKeyboardOnTapOutside,
                      controller: _titleController,
                      decoration: _boxedFormDecoration(
                        hintText: l10n.addPointsWorkNameHint,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _requiredText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ManualWorkLabeledField(
                    label: l10n.addPointsOriginalTitleLabel,
                    child: TextFormField(
                      onTapOutside: dismissKeyboardOnTapOutside,
                      controller: _subtitleController,
                      decoration: _boxedFormDecoration(
                        hintText: l10n.addPointsOriginalTitleHint,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ManualWorkLabeledField(
                    label: l10n.addPointsWorkTypeLabel,
                    required: true,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: AppColors.accent.withValues(
                          alpha: 0.075,
                        ),
                        splashColor: Colors.transparent,
                      ),
                      child: DropdownButtonFormField<BangumiSubjectType>(
                        key: ValueKey(_selectedSubjectType),
                        initialValue: _selectedSubjectType,
                        decoration: _workTypeDropdownDecoration(),
                        isExpanded: true,
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        dropdownColor: AppColors.surface,
                        itemHeight: null,
                        menuMaxHeight: appScaledOverlayExtent(
                          widget.settings,
                          360,
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(LucideIcons.chevronDown, size: 20),
                        ),
                        selectedItemBuilder: (context) => [
                          for (final type in _manualWorkSubjectTypes)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(type.label),
                            ),
                        ],
                        items: [
                          for (final type in _manualWorkSubjectTypes)
                            DropdownMenuItem<BangumiSubjectType>(
                              value: type,
                              child: SizedBox(
                                height: appScaledOverlayExtent(
                                  widget.settings,
                                  48,
                                ),
                                child: AppScaledOverlayContent(
                                  settings: widget.settings,
                                  child: _ManualWorkTypeDropdownItem(
                                    type: type,
                                    selected: type == _selectedSubjectType,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        onChanged: _isSaving
                            ? null
                            : (type) {
                                if (type == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedSubjectType = type;
                                });
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ManualWorkLabeledField(
                    label: l10n.addPointsMainRegionLabel,
                    child: TextFormField(
                      onTapOutside: dismissKeyboardOnTapOutside,
                      controller: _cityController,
                      decoration: _boxedFormDecoration(
                        hintText: l10n.addPointsMainRegionHint,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _saveWork(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveWork,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.check, size: 18),
                label: Text(
                  _isSaving ? l10n.addPointsSaving : l10n.addPointsSaveWork,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredText(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return l10n.addPointsFieldRequired;
    }

    return null;
  }
}

class _ManualPointFillingGuideSheet extends StatelessWidget {
  const _ManualPointFillingGuideSheet();

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return ConstrainedBox(
      key: const ValueKey('manual-point-guide-panel'),
      constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.mapPinPlus,
                  color: AppColors.accentDark,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.addPointsPointGuideTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addPointsPointGuideIntro,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            _FillingGuideItem(
              index: 1,
              title: l10n.addPointsWorkLabel,
              badge: l10n.addPointsBadgeRequired,
              body: l10n.addPointsPointGuideWorkBody,
              example: l10n.addPointsGuideWorkExample,
            ),
            _FillingGuideItem(
              index: 2,
              title: l10n.addPointsGuideNameLocationTitle,
              badge: l10n.addPointsBadgeRequired,
              body: l10n.addPointsGuideNameLocationBody,
              example: l10n.addPointsGuideNameLocationExample,
            ),
            _FillingGuideItem(
              index: 3,
              title: l10n.addPointsGuideSceneSourceTitle,
              badge: l10n.addPointsBadgeRequired,
              body: l10n.addPointsGuideSceneSourceBody,
              example: l10n.addPointsGuideSceneSourceExample,
            ),
            _FillingGuideItem(
              index: 4,
              title: l10n.addPointsNotesLabel,
              badge: l10n.addPointsBadgeOptional,
              body: l10n.addPointsGuideNotesBody,
              example: l10n.addPointsGuideNotesExample,
            ),
            _FillingGuideItem(
              index: 5,
              title: l10n.addPointsGuideCoordinateImageTitle,
              badge: l10n.addPointsBadgeCoordinatesRequired,
              body: l10n.addPointsGuideCoordinateImageBody,
              example: '35.008900, 135.771100',
              isLast: true,
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.locateFixed,
                    size: 19,
                    color: AppColors.accentDark,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      l10n.addPointsGuideCheckMarkerTip,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        height: 1.45,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.addPointsGuideGotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualWorkFillingGuideSheet extends StatelessWidget {
  const _ManualWorkFillingGuideSheet();

  @override
  Widget build(BuildContext context) {
    final viewportLimit = MediaQuery.sizeOf(context).height * 0.72;
    final maxHeight = viewportLimit < 540 ? viewportLimit : 540.0;

    return ConstrainedBox(
      key: const ValueKey('manual-work-guide-panel'),
      constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.bookOpen,
                  color: AppColors.accentDark,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.addPointsWorkGuideTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addPointsWorkGuideIntro,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            _FillingGuideItem(
              index: 1,
              title: l10n.addPointsWorkNameLabel,
              badge: l10n.addPointsBadgeRequired,
              body: l10n.addPointsWorkGuideNameBody,
              example: l10n.addPointsGuideWorkExample,
            ),
            _FillingGuideItem(
              index: 2,
              title: l10n.addPointsOriginalTitleLabel,
              badge: l10n.addPointsBadgeOptional,
              body: l10n.addPointsWorkGuideOriginalTitleBody,
              example: 'けいおん！',
            ),
            _FillingGuideItem(
              index: 3,
              title: l10n.addPointsWorkTypeLabel,
              badge: l10n.addPointsBadgeRequired,
              body: l10n.addPointsWorkGuideTypeBody,
              example: l10n.addPointsGuideWorkTypeExample,
            ),
            _FillingGuideItem(
              index: 4,
              title: l10n.addPointsMainRegionLabel,
              badge: l10n.addPointsBadgeOptional,
              body: l10n.addPointsWorkGuideRegionBody,
              example: l10n.addPointsWorkGuideRegionExample,
              isLast: true,
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.lightbulb,
                    size: 19,
                    color: AppColors.accentDark,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      l10n.addPointsWorkGuideFooter,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        height: 1.45,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.addPointsGuideGotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FillingGuideItem extends StatelessWidget {
  const _FillingGuideItem({
    required this.index,
    required this.title,
    required this.badge,
    required this.body,
    required this.example,
    this.isLast = false,
  });

  final int index;
  final String title;
  final String badge;
  final String body;
  final String example;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 28,
                    bottom: 0,
                    child: Container(width: 2, color: AppColors.border),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: AppColors.onAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badge == l10n.addPointsBadgeRequired
                              ? AppColors.accent.withValues(alpha: 0.1)
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: badge == l10n.addPointsBadgeRequired
                                ? AppColors.accentDark
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.addPointsGuideExample(example),
                    style: TextStyle(
                      color: AppColors.accentDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualWorkTypeDropdownItem extends StatefulWidget {
  const _ManualWorkTypeDropdownItem({
    required this.type,
    required this.selected,
  });

  final BangumiSubjectType type;
  final bool selected;

  @override
  State<_ManualWorkTypeDropdownItem> createState() =>
      _ManualWorkTypeDropdownItemState();
}

class _ManualWorkTypeDropdownItemState
    extends State<_ManualWorkTypeDropdownItem> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hovered = _hovered && !widget.selected;

    return MouseRegion(
      onEnter: widget.selected ? null : (_) => setState(() => _hovered = true),
      onExit: widget.selected ? null : (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(hovered ? 14 : 8, 0, 8, 0),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(
            alpha: widget.selected ? 0.10 : (hovered ? 0.05 : 0),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(widget.type.label)),
            if (widget.selected)
              Icon(LucideIcons.checkCircle, color: AppColors.accent, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ManualWorkLabeledField extends StatelessWidget {
  const _ManualWorkLabeledField({
    required this.label,
    required this.child,
    this.required = false,
    this.prominent = false,
  });

  final String label;
  final Widget child;
  final bool required;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.redAccent),
                ),
            ],
          ),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: prominent ? 15 : 13,
            fontWeight: prominent ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _QuickManualPointDraft {
  const _QuickManualPointDraft({
    required this.work,
    required this.name,
    required this.position,
  });

  final PilgrimageWork work;
  final String name;
  final LatLng? position;
}

class _QuickManualPointFormScreen extends StatefulWidget {
  const _QuickManualPointFormScreen({
    required this.plan,
    required this.settings,
  });

  final PilgrimagePlan plan;
  final AppSettings settings;

  @override
  State<_QuickManualPointFormScreen> createState() =>
      _QuickManualPointFormScreenState();
}

class _QuickManualPointFormScreenState
    extends State<_QuickManualPointFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _latitudeFocusNode = FocusNode();
  final _longitudeFocusNode = FocusNode();
  PilgrimageWork? _selectedWork;

  @override
  void initState() {
    super.initState();
    _selectedWork = widget.plan.works.firstOrNull;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    super.dispose();
  }

  LatLng? get _position {
    final latitude = parseCoordinateComponent(
      _latitudeController.text,
      latitude: true,
    );
    final longitude = parseCoordinateComponent(
      _longitudeController.text,
      latitude: false,
    );
    if (latitude == null || longitude == null) {
      return null;
    }
    return LatLng(latitude, longitude);
  }

  LatLng get _planCenter {
    final positionedPoints = widget.plan.points
        .where((point) => point.hasCoordinate)
        .toList(growable: false);
    if (positionedPoints.isEmpty) {
      return const LatLng(35, 135);
    }
    final latitude =
        positionedPoints
            .map((point) => point.position.latitude)
            .reduce((a, b) => a + b) /
        positionedPoints.length;
    final longitude =
        positionedPoints
            .map((point) => point.position.longitude)
            .reduce((a, b) => a + b) /
        positionedPoints.length;
    return LatLng(latitude, longitude);
  }

  Future<void> _pickCoordinateFromMap() async {
    final result = await Navigator.of(context).push<LatLng>(
      appScaledMaterialPageRoute<LatLng>(
        settings: widget.settings,
        builder: (_) => _ManualPointMapPickerScreen(
          initialPosition: _position ?? _planCenter,
          settings: widget.settings,
        ),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _latitudeController.text = result.latitude.toStringAsFixed(6);
      _longitudeController.text = result.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _pasteCoordinateFromClipboard() {
    return _pasteCoordinateFromClipboardInto(
      context: context,
      latitudeController: _latitudeController,
      longitudeController: _longitudeController,
      onFilled: () => setState(() {}),
    );
  }

  Future<void> _showFillingGuide() {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: _guideDialogHeight(context, 500),
          child: AppScaledOverlayContent(
            settings: widget.settings,
            child: const _QuickManualPointFillingGuideSheet(),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    Navigator.of(context).pop(
      _QuickManualPointDraft(
        work: _selectedWork!,
        name: _nameController.text.trim(),
        position: _position,
      ),
    );
  }

  String? _validateCoordinate(String? value, {required bool latitude}) {
    final text = value?.trim() ?? '';
    final otherText = (latitude ? _longitudeController : _latitudeController)
        .text
        .trim();
    if (text.isEmpty && otherText.isEmpty) {
      return null;
    }
    if (text.isEmpty) {
      return latitude
          ? l10n.addPointsLatitudeAlsoRequired
          : l10n.addPointsLongitudeAlsoRequired;
    }
    final coordinate = parseCoordinateComponent(text, latitude: latitude);
    if (coordinate == null) {
      return latitude
          ? l10n.addPointsLatitudeInvalid
          : l10n.addPointsLongitudeInvalid;
    }
    return null;
  }

  InputDecoration _coordinateDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.42),
        fontSize: 13,
        letterSpacing: 0,
      ),
      isDense: true,
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      errorStyle: const TextStyle(fontSize: 11, height: 0.9),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(l10n.addPointsQuickManualAddPoint),
        actions: [
          TextButton(
            key: const ValueKey('quick-point-filling-guide'),
            onPressed: _showFillingGuide,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentDark,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: ResponsiveButtonContent(
              icon: LucideIcons.bookOpen,
              iconSize: 17,
              label: l10n.addPointsFillingGuide,
              semanticLabel: l10n.addPointsFillingGuide,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              l10n.addPointsAddingTo(widget.plan.name),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            _FormSection(
              children: [
                _ManualWorkLabeledField(
                  label: l10n.addPointsWorkLabel,
                  required: true,
                  prominent: true,
                  child: PilgrimageWorkDropdown(
                    works: widget.plan.works,
                    value: _selectedWork,
                    settings: widget.settings,
                    omitScrollbarInsetWhenUnscrollable: true,
                    onChanged: (work) => setState(() => _selectedWork = work),
                    validator: (work) =>
                        work == null ? l10n.addPointsSelectWorkRequired : null,
                  ),
                ),
                const SizedBox(height: 8),
                _ManualWorkLabeledField(
                  label: l10n.addPointsPointNameLabel,
                  required: true,
                  prominent: true,
                  child: TextFormField(
                    onTapOutside: dismissKeyboardOnTapOutside,
                    key: const ValueKey('quick-point-name'),
                    controller: _nameController,
                    decoration: _boxedFormDecoration(
                      hintText: l10n.addPointsPointNameHint,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: _requiredText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FormSection(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.addPointsCoordinateLabel,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text(
                      l10n.addPointsBadgeOptional,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _CoordinateLabeledField(
                        label: l10n.addPointsLatitude,
                        required: false,
                        focusNode: _latitudeFocusNode,
                        child: TextFormField(
                          onTapOutside: dismissKeyboardOnTapOutside,
                          key: const ValueKey('quick-point-latitude'),
                          controller: _latitudeController,
                          focusNode: _latitudeFocusNode,
                          decoration: _coordinateDecoration(
                            l10n.addPointsLatitudeHint,
                          ),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              _validateCoordinate(value, latitude: true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CoordinateLabeledField(
                        label: l10n.addPointsLongitude,
                        required: false,
                        focusNode: _longitudeFocusNode,
                        child: TextFormField(
                          onTapOutside: dismissKeyboardOnTapOutside,
                          key: const ValueKey('quick-point-longitude'),
                          controller: _longitudeController,
                          focusNode: _longitudeFocusNode,
                          decoration: _coordinateDecoration(
                            l10n.addPointsLongitudeHint,
                          ),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              _validateCoordinate(value, latitude: false),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('quick-point-map-picker'),
                        onPressed: _pickCoordinateFromMap,
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size.fromHeight(44),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          foregroundColor: AppColors.accent,
                          backgroundColor: AppColors.accent.withValues(
                            alpha: 0.06,
                          ),
                          side: BorderSide(
                            color: AppColors.accent.withValues(alpha: 0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: ResponsiveButtonContent(
                          icon: LucideIcons.mapPin,
                          iconSize: 19,
                          label: l10n.addPointsPickFromMap,
                          shortLabel: l10n.addPointsPickFromMapShort,
                          semanticLabel: l10n.addPointsPickFromMapSemantic,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton.outlined(
                        key: const ValueKey('quick-point-paste-coordinate'),
                        tooltip: l10n.addPointsPasteCoordinates,
                        onPressed: _pasteCoordinateFromClipboard,
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(LucideIcons.clipboardPaste),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('quick-point-submit'),
              onPressed: _submit,
              icon: const Icon(LucideIcons.check, size: 18),
              label: Text(l10n.addPointsSavePoint),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredText(String? value) {
    return (value?.trim().isEmpty ?? true) ? l10n.addPointsFieldRequired : null;
  }
}

class _QuickManualPointFillingGuideSheet extends StatelessWidget {
  const _QuickManualPointFillingGuideSheet();

  @override
  Widget build(BuildContext context) {
    final viewportLimit = MediaQuery.sizeOf(context).height * 0.72;
    final maxHeight = viewportLimit < 480 ? viewportLimit : 480.0;
    return ConstrainedBox(
      key: const ValueKey('quick-point-guide-panel'),
      constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.mapPinPlus,
                  color: AppColors.accentDark,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.addPointsQuickGuideTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addPointsQuickGuideIntro,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            _FillingGuideItem(
              index: 1,
              title: l10n.addPointsWorkLabel,
              badge: l10n.addPointsBadgeRequired,
              body: l10n.addPointsQuickGuideWorkBody,
              example: l10n.addPointsGuideWorkExample,
            ),
            _FillingGuideItem(
              index: 2,
              title: l10n.addPointsPointNameLabel,
              badge: l10n.addPointsBadgeRequired,
              body: l10n.addPointsQuickGuideNameBody,
              example: l10n.addPointsGuidePointNameExample,
            ),
            _FillingGuideItem(
              index: 3,
              title: l10n.addPointsCoordinateLabel,
              badge: l10n.addPointsBadgeOptional,
              body: l10n.addPointsQuickGuideCoordinateBody,
              example: '35.008900, 135.771100',
              isLast: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('quick-point-guide-confirm'),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.addPointsGuideGotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualPointFormScreen extends StatefulWidget {
  const _ManualPointFormScreen({
    required this.plan,
    required this.repository,
    this.settings,
    this.editingPoint,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;
  final AppSettings? settings;
  final PilgrimagePoint? editingPoint;

  @override
  State<_ManualPointFormScreen> createState() => _ManualPointFormScreenState();
}

class EditPointScreen {
  const EditPointScreen._();

  static Future<bool?> open(
    BuildContext context, {
    required PilgrimagePlan plan,
    required PilgrimageRepository repository,
    required PilgrimagePoint point,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _ManualPointFormScreen(
          plan: plan,
          repository: repository,
          editingPoint: point,
        ),
      ),
    );
  }
}

class _PendingReferenceImage {
  const _PendingReferenceImage(this.stored, this.thumbnailBytes);

  final StoredUserReferenceImage stored;
  final Uint8List thumbnailBytes;
}

class _ManualPointFormScreenState extends State<_ManualPointFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _fallbackWorkTitleController = TextEditingController();
  final _fallbackWorkSubtitleController = TextEditingController();
  final _fallbackWorkCityController = TextEditingController();
  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _episodeController = TextEditingController();
  final _referenceController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _latitudeFocusNode = FocusNode();
  final _longitudeFocusNode = FocusNode();
  final _noteController = TextEditingController();
  PilgrimageWork? _selectedWork;
  final _pendingReference = PendingReferenceLifecycle<_PendingReferenceImage>(
    delete: (image) => deleteStoredUserReferenceImage(image.stored),
    onRetain: (image) => image.stored.retain(),
  );
  StoredUserReferenceImage? get _pendingReferenceImage =>
      _pendingReference.current?.stored;
  bool get _isSaving => _pendingReference.isSaving;
  bool get _isBusy => _pendingReference.isBusy || _didSavePoint || _isExiting;
  bool _didSavePoint = false;
  bool _isExiting = false;
  late final _draftPointId = 'manual-${DateTime.now().microsecondsSinceEpoch}';
  bool _hasUncertainNewPointSave = false;

  PilgrimagePoint? get _editingPoint => widget.editingPoint;

  bool get _isEditing => _editingPoint != null;

  List<PilgrimageWork> get _workOptions {
    final works = [...widget.plan.works];
    final selectedWork = _selectedWork;
    if (selectedWork != null &&
        !works.any((work) => work.id == selectedWork.id)) {
      works.add(selectedWork);
    }
    return works;
  }

  @override
  void initState() {
    super.initState();
    final editingPoint = _editingPoint;
    _selectedWork = editingPoint == null
        ? widget.plan.works.firstOrNull
        : widget.plan.works.firstWhere(
            (work) => work.id == editingPoint.work.id,
            orElse: () => editingPoint.work,
          );
    if (editingPoint != null) {
      _nameController.text = editingPoint.name;
      _subtitleController.text = editingPoint.subtitle;
      _episodeController.text = editingPoint.episodeLabel;
      _referenceController.text = editingPoint.referenceLabel;
      if (editingPoint.hasCoordinate) {
        _latitudeController.text = editingPoint.position.latitude
            .toStringAsFixed(6);
        _longitudeController.text = editingPoint.position.longitude
            .toStringAsFixed(6);
      }
      _noteController.text = editingPoint.note ?? '';
    }
  }

  @override
  void dispose() {
    _pendingReference.dispose();
    _fallbackWorkTitleController.dispose();
    _fallbackWorkSubtitleController.dispose();
    _fallbackWorkCityController.dispose();
    _nameController.dispose();
    _subtitleController.dispose();
    _episodeController.dispose();
    _referenceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _savePoint() async {
    if (_isBusy || !mounted || _hasUncertainNewPointSave) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || !_pendingReference.beginSave()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {});

    var persistenceStarted = false;
    try {
      final now = DateTime.now();
      final editingPoint = _editingPoint;
      final work = _selectedWork ?? _fallbackWork(now);
      final pointId = editingPoint?.id ?? _draftPointId;
      final storedReference = _pendingReferenceImage;
      final latitudeText = _latitudeController.text.trim();
      final longitudeText = _longitudeController.text.trim();
      final position = latitudeText.isEmpty && longitudeText.isEmpty
          ? PilgrimagePoint.pendingPosition
          : LatLng(
              parseCoordinateComponent(latitudeText, latitude: true)!,
              parseCoordinateComponent(longitudeText, latitude: false)!,
            );
      final noteText = _noteController.text.trim();
      final point = editingPoint == null
          ? PilgrimagePoint(
              id: pointId,
              work: work,
              name: _nameController.text.trim(),
              subtitle: _subtitleController.text.trim(),
              position: position,
              episodeLabel: _episodeController.text.trim(),
              referenceLabel: _referenceController.text.trim(),
              referenceThumbnailPath: storedReference?.thumbnailPath,
              referenceFullImagePath: storedReference?.fullImagePath,
              note: noteText.isEmpty ? null : noteText,
            )
          : editingPoint.copyWith(
              work: work,
              name: _nameController.text.trim(),
              subtitle: _subtitleController.text.trim(),
              position: position,
              episodeLabel: _episodeController.text.trim(),
              referenceLabel: _referenceController.text.trim(),
              referenceThumbnailPath:
                  storedReference?.thumbnailPath ??
                  editingPoint.referenceThumbnailPath,
              referenceFullImagePath:
                  storedReference?.fullImagePath ??
                  editingPoint.referenceFullImagePath,
              referenceImageUrl: storedReference == null
                  ? editingPoint.referenceImageUrl
                  : null,
              note: noteText.isEmpty ? null : noteText,
            );

      _pendingReference.beginPersistence();
      persistenceStarted = true;
      if (editingPoint == null) {
        await widget.repository.addPointToPlan(
          planId: widget.plan.id,
          point: point,
        );
      } else {
        await updatePointReclaimingFiles(
          repository: widget.repository,
          planId: widget.plan.id,
          point: point,
          previous: editingPoint,
        );
      }
      _pendingReference.finishPersistence(succeeded: true);
      _didSavePoint = true;
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      _pendingReference.finishPersistence(succeeded: false);
      if (persistenceStarted && !_isEditing) {
        _hasUncertainNewPointSave = true;
      }
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: _hasUncertainNewPointSave
            ? l10n.addPointsSaveUnconfirmed
            : l10n.addPointsPointSaveFailed,
      );
    } finally {
      _pendingReference.endSave();
      if (mounted) {
        setState(() {});
      }
    }
  }

  PilgrimageWork _fallbackWork(DateTime now) {
    final title = _fallbackWorkTitleController.text.trim();
    final subtitle = _fallbackWorkSubtitleController.text.trim();
    final city = _fallbackWorkCityController.text.trim();
    return PilgrimageWork(
      id: 'manual-work-${now.microsecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      city: city.isEmpty ? widget.plan.area : city,
      source: WorkSource.manual,
    );
  }

  Future<void> _pickReferenceImage() async {
    if (_isBusy || !mounted) return;
    FocusScope.of(context).unfocus();
    final selection = _pendingReference.select(() async {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null || _pendingReference.isDisposed) return null;
      final pointId = _editingPoint?.id ?? _draftPointId;
      final stored = await storeUserReferenceImage(
        sourcePath: picked.path,
        pointId: pointId,
      );
      if (stored == null) throw StateError('Reference image unavailable');
      try {
        // Keep the preview independent of draft-file cleanup, including reads
        // that would otherwise outlive the route's reverse transition.
        final Uint8List thumbnailBytes;
        if (isDesktopAssetPath(stored.thumbnailPath)) {
          final dataUrl = await loadDesktopAssetDataUrl(stored.thumbnailPath);
          if (dataUrl == null) {
            throw StateError('Reference thumbnail unavailable');
          }
          thumbnailBytes = base64Decode(
            dataUrl.substring(dataUrl.indexOf(',') + 1),
          );
        } else {
          thumbnailBytes = await XFile(stored.thumbnailPath).readAsBytes();
        }
        return _PendingReferenceImage(stored, thumbnailBytes);
      } catch (_) {
        await deleteStoredUserReferenceImage(stored);
        rethrow;
      }
    });
    setState(() {});
    try {
      await selection;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.error,
        title: l10n.addPointsReferenceImageReadFailed,
      );
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickCoordinateFromMap() async {
    if (_isBusy || !mounted) return;
    final settings = await widget.repository.loadAppSettings();
    if (!mounted || _isBusy) {
      return;
    }

    final initialPosition = _currentPositionInput() ?? _planCenter;
    final picked = await Navigator.of(context).push<LatLng>(
      appScaledMaterialPageRoute<LatLng>(
        settings: settings,
        builder: (_) => _ManualPointMapPickerScreen(
          initialPosition: initialPosition,
          settings: settings,
        ),
      ),
    );
    if (picked == null || !mounted || _isBusy) {
      return;
    }

    setState(() {
      _latitudeController.text = picked.latitude.toStringAsFixed(6);
      _longitudeController.text = picked.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _pasteCoordinateFromClipboard() {
    return _pasteCoordinateFromClipboardInto(
      context: context,
      latitudeController: _latitudeController,
      longitudeController: _longitudeController,
      onFilled: () => setState(() {}),
      canApply: () => !_isBusy,
    );
  }

  void _removeReferenceImage() {
    if (_isBusy || !mounted) return;
    setState(_pendingReference.remove);
  }

  void _requestExit() {
    if (!mounted || _isBusy) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    setState(() => _isExiting = true);
    Navigator.of(context).pop(false);
  }

  LatLng? _currentPositionInput() {
    final latitude = parseCoordinateComponent(
      _latitudeController.text,
      latitude: true,
    );
    final longitude = parseCoordinateComponent(
      _longitudeController.text,
      latitude: false,
    );
    if (latitude == null || longitude == null) {
      return null;
    }
    return LatLng(latitude, longitude);
  }

  LatLng get _planCenter {
    final positionedPoints = widget.plan.points
        .where((point) => point.hasCoordinate)
        .toList(growable: false);
    if (positionedPoints.isEmpty) {
      return const LatLng(35, 135);
    }
    final latitude =
        positionedPoints
            .map((point) => point.position.latitude)
            .reduce((a, b) => a + b) /
        positionedPoints.length;
    final longitude =
        positionedPoints
            .map((point) => point.position.longitude)
            .reduce((a, b) => a + b) /
        positionedPoints.length;
    return LatLng(latitude, longitude);
  }

  Future<void> _showPointFillingGuide() {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: AppScaledOverlayContent(
          settings: widget.settings ?? const AppSettings(),
          child: const _ManualPointFillingGuideSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workOptions = _workOptions;
    final hasPlanWorks = workOptions.isNotEmpty;
    final editingPoint = _editingPoint;
    final existingReferenceImageUrl =
        editingPoint != null && hasRemoteReferenceImage(editingPoint)
        ? editingPoint.referenceImageUrl
        : null;

    return PopScope(
      canPop: !_isBusy,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _isExiting = true;
          return;
        }
        _requestExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? l10n.addPointsEditPoint : l10n.addPointsManualAddPoint,
          ),
          leading: AppBackButton(onPressed: _requestExit),
          actions: [
            TextButton(
              key: const ValueKey('manual-point-filling-guide'),
              onPressed: _isBusy ? null : _showPointFillingGuide,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentDark,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: ResponsiveButtonContent(
                icon: LucideIcons.bookOpen,
                iconSize: 17,
                label: l10n.addPointsFillingGuide,
                semanticLabel: l10n.addPointsFillingGuide,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                _isEditing
                    ? l10n.addPointsEditing(editingPoint!.name)
                    : l10n.addPointsAddingTo(widget.plan.name),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              _FormSection(
                children: [
                  if (hasPlanWorks)
                    _ManualWorkLabeledField(
                      label: l10n.addPointsWorkLabel,
                      required: true,
                      prominent: true,
                      child: PilgrimageWorkDropdown(
                        works: workOptions,
                        value: _selectedWork,
                        settings: widget.settings ?? const AppSettings(),
                        omitScrollbarInsetWhenUnscrollable: true,
                        onChanged: _isBusy
                            ? null
                            : (work) {
                                setState(() {
                                  _selectedWork = work;
                                });
                              },
                        validator: (work) => work == null
                            ? l10n.addPointsSelectWorkRequired
                            : null,
                      ),
                    )
                  else ...[
                    _ManualWorkLabeledField(
                      label: l10n.addPointsWorkNameLabel,
                      required: true,
                      prominent: true,
                      child: TextFormField(
                        onTapOutside: dismissKeyboardOnTapOutside,
                        controller: _fallbackWorkTitleController,
                        enabled: !_isBusy,
                        decoration: _boxedFormDecoration(
                          hintText: l10n.addPointsWorkNameHint,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _requiredText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ManualWorkLabeledField(
                      label: l10n.addPointsOriginalTitleLabel,
                      prominent: true,
                      child: TextFormField(
                        onTapOutside: dismissKeyboardOnTapOutside,
                        controller: _fallbackWorkSubtitleController,
                        enabled: !_isBusy,
                        decoration: _boxedFormDecoration(
                          hintText: l10n.addPointsOriginalTitleHint,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ManualWorkLabeledField(
                      label: l10n.addPointsMainRegionLabel,
                      prominent: true,
                      child: TextFormField(
                        onTapOutside: dismissKeyboardOnTapOutside,
                        controller: _fallbackWorkCityController,
                        enabled: !_isBusy,
                        decoration: _boxedFormDecoration(
                          hintText: l10n.addPointsMainRegionHint,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _FormSection(
                children: [
                  _ManualWorkLabeledField(
                    label: l10n.addPointsPointNameLabel,
                    required: true,
                    prominent: true,
                    child: TextFormField(
                      onTapOutside: dismissKeyboardOnTapOutside,
                      key: const ValueKey('point-form-name'),
                      enabled: !_isBusy,
                      controller: _nameController,
                      decoration: _boxedFormDecoration(
                        hintText: l10n.addPointsPointNameHint,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _requiredText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ManualWorkLabeledField(
                    label: l10n.addPointsLocationNoteLabel,
                    required: true,
                    prominent: true,
                    child: TextFormField(
                      onTapOutside: dismissKeyboardOnTapOutside,
                      controller: _subtitleController,
                      enabled: !_isBusy,
                      decoration: _boxedFormDecoration(
                        hintText: l10n.addPointsLocationNoteHint,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _requiredText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ManualWorkLabeledField(
                    label: l10n.addPointsSceneTagLabel,
                    required: true,
                    prominent: true,
                    child: TextFormField(
                      onTapOutside: dismissKeyboardOnTapOutside,
                      controller: _episodeController,
                      enabled: !_isBusy,
                      decoration: _boxedFormDecoration(
                        hintText: l10n.addPointsSceneTagHint,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _requiredText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ManualWorkLabeledField(
                    label: l10n.addPointsReferenceSourceLabel,
                    required: true,
                    prominent: true,
                    child: TextFormField(
                      onTapOutside: dismissKeyboardOnTapOutside,
                      controller: _referenceController,
                      enabled: !_isBusy,
                      decoration: _boxedFormDecoration(
                        hintText: l10n.addPointsReferenceSourceHint,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _requiredText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ManualWorkLabeledField(
                    label: l10n.addPointsNotesLabel,
                    prominent: true,
                    child: TextFormField(
                      onTapOutside: dismissKeyboardOnTapOutside,
                      key: const ValueKey('point-form-note'),
                      enabled: !_isBusy,
                      controller: _noteController,
                      decoration: _boxedFormDecoration(
                        hintText: l10n.addPointsNotesHint,
                      ),
                      minLines: 4,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FormSection(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.addPointsCoordinateLabel,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _CoordinateLabeledField(
                          label: l10n.addPointsLatitude,
                          focusNode: _latitudeFocusNode,
                          required: !_canKeepCoordinatePending,
                          child: TextFormField(
                            onTapOutside: dismissKeyboardOnTapOutside,
                            key: const ValueKey('point-form-latitude'),
                            enabled: !_isBusy,
                            controller: _latitudeController,
                            focusNode: _latitudeFocusNode,
                            decoration: _coordinateInputDecoration(
                              hintText: l10n.addPointsLatitudeHint,
                            ),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: _validateLatitude,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CoordinateLabeledField(
                          label: l10n.addPointsLongitude,
                          focusNode: _longitudeFocusNode,
                          required: !_canKeepCoordinatePending,
                          child: TextFormField(
                            onTapOutside: dismissKeyboardOnTapOutside,
                            key: const ValueKey('point-form-longitude'),
                            enabled: !_isBusy,
                            controller: _longitudeController,
                            focusNode: _longitudeFocusNode,
                            decoration: _coordinateInputDecoration(
                              hintText: l10n.addPointsLongitudeHint,
                            ),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            textInputAction: TextInputAction.done,
                            validator: _validateLongitude,
                            onFieldSubmitted: (_) => _savePoint(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const ValueKey('point-form-map-picker'),
                          onPressed: _isBusy ? null : _pickCoordinateFromMap,
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size.fromHeight(44),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            foregroundColor: AppColors.accent,
                            backgroundColor: AppColors.accent.withValues(
                              alpha: 0.06,
                            ),
                            side: BorderSide(
                              color: AppColors.accent.withValues(alpha: 0.35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: ResponsiveButtonContent(
                            icon: LucideIcons.mapPin,
                            iconSize: 19,
                            label: l10n.addPointsPickFromMap,
                            shortLabel: l10n.addPointsPickFromMapShort,
                            semanticLabel: l10n.addPointsPickFromMapSemantic,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton.outlined(
                          key: const ValueKey('point-form-paste-coordinate'),
                          tooltip: l10n.addPointsPasteCoordinates,
                          onPressed: _isBusy
                              ? null
                              : _pasteCoordinateFromClipboard,
                          style: IconButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(LucideIcons.clipboardPaste),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ManualReferenceImagePicker(
                thumbnailBytes: _pendingReference.current?.thumbnailBytes,
                previewEnabled: !_isBusy,
                localPath:
                    _pendingReferenceImage?.thumbnailPath ??
                    editingPoint?.referenceThumbnailPath ??
                    editingPoint?.referenceFullImagePath,
                fullImagePath:
                    _pendingReferenceImage?.fullImagePath ??
                    editingPoint?.referenceFullImagePath,
                imageUrl: _pendingReferenceImage == null
                    ? existingReferenceImageUrl
                    : null,
                hasPendingSelection: _pendingReferenceImage != null,
                hasExistingImage:
                    editingPoint?.referenceThumbnailPath != null ||
                    editingPoint?.referenceFullImagePath != null ||
                    existingReferenceImageUrl != null,
                onPick: _isBusy ? null : _pickReferenceImage,
                onRemove: _isBusy || _pendingReferenceImage == null
                    ? null
                    : _removeReferenceImage,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('point-form-save'),
                onPressed: _isBusy || _hasUncertainNewPointSave
                    ? null
                    : _savePoint,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.check, size: 18),
                label: Text(
                  _isSaving
                      ? l10n.addPointsSaving
                      : (_isEditing
                            ? l10n.addPointsSaveChanges
                            : l10n.addPointsSavePoint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredText(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return l10n.addPointsFieldRequired;
    }

    return null;
  }

  InputDecoration _coordinateInputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.42),
        fontSize: 13,
        letterSpacing: 0,
      ),
      isDense: true,
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      errorStyle: const TextStyle(fontSize: 11, height: 0.9),
    );
  }

  String? _validateLatitude(String? value) {
    return _validateCoordinate(
      value,
      otherValue: _longitudeController.text,
      latitude: true,
      emptyMessage: l10n.addPointsLatitudeRequired,
    );
  }

  String? _validateLongitude(String? value) {
    return _validateCoordinate(
      value,
      otherValue: _latitudeController.text,
      latitude: false,
      emptyMessage: l10n.addPointsLongitudeRequired,
    );
  }

  String? _validateCoordinate(
    String? value, {
    required String otherValue,
    required bool latitude,
    required String emptyMessage,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      if (_canKeepCoordinatePending && otherValue.trim().isEmpty) {
        return null;
      }
      return emptyMessage;
    }

    final coordinate = parseCoordinateComponent(text, latitude: latitude);
    if (coordinate == null) {
      return l10n.addPointsCoordinateInvalid;
    }

    return null;
  }

  bool get _canKeepCoordinatePending =>
      _editingPoint != null && !_editingPoint!.hasCoordinate;
}

class _CoordinateLabeledField extends StatelessWidget {
  const _CoordinateLabeledField({
    required this.label,
    required this.focusNode,
    required this.child,
    this.required = true,
  });

  final String label;
  final FocusNode focusNode;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        final focused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: focused ? AppColors.accent : AppColors.border,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: label),
                    if (required)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                  ],
                ),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              child!,
            ],
          ),
        );
      },
      child: child,
    );
  }
}

class _ManualPointMapPickerScreen extends StatefulWidget {
  const _ManualPointMapPickerScreen({
    required this.initialPosition,
    required this.settings,
  });

  final LatLng initialPosition;
  final AppSettings settings;

  @override
  State<_ManualPointMapPickerScreen> createState() =>
      _ManualPointMapPickerScreenState();
}

class _ManualPointMapPickerScreenState
    extends State<_ManualPointMapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  var _isPickMode = false;

  @override
  Widget build(BuildContext context) {
    final selectedPosition = _selectedPosition;

    return Scaffold(
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(l10n.addPointsPickCoordinateTitle),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialPosition,
              initialZoom: 15,
              minZoom: 4,
              maxZoom: widget.settings.mapMaxZoom.toDouble(),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, latLng) {
                if (!_isPickMode) {
                  return;
                }
                setState(() {
                  _selectedPosition = latLng;
                });
              },
            ),
            children: [
              configuredMapTileLayer(widget.settings),
              MarkerLayer(
                markers: [
                  if (selectedPosition != null)
                    Marker(
                      point: selectedPosition,
                      width: scaledMapMarkerDimension(
                        48,
                        widget.settings.mapMarkerScale,
                      ),
                      height: scaledMapMarkerDimension(
                        48,
                        widget.settings.mapMarkerScale,
                      ),
                      child: ScaledMapMarker(
                        baseWidth: 48,
                        baseHeight: 48,
                        scale: widget.settings.mapMarkerScale,
                        child: const _ManualPointPositionMarker(),
                      ),
                    ),
                ],
              ),
              configuredMapAttribution(widget.settings),
            ],
          ),
          if (_isPickMode)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  setState(() {
                    _selectedPosition = _mapController.camera.offsetToCrs(
                      details.localPosition,
                    );
                  });
                },
              ),
            ),
          Positioned(
            right: 12,
            top: 12,
            child: SafeArea(
              bottom: false,
              child: _MapToolButton(
                tooltip: _isPickMode
                    ? l10n.addPointsExitMapPick
                    : l10n.addPointsStartMapPick,
                icon: LucideIcons.mousePointerClick,
                selected: _isPickMode,
                onTap: () {
                  setState(() {
                    _isPickMode = !_isPickMode;
                  });
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _ManualPointSelectionCard(
              position: selectedPosition,
              pickMode: _isPickMode,
              onSave: selectedPosition == null
                  ? null
                  : () => Navigator.of(context).pop(selectedPosition),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualPointPositionMarker extends StatelessWidget {
  const _ManualPointPositionMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MapColors.accent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Icon(LucideIcons.mapPinPlus, color: MapColors.onAccent),
    );
  }
}

class _MapToolButton extends StatelessWidget {
  const _MapToolButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    required this.selected,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon),
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }
}

class _ManualPointSelectionCard extends StatelessWidget {
  const _ManualPointSelectionCard({
    required this.position,
    required this.pickMode,
    required this.onSave,
  });

  final LatLng? position;
  final bool pickMode;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final position = this.position;
    final subtitle = position == null
        ? (pickMode ? l10n.addPointsMapPickHint : l10n.addPointsMapPickIdleHint)
        : l10n.addPointsMapAdjustHint(
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          );

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.mapPinPlus, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addPointsMapPickTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: onSave, child: Text(l10n.addPointsUse)),
        ],
      ),
    );
  }
}

class _LinkedWorksPanel extends StatelessWidget {
  const _LinkedWorksPanel({
    required this.plan,
    required this.onManage,
    required this.onBangumi,
    required this.onManual,
  });

  final PilgrimagePlan? plan;
  final VoidCallback? onManage;
  final VoidCallback? onBangumi;
  final VoidCallback? onManual;

  @override
  Widget build(BuildContext context) {
    final works = plan?.works ?? const <PilgrimageWork>[];
    final pointCount = plan?.points.length ?? 0;
    final visibleWorks = works.take(5).toList(growable: false);
    final remainingCount = works.length - visibleWorks.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('add-points-work-manager'),
              onTap: onManage,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.addPointsLinkedWorks,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.addPointsLinkedWorksSummary(
                                  works.length,
                                  pointCount,
                                ),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.addPointsManageWorks,
                              style: TextStyle(
                                color: AppColors.accentDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              LucideIcons.chevronRight,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (works.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.addPointsNoLinkedWorks,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 94,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            visibleWorks.length + (remainingCount > 0 ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          if (index == visibleWorks.length) {
                            return _MoreWorksIndicator(count: remainingCount);
                          }
                          return _LinkedWorkPreview(work: visibleWorks[index]);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.55)),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _WorkCreationAction(
                      key: const ValueKey('add-points-bangumi-work'),
                      icon: LucideIcons.search,
                      title: l10n.addPointsAddFromBangumi,
                      subtitle: l10n.addPointsAddFromBangumiSubtitle,
                      onTap: onBangumi,
                    ),
                  ),
                  VerticalDivider(
                    width: 9,
                    indent: 8,
                    endIndent: 8,
                    thickness: 1,
                    color: AppColors.border.withValues(alpha: 0.55),
                  ),
                  Expanded(
                    child: _WorkCreationAction(
                      key: const ValueKey('add-points-manual-work'),
                      icon: LucideIcons.plus,
                      title: l10n.addPointsManualAddWork,
                      subtitle: l10n.addPointsManualAddWorkSubtitle,
                      onTap: onManual,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedWorkPreview extends StatelessWidget {
  const _LinkedWorkPreview({required this.work});

  final PilgrimageWork work;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PilgrimageWorkCover(work: work, width: 56, height: 60),
          const SizedBox(height: 4),
          Text(
            work.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreWorksIndicator extends StatelessWidget {
  const _MoreWorksIndicator({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 40,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(top: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Text(
            '+$count',
            style: TextStyle(
              color: AppColors.accentDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkCreationAction extends StatelessWidget {
  const _WorkCreationAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    ),
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

class _ManualReferenceImagePicker extends StatelessWidget {
  const _ManualReferenceImagePicker({
    required this.thumbnailBytes,
    required this.previewEnabled,
    required this.localPath,
    required this.fullImagePath,
    required this.imageUrl,
    required this.hasPendingSelection,
    required this.hasExistingImage,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? thumbnailBytes;
  final bool previewEnabled;
  final String? localPath;
  final String? fullImagePath;
  final String? imageUrl;
  final bool hasPendingSelection;
  final bool hasExistingImage;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = hasPendingSelection || hasExistingImage;
    final previewPath = fullImagePath ?? (imageUrl == null ? localPath : null);
    final canPreview =
        previewEnabled && (previewPath != null || imageUrl != null);
    final placeholder = Icon(LucideIcons.image, color: AppColors.textSecondary);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tooltip(
              message: canPreview
                  ? l10n.addPointsViewFullImage
                  : l10n.addPointsNoReferenceImage,
              child: GestureDetector(
                onTap: canPreview
                    ? () => ImageViewerScreen.show(
                        context,
                        filePath: previewPath,
                        imageUrl: imageUrl,
                      )
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 104,
                    color: AppColors.surfaceMuted,
                    child: thumbnailBytes != null
                        ? Image.memory(
                            thumbnailBytes!,
                            key: const ValueKey('manual-reference-preview'),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => placeholder,
                          )
                        : ReferenceThumbnail(
                            localPath: localPath,
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: placeholder,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.addPointsReferenceImageLabel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasPendingSelection
                        ? l10n.addPointsReferenceImagePending
                        : hasExistingImage
                        ? l10n.addPointsReferenceImageCurrent
                        : l10n.addPointsReferenceImageOptional,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onPick,
                        icon: const Icon(LucideIcons.images, size: 18),
                        label: Text(
                          hasImage
                              ? l10n.addPointsReselectImage
                              : l10n.addPointsUploadReferenceImage,
                        ),
                      ),
                      if (hasPendingSelection)
                        TextButton.icon(
                          onPressed: onRemove,
                          icon: const Icon(LucideIcons.x, size: 18),
                          label: Text(l10n.addPointsRemoveImage),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkResultCard extends StatefulWidget {
  const _WorkResultCard({
    required this.work,
    required this.added,
    required this.disabled,
    required this.onAdd,
    this.actionLabel,
  });

  final PilgrimageWork work;
  final bool added;
  final bool disabled;
  final VoidCallback onAdd;
  final String? actionLabel;

  @override
  State<_WorkResultCard> createState() => _WorkResultCardState();
}

class _WorkResultCardState extends State<_WorkResultCard> {
  var _expanded = false;
  var _titleExpanded = false;

  @override
  Widget build(BuildContext context) {
    final work = widget.work;
    final subtitle = work.displaySubtitle;
    final showSubtitle = subtitle.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          PilgrimageWorkCover(work: work),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _titleExpanded = !_titleExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      work.title,
                      maxLines: _titleExpanded ? null : 2,
                      overflow: _titleExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                if (showSubtitle)
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        subtitle,
                        maxLines: _expanded ? null : 1,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                if (work.displayBangumiSubjectType != null) ...[
                  const SizedBox(height: 6),
                  _SubjectTypePill(type: work.displayBangumiSubjectType!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (widget.added)
            FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(88, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                disabledBackgroundColor: AppColors.accent.withValues(
                  alpha: 0.10,
                ),
                disabledForegroundColor: AppColors.accentDark,
              ),
              child: Text(l10n.addPointsAdded),
            )
          else
            OutlinedButton(
              onPressed: widget.disabled ? null : widget.onAdd,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(88, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text(widget.actionLabel ?? l10n.addPointsAdd),
            ),
        ],
      ),
    );
  }
}

class _SubjectTypePill extends StatelessWidget {
  const _SubjectTypePill({required this.type});

  final BangumiSubjectType type;

  @override
  Widget build(BuildContext context) {
    return _InfoPill(label: type.label);
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BangumiSearchHintContent extends StatelessWidget {
  const _BangumiSearchHintContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(LucideIcons.search, color: AppColors.accent, size: 17),
            const SizedBox(width: 8),
            Text(
              l10n.addPointsSearchHelpTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 25),
          child: Text(
            l10n.addPointsSearchHelpBody,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ),
        // Bangumi needs a route out of mainland China; elsewhere it just works.
        if (l10n.localeName.startsWith('zh')) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    LucideIcons.info,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.addPointsBangumiNetworkNote,
                    style: TextStyle(
                      color: AppColors.accentDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _FindSpotsPanel extends StatelessWidget {
  const _FindSpotsPanel({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: const ValueKey('add-points-anitabi-map'),
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.32)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.map,
                            color: AppColors.accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    l10n.addPointsFindSpots,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l10n.addPointsRecommended,
                                      style: TextStyle(
                                        color: AppColors.accentDark,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                l10n.addPointsFindSpotsSubtitle,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          color: enabled
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
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

class _AddPointPanel extends StatelessWidget {
  const _AddPointPanel({
    required this.manualEnabled,
    required this.quickManualEnabled,
    required this.onManual,
    required this.onQuickManual,
  });

  final bool manualEnabled;
  final bool quickManualEnabled;
  final VoidCallback? onManual;
  final VoidCallback? onQuickManual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  l10n.addPointsOwnSpotsSection,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          _PointCreationAction(
            key: const ValueKey('add-points-quick-manual-point'),
            icon: LucideIcons.mapPinPlus,
            title: l10n.addPointsQuickManualAddPoint,
            subtitle: quickManualEnabled
                ? l10n.addPointsQuickManualSubtitle
                : l10n.addPointsAddWorkFirst,
            enabled: quickManualEnabled,
            onTap: onQuickManual,
          ),
          Divider(
            height: 1,
            indent: 12,
            endIndent: 12,
            color: AppColors.border.withValues(alpha: 0.60),
          ),
          _PointCreationAction(
            key: const ValueKey('add-points-manual-point'),
            icon: LucideIcons.mapPinPen,
            title: l10n.addPointsManualAddPoint,
            subtitle: l10n.addPointsManualAddPointSubtitle,
            enabled: manualEnabled,
            onTap: onManual,
          ),
        ],
      ),
    );
  }
}

class _PointCreationAction extends StatelessWidget {
  const _PointCreationAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: enabled ? Colors.transparent : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(7),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(7),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: enabled
                          ? AppColors.accent.withValues(alpha: 0.08)
                          : AppColors.border.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: enabled
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                  color: enabled
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(
                              alpha: enabled ? 1 : 0.65,
                            ),
                            fontSize: 13,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: enabled ? AppColors.accent : AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
