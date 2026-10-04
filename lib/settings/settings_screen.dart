import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../app_version.dart';
import '../camera_reference/camera_zoom_capabilities.dart';
import '../data/pilgrimage_repository.dart';
import '../data/reference_cache_cleanup.dart';
import '../data/valhalla_service_config.dart';
import '../data/anitabi_endpoint_sync.dart';
import '../data/anitabi_remote_state.dart';
import '../data/anitabi_service_config.dart';
import '../data/public_http.dart';
import '../desktop/tauri_bridge.dart';
import '../map/map_tile_config.dart';
import '../map/valhalla_route_client.dart';
import '../plan/pilgrimage_models.dart';
import '../records/comparison_export_config.dart';
import 'app_settings_updater.dart';
import '../records/comparison_export_config_editor.dart';
import '../records/comparison_export_config_storage_stub.dart'
    if (dart.library.io) '../records/comparison_export_config_storage_io.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_scaled_route.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/constrained_menu_anchor.dart';
import '../widgets/copyable_text.dart';
import '../widgets/input_dialog.dart';
import '../widgets/responsive_button.dart';
import '../widgets/snackbar_helper.dart';
import 'privacy_policy_screen.dart';

bool get _showCacheCleanupSettings => isReferenceCacheCleanupSupported;
bool get _showDebugPhotoLocationSettings => kIsWeb;
bool get _shouldShowMobileGallerySettings {
  if (kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

bool get _shouldShowPhotoLocationSettings =>
    kDebugMode ||
    _showDebugPhotoLocationSettings ||
    _shouldShowMobileGallerySettings;

/// Saves changed settings; resolves to false when they could not be stored
/// (the caller then shows the previous values again).
typedef SettingsChanged = Future<bool> Function(AppSettings settings);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.settings,
    required this.repository,
    required this.onChanged,
    super.key,
  });

  final AppSettings settings;
  final PilgrimageRepository repository;
  final SettingsChanged onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CameraZoomCapabilities _zoomCapabilities = CameraZoomCapabilities.fallback;
  DesktopLauncherInfo? _desktopLauncherInfo;
  String? _appVersionLabel;
  var _desktopLauncherLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadZoomCapabilities();
    _loadAppVersionLabel();
    if (_shouldShowDesktopSection) {
      _loadDesktopLauncherInfo();
    }
  }

  Future<void> _loadZoomCapabilities() async {
    final capabilities = await CameraZoomCapabilities.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _zoomCapabilities = capabilities;
    });
  }

  Future<void> _loadDesktopLauncherInfo() async {
    final info = await loadDesktopLauncherInfo();
    if (!mounted) {
      return;
    }

    setState(() {
      _desktopLauncherInfo = info;
      _desktopLauncherLoaded = true;
    });
  }

  Future<void> _loadAppVersionLabel() async {
    final label = await loadAppVersionLabel();
    if (!mounted) {
      return;
    }

    setState(() {
      _appVersionLabel = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        key: const ValueKey('settings-app-bar'),
        toolbarHeight: AppTheme.appBarHeight,
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            key: const ValueKey('settings-reset-button'),
            tooltip: l10n.settingsResetTitle,
            onPressed: _confirmResetSettings,
            icon: const Icon(LucideIcons.rotateCcw),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SettingsCard(
            key: const ValueKey('settings-appearance-card'),
            header: _SettingsCardHeader(
              icon: LucideIcons.palette,
              title: l10n.settingsAppearanceTitle,
              subtitle: l10n.settingsAppearanceSubtitle,
              onTap: () => _pushDetail(
                _AppearanceSettingsPage(
                  settings: settings,
                  onChanged: widget.onChanged,
                ),
              ),
            ),
            children: [
              _SummaryGrid(
                children: [
                  _SummaryTile(
                    icon: LucideIcons.circle,
                    title: l10n.settingsThemeColor,
                    value: settings.themePalette.label,
                    swatch: _ThemeSwatch(
                      palette: settings.themePalette,
                      customColorValue: settings.customThemeColorValue,
                    ),
                    onTap: () => _pushDetail(
                      _AppearanceSettingsPage(
                        settings: settings,
                        onChanged: widget.onChanged,
                      ),
                    ),
                  ),
                  _SummaryTile(
                    icon: LucideIcons.moon,
                    title: l10n.settingsThemeMode,
                    value: settings.themeMode.label,
                    onTap: () => _pushDetail(
                      _AppearanceSettingsPage(
                        settings: settings,
                        onChanged: widget.onChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            header: _SettingsCardHeader(
              icon: LucideIcons.camera,
              title: l10n.settingsCameraTitle,
              subtitle: l10n.settingsCameraSubtitle,
              onTap: () => _pushDetail(
                _CameraSettingsPage(
                  settings: settings,
                  onChanged: widget.onChanged,
                  zoomCapabilities: _zoomCapabilities,
                ),
              ),
            ),
            children: [
              _SummaryGrid(
                children: [
                  _SummaryTile(
                    icon: LucideIcons.crop,
                    title: l10n.settingsCaptureAspectRatio,
                    value: settings.cameraCaptureAspectRatio.label,
                    onTap: () => _pushDetail(
                      _CameraSettingsPage(
                        settings: settings,
                        onChanged: widget.onChanged,
                        zoomCapabilities: _zoomCapabilities,
                      ),
                    ),
                  ),
                  _SummaryTile(
                    icon: LucideIcons.panelRight,
                    title: l10n.settingsCameraZoom,
                    value:
                        '${settings.cameraMinZoom.toStringAsFixed(1)}x-${settings.cameraMaxZoom.toStringAsFixed(1)}x',
                    onTap: () => _pushDetail(
                      _CameraSettingsPage(
                        settings: settings,
                        onChanged: widget.onChanged,
                        zoomCapabilities: _zoomCapabilities,
                      ),
                    ),
                  ),
                ],
              ),
              if (_shouldShowMobileGallerySettings)
                _SummarySwitchTile(
                  icon: LucideIcons.cloudUpload,
                  title: l10n.settingsPhotoBackup,
                  subtitle: l10n.settingsSavePhotoToGallery,
                  value: settings.saveVisitPhotoToGallery,
                  onChanged: (value) {
                    widget.onChanged(
                      settings.copyWith(saveVisitPhotoToGallery: value),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            header: _SettingsCardHeader(
              icon: LucideIcons.arrowLeftRight,
              title: l10n.settingsComparisonTitle,
              subtitle: l10n.settingsComparisonSubtitle,
              onTap: () => _openComparisonStyleSettings(settings),
            ),
            children: [
              if (_shouldShowMobileGallerySettings) ...[
                _SummarySwitchTile(
                  icon: LucideIcons.images,
                  title: l10n.settingsAutoSaveComparison,
                  subtitle: l10n.settingsAutoSaveComparisonSubtitle,
                  value: settings.autoSaveComparisonToGallery,
                  onChanged: (value) {
                    widget.onChanged(
                      settings.copyWith(autoSaveComparisonToGallery: value),
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            header: _SettingsCardHeader(
              icon: LucideIcons.map,
              title: l10n.settingsDataSourceTitle,
              subtitle: l10n.settingsDataSourceSubtitle,
              onTap: () => _pushDetail(
                _DataSourceSettingsPage(
                  settings: settings,
                  onChanged: widget.onChanged,
                  showMapUrlDialog: _showMapUrlDialog,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            header: _SettingsCardHeader(
              icon: LucideIcons.layers,
              title: l10n.settingsMapDisplayTitle,
              subtitle: l10n.settingsMapDisplaySubtitle,
              onTap: () => _pushDetail(
                _MapDisplaySettingsPage(
                  settings: settings,
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ),
          if (_showCacheCleanupSettings) ...[
            const SizedBox(height: 12),
            _SettingsCard(
              header: _SettingsCardHeader(
                icon: LucideIcons.brushCleaning,
                title: l10n.settingsClearCacheTitle,
                subtitle: l10n.settingsFullReferenceCache,
                onTap: () => _pushDetail(
                  _CacheCleanupSettingsPage(repository: widget.repository),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_shouldShowDesktopSection) ...[
            _SettingsCard(
              header: _SettingsCardHeader(
                icon: LucideIcons.monitor,
                title: l10n.settingsDesktopTitle,
                subtitle: l10n.settingsDesktopSubtitle,
                onTap: () => _pushDetail(
                  _DesktopSettingsPage(
                    desktopLauncherInfo: _desktopLauncherInfo,
                    desktopLauncherStatusText: _desktopLauncherStatusText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _SettingsCard(
            header: _SettingsCardHeader(
              icon: LucideIcons.info,
              title: l10n.settingsAboutTitle,
              subtitle: l10n.settingsAboutSubtitle,
              onTap: () => _pushDetail(
                _AboutSettingsPage(appVersionLabel: _appVersionLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pushDetail(Widget page) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _openComparisonStyleSettings(AppSettings settings) {
    return _pushDetail(
      _ComparisonStyleSettingsPage(
        repository: widget.repository,
        settings: settings,
        onChanged: widget.onChanged,
      ),
    );
  }

  Future<void> _confirmResetSettings() async {
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.settingsResetTitle,
      message: l10n.settingsResetMessage(l10n.settingsResetTarget),
      confirmLabel: l10n.settingsReset,
      notice: l10n.settingsResetNotice,
      emphasizedValues: [l10n.settingsResetTarget],
    );
    if (!confirmed) {
      return;
    }
    const settings = AppSettings();
    if (!await widget.onChanged(settings)) {
      return;
    }
    ComparisonExportConfig.lastUsed = const ComparisonExportConfig();
    if (mounted) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: l10n.settingsResetDone,
      );
    }
    await clearComparisonExportConfig();
  }

  String get _desktopLauncherStatusText {
    if (!_desktopLauncherLoaded) {
      return l10n.settingsDesktopLauncherChecking;
    }
    final info = _desktopLauncherInfo;
    if (info == null || !isTauriLauncherAvailable) {
      return l10n.settingsDesktopLauncherUnavailable;
    }
    final mode = info.platform == 'macos'
        ? l10n.settingsDesktopSystemDataDir
        : info.fallbackUsed
        ? l10n.settingsDesktopSystemDataDir
        : info.portable
        ? l10n.settingsDesktopPortableDir
        : l10n.settingsDesktopAppDataDir;
    return l10n.settingsDesktopLauncherAvailable(info.platform, mode);
  }

  bool get _shouldShowDesktopSection => kIsWeb;

  Future<void> _showMapUrlDialog({
    required String title,
    required String initialValue,
    required String helperText,
    required String? Function(String value) validator,
    required ValueChanged<String> onSaved,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AppInputDialog(
          title: title,
          content: Form(
            key: formKey,
            child: AppDialogField(
              label: l10n.settingsUrlLabel,
              child: TextFormField(
                onTapOutside: dismissKeyboardOnTapOutside,
                controller: controller,
                autofocus: true,
                decoration: appDialogInputDecoration(helperText: helperText),
                keyboardType: TextInputType.url,
                validator: (value) => validator(value ?? ''),
              ),
            ),
          ),
          confirmLabel: l10n.commonSave,
          onConfirm: () {
            if (!formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(controller.text);
          },
        );
      },
    );
    controller.dispose();
    if (result == null) {
      return;
    }
    onSaved(result);
  }
}

class _AppearanceSettingsPage extends StatefulWidget {
  const _AppearanceSettingsPage({
    required this.settings,
    required this.onChanged,
  });

  final AppSettings settings;
  final SettingsChanged onChanged;

  @override
  State<_AppearanceSettingsPage> createState() =>
      _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<_AppearanceSettingsPage> {
  late AppSettings _settings;
  static const _visibleThemePalettes = [
    AppThemePalette.classicGreen,
    AppThemePalette.deepBlue,
    AppThemePalette.cherryPink,
    AppThemePalette.graphite,
  ];

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  /// The settings last confirmed as stored, shown again if a save fails.
  late AppSettings _stored = widget.settings;

  Future<bool> _update(AppSettings settings) async {
    applyAppColorsFromSettings(
      settings,
      platformBrightness: MediaQuery.platformBrightnessOf(context),
    );
    setState(() {
      _settings = settings;
    });
    final saved = await widget.onChanged(settings);
    if (saved) {
      _stored = settings;
    } else if (mounted && identical(_settings, settings)) {
      // Show what is actually stored again.
      setState(() => _settings = _stored);
    }
    return saved;
  }

  Future<void> _showCustomThemeColorDialog() async {
    final result = await showDialog<CustomThemeColor>(
      context: context,
      builder: (context) => _CustomThemeColorDialog(settings: _settings),
    );
    if (result == null) {
      return;
    }

    final colors = [
      ..._settings.customThemeColors.where(
        (color) => color.name != result.name && color.value != result.value,
      ),
      result,
    ];
    _update(
      _settings.copyWith(
        themePalette: AppThemePalette.aurora,
        customThemeColorName: result.name,
        customThemeColorValue: result.value,
        customThemeColors: colors,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final uiScale = settings.uiScale.clamp(0.8, 1.0);
    final fontScale = settings.fontScale.clamp(0.8, 1.2);
    applyAppColorsFromSettings(
      settings,
      platformBrightness: MediaQuery.platformBrightnessOf(context),
    );

    return Theme(
      data: appThemeFor(
        settings,
        platformBrightness: MediaQuery.platformBrightnessOf(context),
      ),
      child: _ScaledDetailScaffold(
        title: l10n.settingsAppearanceTitle,
        uiScale: settings.uiScale,
        fontScale: settings.fontScale,
        children: [
          _AppearancePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InlineSectionTitle(
                  title: l10n.settingsThemeMode,
                  subtitle: l10n.settingsThemeModeSubtitle,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        key: const ValueKey('appearance-theme-mode-light'),
                        icon: LucideIcons.sun,
                        label: l10n.settingsLight,
                        selected: settings.themeMode == AppThemeMode.light,
                        onTap: () {
                          _update(
                            settings.copyWith(themeMode: AppThemeMode.light),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeButton(
                        key: const ValueKey('appearance-theme-mode-dark'),
                        icon: LucideIcons.moon,
                        label: l10n.settingsDark,
                        selected: settings.themeMode == AppThemeMode.dark,
                        onTap: () {
                          _update(
                            settings.copyWith(themeMode: AppThemeMode.dark),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeButton(
                        key: const ValueKey('appearance-theme-mode-system'),
                        icon: LucideIcons.smartphone,
                        label: l10n.settingsFollowSystem,
                        selected: settings.themeMode == AppThemeMode.system,
                        onTap: () {
                          _update(
                            settings.copyWith(themeMode: AppThemeMode.system),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _InlineSectionTitle(
                  title: l10n.settingsThemeColor,
                  subtitle: l10n.settingsThemeColorSubtitle,
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final palette in _visibleThemePalettes)
                        Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: _ThemeColorOption(
                            palette: palette,
                            selected:
                                settings.themePalette == palette &&
                                palette != AppThemePalette.aurora,
                            onTap: () {
                              _update(settings.copyWith(themePalette: palette));
                            },
                          ),
                        ),
                      for (final color in settings.customThemeColors)
                        Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: _CustomThemeColorOption(
                            color: color,
                            selected:
                                settings.themePalette ==
                                    AppThemePalette.aurora &&
                                settings.customThemeColorValue == color.value,
                            onTap: () {
                              _update(
                                settings.copyWith(
                                  themePalette: AppThemePalette.aurora,
                                  customThemeColorName: color.name,
                                  customThemeColorValue: color.value,
                                ),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _AddThemeColorOption(
                          selected:
                              settings.themePalette == AppThemePalette.aurora,
                          colorValue: settings.customThemeColorValue,
                          label: settings.displayCustomThemeColorName,
                          onTap: _showCustomThemeColorDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _AppearancePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.maximize,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.settingsPageScale,
                        style: _titleTextStyle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(uiScale * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 28, right: 8),
                  child: Text(
                    l10n.settingsPageScaleSubtitle,
                    style: _captionTextStyle,
                  ),
                ),
                const SizedBox(height: 14),
                _PercentScaleControl(
                  value: uiScale,
                  min: 0.8,
                  max: 1.0,
                  divisions: 4,
                  tickLabels: const ['80%', '85%', '90%', '95%', '100%'],
                  showStepper: false,
                  onChanged: (value) {
                    _update(settings.copyWith(uiScale: value));
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text('Aa', style: _titleTextStyle),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          _FontSizeButton(
                            label: l10n.settingsFontSmall,
                            selected: fontScale <= 0.9,
                            onTap: () =>
                                _update(settings.copyWith(fontScale: 0.9)),
                          ),
                          const SizedBox(width: 10),
                          _FontSizeButton(
                            label: l10n.settingsFontStandard,
                            selected: fontScale > 0.9 && fontScale < 1.1,
                            onTap: () =>
                                _update(settings.copyWith(fontScale: 1)),
                          ),
                          const SizedBox(width: 10),
                          _FontSizeButton(
                            label: l10n.settingsFontLarge,
                            selected: fontScale >= 1.1 && fontScale < 1.2,
                            onTap: () =>
                                _update(settings.copyWith(fontScale: 1.1)),
                          ),
                          const SizedBox(width: 10),
                          _FontSizeButton(
                            label: l10n.settingsFontExtraLarge,
                            selected: fontScale >= 1.2,
                            onTap: () =>
                                _update(settings.copyWith(fontScale: 1.2)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _AppearancePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsPersonalization, style: _cardTitleTextStyle),
                const SizedBox(height: 4),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    key: const ValueKey('plan-group-progress-toggle'),
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      LucideIcons.moveHorizontal,
                      color: AppColors.textSecondary,
                    ),
                    title: Text(
                      l10n.settingsShowAreaProgress,
                      style: _titleTextStyle,
                    ),
                    subtitle: Text(
                      l10n.settingsShowAreaProgressSubtitle,
                      style: _secondaryTextStyle,
                    ),
                    value: settings.showPlanGroupProgress,
                    onChanged: (value) {
                      _update(settings.copyWith(showPlanGroupProgress: value));
                    },
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    key: const ValueKey(
                      'dismiss-plan-actions-on-outside-tap-toggle',
                    ),
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      LucideIcons.pointer,
                      color: AppColors.textSecondary,
                    ),
                    title: Text(
                      l10n.settingsDismissPlanActions,
                      style: _titleTextStyle,
                    ),
                    subtitle: Text(
                      l10n.settingsDismissPlanActionsSubtitle,
                      style: _secondaryTextStyle,
                    ),
                    value: settings.dismissPlanActionsOnOutsideTap,
                    onChanged: (value) {
                      _update(
                        settings.copyWith(
                          dismissPlanActionsOnOutsideTap: value,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraSettingsPage extends StatefulWidget {
  const _CameraSettingsPage({
    required this.settings,
    required this.onChanged,
    required this.zoomCapabilities,
  });

  final AppSettings settings;
  final SettingsChanged onChanged;
  final CameraZoomCapabilities zoomCapabilities;

  @override
  State<_CameraSettingsPage> createState() => _CameraSettingsPageState();
}

class _CameraSettingsPageState extends State<_CameraSettingsPage> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  /// The settings last confirmed as stored, shown again if a save fails.
  late AppSettings _stored = widget.settings;

  Future<bool> _update(AppSettings settings) async {
    setState(() {
      _settings = settings;
    });
    final saved = await widget.onChanged(settings);
    if (saved) {
      _stored = settings;
    } else if (mounted && identical(_settings, settings)) {
      // Show what is actually stored again.
      setState(() => _settings = _stored);
    }
    return saved;
  }

  Future<void> _showCustomAspectRatioDialog({
    required bool fallbackRatio,
  }) async {
    final result = await showDialog<({double width, double height})>(
      context: context,
      builder: (context) => _CustomAspectRatioDialog(settings: _settings),
    );
    if (result == null) {
      return;
    }

    final updated = _settings.copyWith(
      customCameraAspectRatioWidth: result.width,
      customCameraAspectRatioHeight: result.height,
      cameraCaptureAspectRatio: fallbackRatio
          ? _settings.cameraCaptureAspectRatio
          : CameraPhotoAspectRatio.custom,
      cameraFallbackAspectRatio: fallbackRatio
          ? CameraPhotoAspectRatio.custom
          : _settings.cameraFallbackAspectRatio,
    );
    _update(updated);
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final zoomRangeMin = widget.zoomCapabilities.minZoom;
    final zoomRangeMax = widget.zoomCapabilities.maxZoom.clamp(
      zoomRangeMin,
      cameraZoomUpperLimit,
    );
    final cameraMinZoom = settings.cameraMinZoom.clamp(
      zoomRangeMin,
      zoomRangeMax,
    );
    final cameraMaxZoom = settings.cameraMaxZoom.clamp(
      cameraMinZoom,
      zoomRangeMax,
    );
    final zoomSliderValues = RangeValues(
      cameraZoomSliderValueFromRealZoom(
        minZoom: zoomRangeMin,
        maxZoom: zoomRangeMax,
        realZoom: cameraMinZoom,
      ),
      cameraZoomSliderValueFromRealZoom(
        minZoom: zoomRangeMin,
        maxZoom: zoomRangeMax,
        realZoom: cameraMaxZoom,
      ),
    );

    return _ScaledDetailScaffold(
      title: l10n.settingsCameraTitle,
      uiScale: settings.uiScale,
      fontScale: settings.fontScale,
      children: [
        _SettingsSection(
          title: l10n.settingsCaptureAspectRatio,
          titleSpacing: 6,
          children: [
            Text(
              l10n.settingsCaptureAspectRatioHint,
              style: _secondaryTextStyle,
            ),
            const SizedBox(height: 10),
            _AspectRatioGrid(
              ratios: const [
                CameraPhotoAspectRatio.auto,
                CameraPhotoAspectRatio.landscape16x9,
                CameraPhotoAspectRatio.cinema21x9,
                CameraPhotoAspectRatio.standard4x3,
                CameraPhotoAspectRatio.photo3x2,
                CameraPhotoAspectRatio.square1x1,
                CameraPhotoAspectRatio.portrait9x16,
                CameraPhotoAspectRatio.portrait9x21,
                CameraPhotoAspectRatio.portrait3x4,
                CameraPhotoAspectRatio.portrait2x3,
              ],
              selectedRatio: settings.cameraCaptureAspectRatio,
              onSelected: (ratio) {
                _update(settings.copyWith(cameraCaptureAspectRatio: ratio));
              },
              customSelected:
                  settings.cameraCaptureAspectRatio ==
                  CameraPhotoAspectRatio.custom,
              onCustomSelected: () =>
                  _showCustomAspectRatioDialog(fallbackRatio: false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsFallbackAspectRatio,
          titleSpacing: 6,
          children: [
            Text(
              l10n.settingsFallbackAspectRatioHint,
              style: _secondaryTextStyle,
            ),
            const SizedBox(height: 10),
            _AspectRatioGrid(
              ratios: const [
                CameraPhotoAspectRatio.native,
                CameraPhotoAspectRatio.landscape16x9,
                CameraPhotoAspectRatio.cinema21x9,
                CameraPhotoAspectRatio.standard4x3,
                CameraPhotoAspectRatio.photo3x2,
                CameraPhotoAspectRatio.square1x1,
                CameraPhotoAspectRatio.portrait9x16,
                CameraPhotoAspectRatio.portrait9x21,
                CameraPhotoAspectRatio.portrait3x4,
                CameraPhotoAspectRatio.portrait2x3,
              ],
              selectedRatio: settings.cameraFallbackAspectRatio,
              onSelected: (ratio) {
                _update(settings.copyWith(cameraFallbackAspectRatio: ratio));
              },
              customSelected:
                  settings.cameraFallbackAspectRatio ==
                  CameraPhotoAspectRatio.custom,
              onCustomSelected: () =>
                  _showCustomAspectRatioDialog(fallbackRatio: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsReferenceImageScale(
            (settings.referenceImageScale * 100).round(),
          ),
          children: [
            _PercentScaleControl(
              value: settings.referenceImageScale.clamp(0.8, 1.0),
              min: 0.8,
              max: 1.0,
              divisions: 4,
              tickLabels: const ['80%', '85%', '90%', '95%', '100%'],
              showStepper: false,
              onChanged: (value) {
                _update(settings.copyWith(referenceImageScale: value));
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsCameraZoomRange(
            cameraMinZoom.toStringAsFixed(1),
            cameraMaxZoom.toStringAsFixed(1),
          ),
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 7,
                  pressedElevation: 3,
                ),
                rangeValueIndicatorShape:
                    const PaddleRangeSliderValueIndicatorShape(),
                showValueIndicator: ShowValueIndicator.onlyForDiscrete,
              ),
              child: RangeSlider(
                min: 0,
                max: 1,
                divisions: 200,
                values: zoomSliderValues,
                labels: RangeLabels(
                  '${cameraMinZoom.toStringAsFixed(1)}x',
                  '${cameraMaxZoom.toStringAsFixed(1)}x',
                ),
                onChanged: (values) {
                  final minZoom = realZoomFromCameraSliderValue(
                    minZoom: zoomRangeMin,
                    maxZoom: zoomRangeMax,
                    sliderValue: values.start,
                  ).snapToZoomStep();
                  final maxZoom = realZoomFromCameraSliderValue(
                    minZoom: zoomRangeMin,
                    maxZoom: zoomRangeMax,
                    sliderValue: values.end,
                  ).snapToZoomStep();
                  _update(
                    settings.copyWith(
                      cameraMinZoom: minZoom.clamp(zoomRangeMin, zoomRangeMax),
                      cameraMaxZoom: maxZoom.clamp(minZoom, zoomRangeMax),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        if (_shouldShowPhotoLocationSettings) ...[
          const SizedBox(height: 12),
          _SettingsSection(
            title: l10n.settingsPhotoLocation,
            titleSpacing: 6,
            children: [
              _PhotoLocationStrategyDropdown(
                value: settings.photoLocationStrategy,
                settings: settings,
                onChanged: (strategy) {
                  if (strategy != null) {
                    _update(settings.copyWith(photoLocationStrategy: strategy));
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                _photoLocationStrategyDescription(
                  settings.photoLocationStrategy,
                ),
                style: _secondaryTextStyle,
              ),
            ],
          ),
        ],
        if (_shouldShowMobileGallerySettings) ...[
          const SizedBox(height: 12),
          _SettingsSection(
            title: l10n.settingsPhotoBackup,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  LucideIcons.cloudUpload,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  l10n.settingsSavePhotoToGallery,
                  style: _titleTextStyle,
                ),
                subtitle: Text(
                  l10n.settingsPhotoBackupSubtitle,
                  style: _secondaryTextStyle,
                ),
                value: settings.saveVisitPhotoToGallery,
                onChanged: (value) {
                  _update(settings.copyWith(saveVisitPhotoToGallery: value));
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}

String _photoLocationStrategyDescription(PhotoLocationStrategy strategy) {
  return switch (strategy) {
    PhotoLocationStrategy.askOnFirstCapture =>
      l10n.settingsPhotoLocationAskDescription,
    PhotoLocationStrategy.disabled =>
      l10n.settingsPhotoLocationDisabledDescription,
    PhotoLocationStrategy.useRecentLocation =>
      l10n.settingsPhotoLocationRecentDescription,
    PhotoLocationStrategy.waitOnConfirmation =>
      l10n.settingsPhotoLocationConfirmDescription,
  };
}

String _photoLocationStrategyBadge(PhotoLocationStrategy strategy) {
  return switch (strategy) {
    PhotoLocationStrategy.askOnFirstCapture =>
      l10n.settingsPhotoLocationBadgeAsk,
    PhotoLocationStrategy.disabled => l10n.settingsPhotoLocationBadgeOff,
    PhotoLocationStrategy.useRecentLocation =>
      l10n.settingsPhotoLocationBadgeRecent,
    PhotoLocationStrategy.waitOnConfirmation => l10n.settingsRecommended,
  };
}

String _photoLocationStrategyMenuLabel(PhotoLocationStrategy strategy) {
  return switch (strategy) {
    PhotoLocationStrategy.waitOnConfirmation =>
      l10n.settingsPhotoLocationConfirmLabel,
    _ => strategy.label,
  };
}

class _PhotoLocationStrategyDropdown extends StatelessWidget {
  const _PhotoLocationStrategyDropdown({
    required this.value,
    required this.settings,
    required this.onChanged,
  });

  final PhotoLocationStrategy value;
  final AppSettings settings;
  final ValueChanged<PhotoLocationStrategy?> onChanged;

  static const _strategies = PhotoLocationStrategy.values;

  @override
  Widget build(BuildContext context) {
    return ConstrainedMenuAnchor(
      maxMenuWidth: double.infinity,
      screenPadding: EdgeInsets.zero,
      maxMenuHeight: appScaledOverlayExtent(settings, 360),
      builder: (context, controller, child) => Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          key: const ValueKey('photo-location-strategy-selector'),
          borderRadius: BorderRadius.circular(8),
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(_photoLocationStrategyMenuLabel(value))),
                const Icon(LucideIcons.chevronDown, size: 18),
              ],
            ),
          ),
        ),
      ),
      menuChildrenBuilder: (context, width) => [
        for (final strategy in _strategies)
          MenuItemButton(
            onPressed: () => onChanged(strategy),
            leadingIcon: strategy == value
                ? const Icon(LucideIcons.check, size: 18)
                : const SizedBox(width: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(_photoLocationStrategyMenuLabel(strategy)),
                ),
                Text(
                  _photoLocationStrategyBadge(strategy),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AnitabiServiceSettingsPage extends StatefulWidget {
  const _AnitabiServiceSettingsPage({
    required this.settings,
    required this.onChanged,
    required this.showUrlDialog,
  });

  final AppSettings settings;
  final SettingsChanged onChanged;
  final Future<void> Function({
    required String title,
    required String initialValue,
    required String helperText,
    required String? Function(String value) validator,
    required ValueChanged<String> onSaved,
  })
  showUrlDialog;

  @override
  State<_AnitabiServiceSettingsPage> createState() =>
      _AnitabiServiceSettingsPageState();
}

class _AnitabiServiceSettingsPageState
    extends State<_AnitabiServiceSettingsPage> {
  late AppSettings _settings = widget.settings;
  var _testing = false;
  var _checking = false;

  /// Probe round-trip time per service; null when the probe failed.
  Map<AnitabiServiceField, int?> _testResults = const {};

  /// The addresses in use: custom ones, else the remote configuration, else
  /// the built-in defaults.
  AnitabiServiceConfig get _config => _settings.anitabiServiceConfig;

  /// The settings last confirmed as stored, shown again if a save fails.
  late AppSettings _stored = widget.settings;

  Future<bool> _update(AppSettings settings) async {
    setState(() {
      _settings = settings;
      _testResults = const {};
    });
    final saved = await widget.onChanged(settings);
    if (saved) {
      _stored = settings;
    } else if (mounted && identical(_settings, settings)) {
      // Show what is actually stored again.
      setState(() => _settings = _stored);
    }
    return saved;
  }

  Future<void> _edit({
    required String title,
    required String value,
    required ValueChanged<String> onSaved,
  }) {
    return widget.showUrlDialog(
      title: title,
      initialValue: value,
      helperText: l10n.settingsAnitabiUrlHelper,
      validator: validateAnitabiBaseUrl,
      onSaved: (value) =>
          onSaved(normalizeAnitabiBaseUrl(value, fallback: value.trim())),
    );
  }

  /// Picks up sync state written by [AnitabiEndpointSync] while this page
  /// was open.
  /// Shows what the sync has just stored; it is saved already.
  Future<void> _reloadFromSync(AnitabiEndpointSync sync) async {
    final latest = await sync.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = latest;
      _stored = latest;
      _testResults = const {};
    });
  }

  void _showSaveFailed() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showStatusSnack(
      kind: AppStatusBannerKind.error,
      title: l10n.settingsSaveFailed,
      subtitle: l10n.settingsTryAgainLater,
    );
  }

  Future<void> _setAutoUpdate(bool enabled) async {
    final sync = AnitabiEndpointSync.active;
    if (sync == null) {
      _update(
        _settings.copyWith(
          anitabiRemoteStateJson: _settings.anitabiRemoteState
              .copyWith(autoUpdate: enabled)
              .encode(),
        ),
      );
      return;
    }
    try {
      await sync.setAutoUpdate(enabled);
    } on Object catch (error) {
      debugPrint('Failed to save Anitabi auto update: $error');
      _showSaveFailed();
    }
    await _reloadFromSync(sync);
  }

  Future<void> _checkNow() async {
    final sync = AnitabiEndpointSync.active;
    if (sync == null) {
      return;
    }
    setState(() => _checking = true);
    AnitabiSyncOutcome? outcome;
    try {
      outcome = await sync.checkNow();
    } on Object catch (error) {
      debugPrint('Anitabi address check could not be saved: $error');
    }
    try {
      await _reloadFromSync(sync);
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
    if (!mounted) {
      return;
    }
    if (outcome == null) {
      _showSaveFailed();
      return;
    }
    final succeeded =
        outcome == AnitabiSyncOutcome.updated ||
        outcome == AnitabiSyncOutcome.unchanged;
    ScaffoldMessenger.of(context).showStatusSnack(
      kind: succeeded ? AppStatusBannerKind.success : AppStatusBannerKind.error,
      title: outcome.label,
    );
  }

  Future<void> _testConnections() async {
    setState(() {
      _testing = true;
      _testResults = const {};
    });
    final config = _config;
    final probes = <AnitabiServiceField, Uri>{
      AnitabiServiceField.site: config.siteUri('/'),
      AnitabiServiceField.staticData: config.staticDataUri('g.json'),
      AnitabiServiceField.api: config.apiUri('bangumi/115908/lite'),
      AnitabiServiceField.officialImage: Uri.parse(
        config.officialImageUrl(
          Uri.parse(
            'https://image.anitabi.cn/points/115908/qys7fu.jpg?plan=h160',
          ),
        ),
      ),
      AnitabiServiceField.mirrorImage: Uri.parse(
        config.mirrorImageUrl(
          Uri.parse(
            'https://image.anitabi.cn/points/115908/qys7fu.jpg?plan=h160',
          ),
        ),
      ),
    };
    final results = <AnitabiServiceField, int?>{};
    final client = http.Client();
    try {
      for (final entry in probes.entries) {
        results[entry.key] = await _probe(client, entry.value);
        if (mounted) {
          setState(() => _testResults = {...results});
        }
      }
    } finally {
      client.close();
    }
    if (mounted) {
      setState(() => _testing = false);
    }
  }

  /// Returns the round-trip time in ms, or null when the service failed.
  Future<int?> _probe(http.Client client, Uri uri) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await sendPublicGet(
        client,
        uri,
        headers: const {'range': 'bytes=0-2047'},
      ).timeout(const Duration(seconds: 12));
      await response.stream.timeout(const Duration(seconds: 12)).drain<void>();
      stopwatch.stop();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }

  Future<void> _restoreDefaults() async {
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.settingsRestoreDefaultAddresses,
      message: l10n.settingsAnitabiRestoreMessage(
        l10n.settingsAnitabiRestoreTarget,
      ),
      confirmLabel: l10n.settingsRestoreDefault,
      notice: l10n.settingsAnitabiRestoreNotice,
      emphasizedValues: [l10n.settingsAnitabiRestoreTarget],
    );
    if (!confirmed || !mounted) {
      return;
    }
    _update(
      _settings.copyWith(
        anitabiSiteBaseUrl: defaultAnitabiSiteBaseUrl,
        anitabiStaticDataBaseUrl: defaultAnitabiStaticDataBaseUrl,
        anitabiApiBaseUrl: defaultAnitabiApiBaseUrl,
        anitabiOfficialImageBaseUrl: defaultAnitabiOfficialImageBaseUrl,
        anitabiMirrorImageBaseUrl: defaultAnitabiMirrorImageBaseUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final remoteState = settings.anitabiRemoteState;
    final services =
        <
          ({
            Key key,
            IconData icon,
            String title,
            AnitabiServiceField field,
            ValueChanged<String> onSaved,
          })
        >[
          (
            key: const ValueKey('anitabi-site-base-url'),
            icon: LucideIcons.globe,
            title: l10n.settingsAnitabiSite,
            field: AnitabiServiceField.site,
            onSaved: (value) =>
                _update(settings.copyWith(anitabiSiteBaseUrl: value)),
          ),
          (
            key: const ValueKey('anitabi-static-data-base-url'),
            icon: LucideIcons.braces,
            title: l10n.settingsAnitabiStaticData,
            field: AnitabiServiceField.staticData,
            onSaved: (value) =>
                _update(settings.copyWith(anitabiStaticDataBaseUrl: value)),
          ),
          (
            key: const ValueKey('anitabi-api-base-url'),
            icon: LucideIcons.webhook,
            title: l10n.settingsAnitabiApi,
            field: AnitabiServiceField.api,
            onSaved: (value) =>
                _update(settings.copyWith(anitabiApiBaseUrl: value)),
          ),
          (
            key: const ValueKey('anitabi-official-image-base-url'),
            icon: LucideIcons.image,
            title: l10n.settingsAnitabiOfficialImage,
            field: AnitabiServiceField.officialImage,
            onSaved: (value) =>
                _update(settings.copyWith(anitabiOfficialImageBaseUrl: value)),
          ),
          (
            key: const ValueKey('anitabi-mirror-image-base-url'),
            icon: LucideIcons.cloud,
            title: l10n.settingsAnitabiMirrorImage,
            field: AnitabiServiceField.mirrorImage,
            onSaved: (value) =>
                _update(settings.copyWith(anitabiMirrorImageBaseUrl: value)),
          ),
        ];
    return _ScaledDetailScaffold(
      title: l10n.settingsAnitabiServices,
      uiScale: settings.uiScale,
      fontScale: settings.fontScale,
      children: [
        _SettingsSection(
          title: l10n.settingsServiceAddresses,
          titleSpacing: 4,
          children: [
            for (var index = 0; index < services.length; index += 1) ...[
              if (index > 0)
                Divider(height: 1, thickness: 1, color: AppColors.border),
              Builder(
                builder: (context) {
                  final service = services[index];
                  final resolved = settings.resolvedAnitabiAddress(
                    service.field,
                  );
                  return _AnitabiServiceRow(
                    key: service.key,
                    icon: service.icon,
                    title: service.title,
                    url: resolved.value,
                    source: resolved.source,
                    tested: _testResults.containsKey(service.field),
                    elapsedMs: _testResults[service.field],
                    testing:
                        _testing && !_testResults.containsKey(service.field),
                    onTap: () => _edit(
                      title: service.title,
                      value: resolved.value,
                      onSaved: (value) {
                        // Confirming the address already in use keeps it
                        // following the remote configuration.
                        if (value == resolved.value &&
                            resolved.source != AnitabiServiceSource.custom) {
                          return;
                        }
                        service.onSaved(value);
                      },
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('anitabi-service-test-all'),
                onPressed: _testing ? null : _testConnections,
                icon: _testing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.wifi),
                label: Text(
                  _testing
                      ? l10n.settingsTestingConnections
                      : l10n.settingsTestAllConnections,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('anitabi-service-restore-defaults'),
                onPressed: _testing ? null : _restoreDefaults,
                icon: const Icon(LucideIcons.history),
                label: Text(l10n.settingsRestoreDefaultAddresses),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsAddressAutoUpdate,
          titleSpacing: 4,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsAddressAutoUpdateDescription,
                        style: _secondaryTextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  key: const ValueKey('anitabi-service-auto-update'),
                  value: remoteState.autoUpdate,
                  onChanged: _checking ? null : _setAutoUpdate,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _anitabiRemoteStatusText(remoteState),
              key: const ValueKey('anitabi-service-remote-status'),
              style: _secondaryTextStyle,
            ),
            if (AnitabiEndpointSync.active != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const ValueKey('anitabi-service-check-now'),
                  onPressed: _checking || _testing ? null : _checkNow,
                  icon: _checking
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.refreshCw),
                  label: Text(
                    _checking ? l10n.settingsChecking : l10n.settingsCheckNow,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

String _anitabiRemoteStatusText(AnitabiRemoteState state) {
  final lastGood = state.lastGood;
  final applied = lastGood == null
      ? l10n.settingsRemoteConfigNotApplied
      : l10n.settingsRemoteConfigApplied(lastGood.version);
  final lastCheck = state.lastCheckAt;
  if (lastCheck == null) {
    return applied;
  }
  final result = AnitabiSyncOutcome.values
      .where((outcome) => outcome.name == state.lastResult)
      .firstOrNull;
  final local = lastCheck.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  final time =
      '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
  return result == null
      ? l10n.settingsRemoteLastCheck(applied, time)
      : l10n.settingsRemoteLastCheckResult(applied, time, result.label);
}

class _ComparisonStyleSettingsPage extends StatefulWidget {
  const _ComparisonStyleSettingsPage({
    required this.repository,
    required this.settings,
    required this.onChanged,
  });

  final PilgrimageRepository repository;
  final AppSettings settings;
  final SettingsChanged onChanged;

  @override
  State<_ComparisonStyleSettingsPage> createState() =>
      _ComparisonStyleSettingsPageState();
}

class _ComparisonStyleSettingsPageState
    extends State<_ComparisonStyleSettingsPage> {
  var _settings = const AppSettings();
  var _config = ComparisonExportConfig.lastUsed;
  late final TextEditingController _pilgrimNameController;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _config = ComparisonExportConfig.lastUsed.withSettings(_settings);
    _pilgrimNameController = TextEditingController(text: _config.pilgrimName);
    _loadSavedConfig();
  }

  @override
  void dispose() {
    if (_saveTimer?.isActive ?? false) {
      // Only this page's fields, on top of the app's current settings, and
      // after this frame: the tree is locked while the page is disposed.
      final config = _config;
      final repository = widget.repository;
      unawaited(
        Future(
          () => AppSettingsUpdater.update(repository, config.applyToSettings),
        ),
      );
    }
    _saveTimer?.cancel();
    _pilgrimNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedConfig() async {
    // The app's settings when it runs: the repository may still be storing
    // the latest change.
    final settings =
        AppSettingsUpdater.currentSettings?.call() ??
        await widget.repository.loadAppSettings();
    if (!mounted) {
      return;
    }

    final migratedConfig = ComparisonExportConfig.fromSettings(settings);
    setState(() {
      _settings = settings;
      _config = migratedConfig;
      ComparisonExportConfig.lastUsed = migratedConfig;
      _pilgrimNameController.text = migratedConfig.pilgrimName;
      _stored = (config: migratedConfig, settings: settings);
      _loading = false;
    });
  }

  /// The last configuration confirmed as stored, shown again if a save
  /// fails.
  ({ComparisonExportConfig config, AppSettings settings})? _stored;

  /// Changes are saved once they pause: typing the pilgrim name or dragging
  /// the border slider would otherwise store (and rebuild the app) per step.
  Timer? _saveTimer;

  Future<void> _updateConfig(ComparisonExportConfig config) async {
    _stored ??= (config: _config, settings: _settings);
    final previous = _config;
    final settings = config.applyToSettings(_settings);
    setState(() {
      _config = config;
      _settings = settings;
    });
    ComparisonExportConfig.lastUsed = config;
    _saveTimer?.cancel();
    _saveTimer = Timer(
      config.pilgrimName != previous.pilgrimName
          ? const Duration(milliseconds: 600)
          : const Duration(milliseconds: 300),
      () => _save(config, settings),
    );
  }

  Future<void> _save(
    ComparisonExportConfig config,
    AppSettings settings,
  ) async {
    final stored = _stored ?? (config: config, settings: settings);
    if (await widget.onChanged(settings)) {
      _stored = (config: config, settings: settings);
      return;
    }
    if (!mounted || !identical(_settings, settings)) {
      return;
    }
    final restore = _stored ?? stored;
    setState(() {
      _config = restore.config;
      _settings = restore.settings;
      if (_pilgrimNameController.text != restore.config.pilgrimName) {
        _pilgrimNameController.text = restore.config.pilgrimName;
      }
    });
    ComparisonExportConfig.lastUsed = restore.config;
  }

  @override
  Widget build(BuildContext context) {
    return _ScaledDetailScaffold(
      title: l10n.settingsComparisonTitle,
      uiScale: _settings.uiScale,
      fontScale: _settings.fontScale,
      children: [
        _SettingsSection(
          title: '',
          showTitle: false,
          children: [
            if (_loading) ...[
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 14),
            ],
            ComparisonExportConfigEditor(
              config: _config,
              pilgrimNameController: _pilgrimNameController,
              onChanged: _updateConfig,
            ),
          ],
        ),
      ],
    );
  }
}

class _DataSourceSettingsPage extends StatefulWidget {
  const _DataSourceSettingsPage({
    required this.settings,
    required this.onChanged,
    required this.showMapUrlDialog,
  });

  final AppSettings settings;
  final SettingsChanged onChanged;
  final Future<void> Function({
    required String title,
    required String initialValue,
    required String helperText,
    required String? Function(String value) validator,
    required ValueChanged<String> onSaved,
  })
  showMapUrlDialog;

  @override
  State<_DataSourceSettingsPage> createState() =>
      _DataSourceSettingsPageState();
}

class _DataSourceSettingsPageState extends State<_DataSourceSettingsPage> {
  late AppSettings _settings;
  var _testingValhalla = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  /// The settings last confirmed as stored, shown again if a save fails.
  late AppSettings _stored = widget.settings;

  Future<bool> _update(AppSettings settings) async {
    setState(() {
      _settings = settings;
    });
    final saved = await widget.onChanged(settings);
    if (saved) {
      _stored = settings;
    } else if (mounted && identical(_settings, settings)) {
      // Show what is actually stored again.
      setState(() => _settings = _stored);
    }
    return saved;
  }

  Future<void> _testValhalla() async {
    setState(() => _testingValhalla = true);
    try {
      await ValhallaRouteClient().testConnection(_settings.valhallaBaseUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.success,
          title: l10n.settingsRoutingConnectionOk,
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.settingsRoutingConnectionFailed,
          subtitle: error.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _testingValhalla = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return _ScaledDetailScaffold(
      title: l10n.settingsDataSourceTitle,
      uiScale: settings.uiScale,
      fontScale: settings.fontScale,
      children: [
        _SettingsSection(
          title: l10n.settingsMapSource(
            mapTileProviderOption(settings.mapTileProvider).label,
          ),
          children: [
            _MapSourceGrid(
              selectedProvider: settings.mapTileProvider,
              onSelected: (provider) {
                _update(settings.copyWith(mapTileProvider: provider));
              },
            ),
            const SizedBox(height: 10),
            Text(
              mapTileProviderOption(settings.mapTileProvider).description,
              style: _secondaryTextStyle,
            ),
            if (settings.mapTileProvider == MapTileProvider.openFreeMap) ...[
              const SizedBox(height: 12),
              _SettingsSubheading(
                icon: LucideIcons.layers,
                title: l10n.settingsOpenFreeMapStyle(
                  openFreeMapStyleOption(settings.openFreeMapStyle).label,
                ),
              ),
              const SizedBox(height: 8),
              _OpenFreeMapStyleGrid(
                selectedStyle: settings.openFreeMapStyle,
                onSelected: (style) {
                  _update(settings.copyWith(openFreeMapStyle: style));
                },
              ),
              const SizedBox(height: 10),
              Text(
                openFreeMapStyleOption(settings.openFreeMapStyle).description,
                style: _secondaryTextStyle,
              ),
            ],
            if (settings.mapTileProvider == MapTileProvider.customXyz) ...[
              const SizedBox(height: 12),
              _MapUrlRow(
                icon: LucideIcons.grid3X3,
                label: settings.customXyzTileUrl.trim().isEmpty
                    ? l10n.settingsCustomXyzUrlNotSet
                    : settings.customXyzTileUrl.trim(),
                onTap: () => widget.showMapUrlDialog(
                  title: l10n.settingsCustomXyzUrl,
                  initialValue: settings.customXyzTileUrl,
                  helperText: l10n.settingsXyzUrlHelper('{z}', '{x}', '{y}'),
                  validator: (value) => isValidXyzTileUrl(value.trim())
                      ? null
                      : l10n.settingsInvalidUrl,
                  onSaved: (value) {
                    _update(settings.copyWith(customXyzTileUrl: value.trim()));
                  },
                ),
              ),
            ],
            if (settings.mapTileProvider ==
                MapTileProvider.customMapLibreStyle) ...[
              const SizedBox(height: 12),
              _MapUrlRow(
                icon: LucideIcons.braces,
                label: settings.customMapLibreStyleUrl.trim().isEmpty
                    ? l10n.settingsMapLibreStyleUrlNotSet
                    : settings.customMapLibreStyleUrl.trim(),
                onTap: () => widget.showMapUrlDialog(
                  title: 'MapLibre style URL',
                  initialValue: settings.customMapLibreStyleUrl,
                  helperText: l10n.settingsMapLibreStyleUrlHelper,
                  validator: (value) {
                    final testSettings = settings.copyWith(
                      customMapLibreStyleUrl: value.trim(),
                    );
                    return validateMapTileSettings(testSettings);
                  },
                  onSaved: (value) {
                    _update(
                      settings.copyWith(customMapLibreStyleUrl: value.trim()),
                    );
                  },
                ),
              ),
            ],
            if (validateMapTileSettings(settings) != null) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: LucideIcons.circleAlert,
                text: validateMapTileSettings(settings)!,
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: '',
          showTitle: false,
          children: [
            _SettingsSubheading(title: l10n.settingsAnitabiServices),
            const SizedBox(height: 8),
            _AnitabiServiceEntryRow(
              key: const ValueKey('anitabi-service-settings-entry'),
              siteUrl: settings.anitabiServiceConfig.siteBaseUrl,
              summary: _anitabiServiceSummary(settings),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _AnitabiServiceSettingsPage(
                    settings: settings,
                    onChanged: _update,
                    showUrlDialog: widget.showMapUrlDialog,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(l10n.settingsAnitabiServicesHint, style: _secondaryTextStyle),
            const SizedBox(height: 20),
            Divider(height: 1, thickness: 1, color: AppColors.surfaceMuted),
            const SizedBox(height: 18),
            Text(
              l10n.settingsAnitabiImageSource(
                _anitabiImageSourceLabel(settings.anitabiImageSource),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            _AnitabiImageSourceGrid(
              selectedSource: settings.anitabiImageSource,
              onSelected: (source) {
                _update(settings.copyWith(anitabiImageSource: source));
              },
            ),
            const SizedBox(height: 10),
            Text(
              _anitabiImageSourceDescription(settings),
              style: _secondaryTextStyle,
            ),
            const SizedBox(height: 20),
            Divider(height: 1, thickness: 1, color: AppColors.surfaceMuted),
            const SizedBox(height: 18),
            _NumberStepperSetting(
              icon: LucideIcons.cloudDownload,
              title: l10n.settingsConcurrentImageLoads,
              subtitle: l10n.settingsConcurrentImageLoadsSubtitle,
              value: settings.mapThumbnailConcurrentLoads,
              min: 1,
              max: 30,
              step: 1,
              valueLabel: l10n.settingsCountValue(
                settings.mapThumbnailConcurrentLoads,
              ),
              onChanged: (value) {
                _update(settings.copyWith(mapThumbnailConcurrentLoads: value));
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsNavigationApp(settings.navigationApp.label),
          children: [
            _NavigationAppGrid(
              selectedApp: settings.navigationApp,
              onSelected: (app) {
                _update(settings.copyWith(navigationApp: app));
              },
            ),
            const SizedBox(height: 10),
            Text(
              _navigationAppDescription(settings.navigationApp),
              style: _secondaryTextStyle,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsWalkingRoutes,
          children: [
            _MapUrlRow(
              icon: LucideIcons.route,
              label: settings.valhallaBaseUrl,
              onTap: () => widget.showMapUrlDialog(
                title: l10n.settingsValhallaAddress,
                initialValue: settings.valhallaBaseUrl,
                helperText: l10n.settingsValhallaHelper,
                validator: validateValhallaBaseUrl,
                onSaved: (value) {
                  _update(
                    settings.copyWith(
                      valhallaBaseUrl: normalizeValhallaBaseUrl(value),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ResponsiveTwoButtonRow(
              first: OutlinedButton(
                onPressed: _testingValhalla ? null : _testValhalla,
                child: _testingValhalla
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ResponsiveButtonContent(
                        icon: LucideIcons.radio,
                        label: l10n.settingsTestConnection,
                        shortLabel: l10n.settingsTest,
                        semanticLabel: l10n.settingsTestValhallaConnection,
                      ),
              ),
              second: OutlinedButton(
                onPressed: settings.valhallaBaseUrl == defaultValhallaBaseUrl
                    ? null
                    : () => _update(
                        settings.copyWith(
                          valhallaBaseUrl: defaultValhallaBaseUrl,
                        ),
                      ),
                child: ResponsiveButtonContent(
                  icon: LucideIcons.history,
                  label: l10n.settingsRestoreDefault,
                  shortLabel: l10n.settingsReset,
                  semanticLabel: l10n.settingsRestoreDefaultValhalla,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.settingsValhallaPrivacy, style: _secondaryTextStyle),
          ],
        ),
      ],
    );
  }
}

class _MapDisplaySettingsPage extends StatefulWidget {
  const _MapDisplaySettingsPage({
    required this.settings,
    required this.onChanged,
  });

  final AppSettings settings;
  final SettingsChanged onChanged;

  @override
  State<_MapDisplaySettingsPage> createState() =>
      _MapDisplaySettingsPageState();
}

class _MapDisplaySettingsPageState extends State<_MapDisplaySettingsPage> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  /// The settings last confirmed as stored, shown again if a save fails.
  late AppSettings _stored = widget.settings;

  Future<bool> _update(AppSettings settings) async {
    setState(() {
      _settings = settings;
    });
    final saved = await widget.onChanged(settings);
    if (saved) {
      _stored = settings;
    } else if (mounted && identical(_settings, settings)) {
      // Show what is actually stored again.
      setState(() => _settings = _stored);
    }
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return _ScaledDetailScaffold(
      title: l10n.settingsMapDisplayTitle,
      uiScale: settings.uiScale,
      fontScale: settings.fontScale,
      children: [
        _SettingsSection(
          title: l10n.settingsBaseMapBrightness,
          children: [
            Row(
              children: [
                for (final appearance in MapAppearance.values) ...[
                  if (appearance != MapAppearance.values.first)
                    const SizedBox(width: 10),
                  Expanded(
                    child: _ModeButton(
                      key: ValueKey('map-appearance-${appearance.name}'),
                      icon: switch (appearance) {
                        MapAppearance.automatic => LucideIcons.smartphone,
                        MapAppearance.light => LucideIcons.sun,
                        MapAppearance.dark => LucideIcons.moon,
                      },
                      label: switch (appearance) {
                        MapAppearance.automatic => l10n.settingsFollowTheme,
                        MapAppearance.light => l10n.settingsLight,
                        MapAppearance.dark => l10n.settingsDark,
                      },
                      selected: settings.mapAppearance == appearance,
                      onTap: () =>
                          _update(settings.copyWith(mapAppearance: appearance)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.settingsBaseMapBrightnessHint,
              style: _secondaryTextStyle,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsCurrentLocation,
          children: [
            SwitchListTile(
              key: const ValueKey('continuous-map-location-switch'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.settingsContinuousLocation,
                style: _titleTextStyle,
              ),
              subtitle: Text(
                l10n.settingsContinuousLocationSubtitle,
                style: _secondaryTextStyle,
              ),
              value: settings.continuousMapLocation,
              onChanged: (value) =>
                  _update(settings.copyWith(continuousMapLocation: value)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsMapZoom,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.zoomIn,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.settingsMaxZoom,
                              style: _titleTextStyle,
                            ),
                          ),
                          Text(
                            l10n.settingsZoomLevel(settings.mapMaxZoom),
                            style: TextStyle(
                              color: AppColors.accentForeground,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.settingsMaxZoomHint,
                        style: _secondaryTextStyle,
                      ),
                      Slider(
                        key: const ValueKey('map-max-zoom-slider'),
                        min: 16,
                        max: 24,
                        divisions: 8,
                        value: settings.mapMaxZoom.toDouble().clamp(16, 24),
                        label: l10n.settingsZoomLevel(settings.mapMaxZoom),
                        onChanged: (value) {
                          final mapMaxZoom = value.round();
                          final clusterMaxZoom =
                              settings.mapMarkerClusterMaxZoom > mapMaxZoom
                              ? mapMaxZoom
                              : settings.mapMarkerClusterMaxZoom;
                          _update(
                            settings.copyWith(
                              mapMaxZoom: mapMaxZoom,
                              mapMarkerClusterMaxZoom: clusterMaxZoom,
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('16', style: _captionTextStyle),
                            Text('18', style: _captionTextStyle),
                            Text('20', style: _captionTextStyle),
                            Text('22', style: _captionTextStyle),
                            Text('24', style: _captionTextStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsMapMarkers,
          children: [
            Material(
              color: Colors.transparent,
              child: SwitchListTile(
                key: const ValueKey('hide-completed-points-on-map-toggle'),
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  LucideIcons.eyeOff,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  l10n.settingsHideCompletedSpots,
                  style: _titleTextStyle,
                ),
                subtitle: Text(
                  l10n.settingsHideCompletedSpotsSubtitle,
                  style: _secondaryTextStyle,
                ),
                value: settings.hideCompletedPointsOnMap,
                onChanged: (value) {
                  _update(settings.copyWith(hideCompletedPointsOnMap: value));
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.mapPin,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.settingsMarkerSize, style: _titleTextStyle),
                      const SizedBox(height: 3),
                      Text(
                        l10n.settingsMarkerSizeSubtitle,
                        style: _secondaryTextStyle,
                      ),
                      const SizedBox(height: 8),
                      _PercentScaleControl(
                        value: settings.mapMarkerScale,
                        min: 0.6,
                        max: 1.2,
                        divisions: 12,
                        tickLabels: const ['60%', '80%', '100%', '120%'],
                        onChanged: (value) {
                          _update(settings.copyWith(mapMarkerScale: value));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsAreaRange,
          children: [
            _NumberStepperSetting(
              icon: LucideIcons.hand,
              title: l10n.settingsAreaRadius,
              subtitle: l10n.settingsAreaRadiusSubtitle,
              value: settings.mapGroupAreaRadiusMeters,
              min: 25,
              max: 500,
              step: 25,
              valueLabel: '${settings.mapGroupAreaRadiusMeters} m',
              onChanged: (value) {
                _update(settings.copyWith(mapGroupAreaRadiusMeters: value));
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsSpotClustering,
          children: [
            Material(
              color: Colors.transparent,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  LucideIcons.gitBranch,
                  color: AppColors.textSecondary,
                ),
                title: Text(l10n.settingsAutoCluster, style: _titleTextStyle),
                subtitle: Text(
                  l10n.settingsAutoClusterSubtitle,
                  style: _secondaryTextStyle,
                ),
                value: settings.mapMarkerClusteringEnabled,
                onChanged: (value) {
                  _update(settings.copyWith(mapMarkerClusteringEnabled: value));
                },
              ),
            ),
            if (settings.mapMarkerClusteringEnabled) ...[
              const SizedBox(height: 8),
              _NumberStepperSetting(
                icon: LucideIcons.circleDashed,
                title: l10n.settingsClusterRadius,
                subtitle: l10n.settingsClusterRadiusSubtitle,
                value: settings.mapMarkerClusterRadius,
                min: 32,
                max: 120,
                step: 8,
                valueLabel: '${settings.mapMarkerClusterRadius} px',
                onChanged: (value) {
                  _update(settings.copyWith(mapMarkerClusterRadius: value));
                },
              ),
              const SizedBox(height: 12),
              _NumberStepperSetting(
                icon: LucideIcons.maximize,
                title: l10n.settingsClusterMaxZoom,
                subtitle: l10n.settingsClusterMaxZoomSubtitle,
                value: settings.mapMarkerClusterMaxZoom,
                min: 10,
                max: settings.mapMaxZoom.clamp(10, 22),
                step: 1,
                valueLabel: l10n.settingsZoomLevel(
                  settings.mapMarkerClusterMaxZoom,
                ),
                onChanged: (value) {
                  _update(settings.copyWith(mapMarkerClusterMaxZoom: value));
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsMapThumbnails,
          children: [
            _NumberStepperSetting(
              icon: LucideIcons.maximize,
              title: l10n.settingsThumbnailThreshold,
              subtitle: l10n.settingsThumbnailThresholdSubtitle(
                settings.mapThumbnailVisibleThreshold,
              ),
              value: settings.mapThumbnailVisibleThreshold,
              min: 0,
              max: 200,
              step: 5,
              valueLabel: l10n.settingsCountValue(
                settings.mapThumbnailVisibleThreshold,
              ),
              onChanged: (value) {
                _update(settings.copyWith(mapThumbnailVisibleThreshold: value));
              },
            ),
            const SizedBox(height: 8),
            Text(
              l10n.settingsThumbnailThresholdHint,
              style: _secondaryTextStyle,
            ),
          ],
        ),
      ],
    );
  }
}

class _CacheCleanupSettingsPage extends StatefulWidget {
  const _CacheCleanupSettingsPage({required this.repository});

  final PilgrimageRepository repository;

  @override
  State<_CacheCleanupSettingsPage> createState() =>
      _CacheCleanupSettingsPageState();
}

class _CacheCleanupSettingsPageState extends State<_CacheCleanupSettingsPage> {
  final Set<String> _selectedPlanIds = <String>{};
  Future<List<PilgrimagePlan>>? _plansFuture;
  var _busy = false;
  var _completed = 0;
  var _total = 0;

  @override
  void initState() {
    super.initState();
    _plansFuture = widget.repository.loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: l10n.settingsClearCacheTitle,
      children: [
        FutureBuilder<List<PilgrimagePlan>>(
          future: _plansFuture,
          builder: (context, snapshot) {
            final plans = snapshot.data;
            if (snapshot.connectionState != ConnectionState.done) {
              return _SettingsSection(
                title: l10n.settingsPlans,
                children: const [
                  Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.hasError || plans == null) {
              return _SettingsSection(
                title: l10n.settingsPlans,
                children: [
                  _InfoRow(
                    icon: LucideIcons.circleAlert,
                    text: l10n.settingsPlansLoadFailed,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _plansFuture = widget.repository.loadPlans();
                      });
                    },
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    label: Text(l10n.commonRetry),
                  ),
                ],
              );
            }

            _selectedPlanIds.removeWhere(
              (id) => plans.every((plan) => plan.id != id),
            );

            return Column(
              children: [
                _SettingsSection(
                  title: l10n.settingsSelectPlans,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.settingsSelectedPlans(
                              _selectedPlanIds.length,
                              plans.length,
                            ),
                            style: _secondaryTextStyle,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.settingsSelectAll,
                          onPressed: () {
                            setState(() {
                              _selectedPlanIds
                                ..clear()
                                ..addAll(plans.map((plan) => plan.id));
                            });
                          },
                          icon: const Icon(LucideIcons.scan),
                        ),
                        IconButton(
                          tooltip: l10n.settingsClearSelection,
                          onPressed: _selectedPlanIds.isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    _selectedPlanIds.clear();
                                  });
                                },
                          icon: const Icon(LucideIcons.square),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...plans.map(
                      (plan) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(plan.name, style: _titleTextStyle),
                        subtitle: Text(
                          l10n.settingsPlanSummary(
                            plan.area,
                            plan.points.length,
                          ),
                          style: _secondaryTextStyle,
                        ),
                        value: _selectedPlanIds.contains(plan.id),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedPlanIds.add(plan.id);
                            } else {
                              _selectedPlanIds.remove(plan.id);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _FullReferenceCacheSection(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _selectedPlanIds.isEmpty || _busy
                        ? null
                        : () => _confirmAndClean(
                            plans.where(
                              (plan) => _selectedPlanIds.contains(plan.id),
                            ),
                          ),
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.brushCleaning),
                    label: Text(
                      _busy && _total > 0
                          ? l10n.settingsCleaningProgress(_completed, _total)
                          : l10n.settingsClearDownloadedReferenceCache,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmAndClean(Iterable<PilgrimagePlan> selected) async {
    setState(() => _busy = true);
    final plans = selected.toList(growable: false);
    late ReferenceCacheScan scan;
    try {
      scan = await scanDownloadedReferenceCaches(
        plans,
        retainedPaths: await referenceCachePathsInUseElsewhere(
          repository: widget.repository,
          planIds: plans.map((plan) => plan.id),
        ),
      );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.settingsCacheScanFailed,
          subtitle: error.toString(),
        );
      }
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (scan.fileCount == 0) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: l10n.settingsNoCacheToClear,
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsClearReferenceCacheTitle),
        content: Text(
          l10n.settingsClearReferenceCacheMessage(
            scan.fileCount,
            _formatByteSize(scan.byteCount),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsClear),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _completed = 0;
      _total = scan.paths.length;
    });
    try {
      final result = await cleanupDownloadedReferenceCaches(
        repository: widget.repository,
        plans: plans,
        onProgress: (completed, total) {
          if (!mounted) return;
          setState(() {
            _completed = completed;
            _total = total;
          });
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: result.failedFileCount == 0
            ? AppStatusBannerKind.success
            : AppStatusBannerKind.warning,
        title: l10n.settingsCacheCleared(result.deletedFileCount),
        subtitle: result.failedFileCount == 0
            ? l10n.settingsFreedSpace(_formatByteSize(result.reclaimedBytes))
            : l10n.settingsCacheClearFailedFiles(result.failedFileCount),
      );
      setState(() {
        _plansFuture = widget.repository.loadPlans();
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _completed = 0;
          _total = 0;
        });
      }
    }
  }
}

class _DesktopSettingsPage extends StatelessWidget {
  const _DesktopSettingsPage({
    required this.desktopLauncherInfo,
    required this.desktopLauncherStatusText,
  });

  final DesktopLauncherInfo? desktopLauncherInfo;
  final String desktopLauncherStatusText;

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: l10n.settingsDesktopTitle,
      children: [
        _SettingsSection(
          title: l10n.settingsLauncher,
          children: [
            _InfoRow(
              icon: LucideIcons.monitor,
              text: desktopLauncherStatusText,
            ),
            if (desktopLauncherInfo != null) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: LucideIcons.folder,
                text: desktopLauncherInfo!.dataDir,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: LucideIcons.package,
                text: desktopLauncherInfo!.assetsDir,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

String _formatByteSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kilobytes = bytes / 1024;
  if (kilobytes < 1024) return '${kilobytes.toStringAsFixed(1)} KB';
  final megabytes = kilobytes / 1024;
  if (megabytes < 1024) return '${megabytes.toStringAsFixed(1)} MB';
  return '${(megabytes / 1024).toStringAsFixed(2)} GB';
}

class _AboutSettingsPage extends StatelessWidget {
  const _AboutSettingsPage({required this.appVersionLabel});

  final String? appVersionLabel;

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: l10n.settingsAboutTitle,
      children: [
        _SettingsSection(
          title: l10n.settingsAppInfo,
          children: [
            Row(
              children: [
                const _AppIconMark(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CopyableText(
                        text: 'MiriaGo',
                        copyLabel: 'MiriaGo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(l10n.settingsAppTagline, style: _secondaryTextStyle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _AboutInfoTile(
              icon: LucideIcons.badge,
              label: l10n.settingsCurrentVersion,
              value: appVersionLabel ?? l10n.settingsLoading,
            ),
            _AboutInfoTile(
              icon: LucideIcons.user,
              label: l10n.settingsAuthor,
              value: 'BilyHurington',
            ),
            _AboutInfoTile(
              icon: LucideIcons.mail,
              label: l10n.settingsContactEmail,
              value: 'bilyhurington@gmail.com',
            ),
            _AboutInfoTile(
              icon: LucideIcons.code,
              label: l10n.settingsSourceRepository,
              value: 'github.com/BilyHurington/MiriaGo',
            ),
            _AboutInfoTile(
              icon: LucideIcons.scale,
              label: l10n.settingsLicense,
              value: 'MIT License',
            ),
            _AboutInfoTile(
              icon: LucideIcons.shieldCheck,
              label: l10n.settingsPrivacyPolicy,
              value: l10n.settingsViewPrivacyPolicy,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.settingsDataAndCopyright,
          children: [
            _AboutDataItem(
              icon: LucideIcons.map,
              label: l10n.settingsMap,
              description: l10n.settingsMapDataDescription,
            ),
            _AboutDataItem(
              icon: LucideIcons.search,
              label: l10n.settingsWorks,
              description: l10n.settingsWorksDataDescription,
            ),
            _AboutDataItem(
              icon: LucideIcons.mapPin,
              label: l10n.settingsPilgrimageContent,
              description: l10n.settingsPilgrimageContentDescription,
            ),
            _AboutDataItem(
              icon: LucideIcons.image,
              label: l10n.settingsImageSource,
              description: l10n.settingsImageSourceDescription,
            ),
            _AboutDataItem(
              icon: LucideIcons.copyright,
              label: l10n.settingsCopyright,
              description: l10n.settingsCopyrightDescription,
              bottomSpacing: 0,
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: children,
      ),
    );
  }
}

class _ScaledDetailScaffold extends StatelessWidget {
  const _ScaledDetailScaffold({
    required this.title,
    required this.uiScale,
    required this.fontScale,
    required this.children,
  });

  final String title;
  final double uiScale;
  final double fontScale;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: appTextScalerFor(context, fontScale)),
      child: AppUiScaleView(
        scale: uiScale,
        child: _DetailScaffold(title: title, children: children),
      ),
    );
  }
}

extension _SettingsAspectRatioLabel on CameraPhotoAspectRatio {
  String get shortLabel {
    return switch (this) {
      CameraPhotoAspectRatio.auto => l10n.settingsAspectAuto,
      CameraPhotoAspectRatio.native => l10n.settingsAspectNative,
      CameraPhotoAspectRatio.landscape16x9 => '16:9',
      CameraPhotoAspectRatio.cinema21x9 => '21:9',
      CameraPhotoAspectRatio.standard4x3 => '4:3',
      CameraPhotoAspectRatio.photo3x2 => '3:2',
      CameraPhotoAspectRatio.portrait9x16 => '9:16',
      CameraPhotoAspectRatio.portrait9x21 => '9:21',
      CameraPhotoAspectRatio.portrait3x4 => '3:4',
      CameraPhotoAspectRatio.portrait2x3 => '2:3',
      CameraPhotoAspectRatio.square1x1 => '1:1',
      CameraPhotoAspectRatio.custom => l10n.settingsCustom,
    };
  }

  String get settingHintLabel {
    return switch (this) {
      CameraPhotoAspectRatio.auto => l10n.settingsRecommended,
      CameraPhotoAspectRatio.native => l10n.settingsAspectNative,
      CameraPhotoAspectRatio.landscape16x9 => l10n.settingsAspectWidescreen,
      CameraPhotoAspectRatio.cinema21x9 => l10n.settingsAspectCinema,
      CameraPhotoAspectRatio.standard4x3 => l10n.settingsAspectClassic,
      CameraPhotoAspectRatio.photo3x2 => l10n.settingsAspectCamera,
      CameraPhotoAspectRatio.portrait9x16 => l10n.settingsAspectPortrait,
      CameraPhotoAspectRatio.portrait9x21 => l10n.settingsAspectFullScreen,
      CameraPhotoAspectRatio.portrait3x4 => l10n.settingsAspectVertical,
      CameraPhotoAspectRatio.portrait2x3 => l10n.settingsAspectVertical,
      CameraPhotoAspectRatio.square1x1 => l10n.settingsAspectSquare,
      CameraPhotoAspectRatio.custom => l10n.settingsAspectCustomShort,
    };
  }
}

extension _ZoomStepSnap on double {
  double snapToZoomStep() => (this * 10).round() / 10;
}

class _SettingsChrome extends StatelessWidget {
  const _SettingsChrome({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: scheme.outline),
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.header,
    this.children = const [],
    super.key,
  });

  final _SettingsCardHeader header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return _SettingsChrome(
      child: Column(
        children: [
          header,
          for (final child in children) ...[
            ColoredBox(
              color: outline,
              child: const SizedBox(height: 1, width: double.infinity),
            ),
            child,
          ],
        ],
      ),
    );
  }
}

class _SettingsCardHeader extends StatelessWidget {
  const _SettingsCardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSurfaceVariant, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _cardTitleTextStyle.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: _secondaryTextStyle.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              LucideIcons.chevronRight,
              color: scheme.onSurfaceVariant,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index += 1) ...[
              if (index > 0)
                ColoredBox(color: outline, child: const SizedBox(width: 1)),
              Expanded(child: children[index]),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.value,
    this.swatch,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Widget? swatch;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            swatch ??
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 28,
                ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _titleTextStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.accentForeground,
                      fontSize: 13,
                      letterSpacing: 0,
                    ),
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

class _SummarySwitchTile extends StatelessWidget {
  const _SummarySwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _cardTitleTextStyle),
                const SizedBox(height: 3),
                Text(subtitle, style: _secondaryTextStyle),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
    this.titleSpacing = 12,
    this.showTitle = true,
  });

  final String title;
  final List<Widget> children;
  final double titleSpacing;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return _SettingsChrome(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: titleSpacing),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _SettingsSubheading extends StatelessWidget {
  const _SettingsSubheading({this.icon, required this.title});

  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
    if (icon == null) {
      return titleText;
    }
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: titleText),
      ],
    );
  }
}

class _NumberStepperSetting extends StatelessWidget {
  const _NumberStepperSetting({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.valueLabel,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final int step;
  final String valueLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrease = value > min;
    final canIncrease = value < max;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _titleTextStyle),
              const SizedBox(height: 3),
              Text(subtitle, style: _secondaryTextStyle),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NumberStepperIconButton(
              icon: LucideIcons.minus,
              tooltip: l10n.settingsDecrease,
              onTap: canDecrease
                  ? () => onChanged((value - step).clamp(min, max))
                  : null,
            ),
            Container(
              width: 58,
              height: 36,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                valueLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            _NumberStepperIconButton(
              icon: LucideIcons.plus,
              tooltip: l10n.settingsIncrease,
              onTap: canIncrease
                  ? () => onChanged((value + step).clamp(min, max))
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberStepperIconButton extends StatelessWidget {
  const _NumberStepperIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textSecondary.withValues(
            alpha: 0.5,
          ),
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 18),
      ),
    );
  }
}

class _AspectRatioGrid extends StatelessWidget {
  const _AspectRatioGrid({
    required this.ratios,
    required this.selectedRatio,
    required this.onSelected,
    this.customSelected = false,
    this.onCustomSelected,
  });

  final List<CameraPhotoAspectRatio> ratios;
  final CameraPhotoAspectRatio selectedRatio;
  final ValueChanged<CameraPhotoAspectRatio> onSelected;
  final bool customSelected;
  final VoidCallback? onCustomSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 8.0;
        final tileWidth = ((constraints.maxWidth - spacing * 3) / 4).clamp(
          72.0,
          112.0,
        );
        return Wrap(
          spacing: spacing,
          runSpacing: 10,
          children: [
            for (final ratio in ratios)
              SizedBox(
                width: tileWidth,
                child: _AspectRatioOption(
                  ratio: ratio,
                  selected: selectedRatio == ratio,
                  onTap: () => onSelected(ratio),
                ),
              ),
            SizedBox(
              width: tileWidth,
              child: _CustomAspectRatioOption(
                selected: customSelected,
                onTap: onCustomSelected,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FullReferenceCacheSection extends StatelessWidget {
  const _FullReferenceCacheSection();

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: l10n.settingsCacheContents,
      children: [
        _CacheTargetCard(
          icon: LucideIcons.images,
          title: l10n.settingsFullReferenceCache,
          subtitle: l10n.settingsFullReferenceCacheSubtitle,
        ),
      ],
    );
  }
}

class _CacheTargetCard extends StatelessWidget {
  const _CacheTargetCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accentForeground, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _titleTextStyle),
                const SizedBox(height: 4),
                Text(subtitle, style: _secondaryParagraphTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAspectRatioOption extends StatelessWidget {
  const _CustomAspectRatioOption({required this.selected, this.onTap});

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.accentForeground : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            l10n.settingsCustom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.onAccent : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomAspectRatioDialog extends StatefulWidget {
  const _CustomAspectRatioDialog({required this.settings});

  final AppSettings settings;

  @override
  State<_CustomAspectRatioDialog> createState() =>
      _CustomAspectRatioDialogState();
}

class _CustomAspectRatioDialogState extends State<_CustomAspectRatioDialog> {
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(
      text: _formatRatioNumber(widget.settings.customCameraAspectRatioWidth),
    );
    _heightController = TextEditingController(
      text: _formatRatioNumber(widget.settings.customCameraAspectRatioHeight),
    );
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _submit() {
    final width = double.tryParse(_widthController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    if (width == null || height == null || width <= 0 || height <= 0) {
      setState(() => _errorText = l10n.settingsEnterValidRatio);
      return;
    }
    Navigator.of(context).pop((width: width, height: height));
  }

  @override
  Widget build(BuildContext context) {
    return AppInputDialog(
      title: l10n.settingsCustomAspectRatio,
      errorText: _errorText,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AppDialogField(
              label: l10n.settingsWidth,
              child: TextField(
                onTapOutside: dismissKeyboardOnTapOutside,
                controller: _widthController,
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: appDialogInputDecoration(),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              ':',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: AppDialogField(
              label: l10n.settingsHeight,
              child: TextField(
                onTapOutside: dismissKeyboardOnTapOutside,
                controller: _heightController,
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: appDialogInputDecoration(),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
        ],
      ),
      confirmLabel: l10n.commonSave,
      onConfirm: _submit,
    );
  }
}

String _formatRatioNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}

class _AspectRatioOption extends StatelessWidget {
  const _AspectRatioOption({
    required this.ratio,
    required this.selected,
    required this.onTap,
  });

  final CameraPhotoAspectRatio ratio;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.accentForeground : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  Icon(LucideIcons.check, size: 13, color: AppColors.onAccent),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    ratio.shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.onAccent
                          : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              ratio.settingHintLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? AppColors.onAccent.withValues(alpha: 0.86)
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearancePanel extends StatelessWidget {
  const _AppearancePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _SettingsChrome(padding: const EdgeInsets.all(14), child: child);
  }
}

class _InlineSectionTitle extends StatelessWidget {
  const _InlineSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: _titleTextStyle.copyWith(color: scheme.onSurface)),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            subtitle,
            style: _captionTextStyle.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _ThemeColorOption extends StatelessWidget {
  const _ThemeColorOption({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AppThemePalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeSwatch(palette: palette, selected: selected),
          const SizedBox(height: 8),
          Text(
            palette.label,
            style: TextStyle(
              color: selected
                  ? AppColors.accentForeground
                  : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomThemeColorOption extends StatelessWidget {
  const _CustomThemeColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final CustomThemeColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ThemeColorButton(
      color: Color(color.value),
      label: color.name,
      selected: selected,
      icon: selected ? LucideIcons.check : null,
      onTap: onTap,
    );
  }
}

class _AddThemeColorOption extends StatelessWidget {
  const _AddThemeColorOption({
    required this.selected,
    required this.colorValue,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final int colorValue;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ThemeColorButton(
      color: Color(colorValue),
      label: label.trim().isEmpty ? l10n.settingsCustom : label.trim(),
      selected: selected,
      icon: LucideIcons.plus,
      onTap: onTap,
    );
  }
}

class _ThemeColorButton extends StatelessWidget {
  const _ThemeColorButton({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.isDark
        ? AppColors.foregroundOn(color)
        : color.computeLuminance() > 0.55
        ? AppColors.textPrimary
        : Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: selected ? 42 : 38,
            height: selected ? 42 : 38,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.accentForeground : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: icon == null
                  ? null
                  : Icon(icon, color: foreground, size: 18),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 58,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? AppColors.accentForeground
                    : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomThemeColorDialog extends StatefulWidget {
  const _CustomThemeColorDialog({required this.settings});

  final AppSettings settings;

  @override
  State<_CustomThemeColorDialog> createState() =>
      _CustomThemeColorDialogState();
}

class _CustomThemeColorDialogState extends State<_CustomThemeColorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _hexController;
  late Color _color;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _color = Color(widget.settings.customThemeColorValue);
    _nameController = TextEditingController(
      text: widget.settings.displayCustomThemeColorName,
    );
    _hexController = TextEditingController(text: _hexFromColor(_color));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  void _setColor(Color color, {bool syncHex = true}) {
    setState(() {
      _color = color.withAlpha(255);
      if (syncHex) {
        _hexController.text = _hexFromColor(_color);
      }
    });
  }

  void _applyHex() {
    final color = _colorFromHex(_hexController.text);
    if (color != null) {
      _setColor(color, syncHex: false);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final color = _colorFromHex(_hexController.text) ?? _color;
    if (name.isEmpty) {
      setState(() => _errorText = l10n.settingsEnterColorName);
      return;
    }
    Navigator.of(
      context,
    ).pop(CustomThemeColor(name: name, value: color.withAlpha(255).toARGB32()));
  }

  @override
  Widget build(BuildContext context) {
    return AppInputDialog(
      title: l10n.settingsCustomThemeColor,
      errorText: _errorText,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _hexFromColor(_color),
              style: TextStyle(
                color: _color.computeLuminance() > 0.5
                    ? AppColors.textPrimary
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppDialogField(
            label: l10n.settingsName,
            child: TextField(
              onTapOutside: dismissKeyboardOnTapOutside,
              controller: _nameController,
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              decoration: appDialogInputDecoration(),
            ),
          ),
          const SizedBox(height: 10),
          AppDialogField(
            label: l10n.settingsColorCode,
            child: TextField(
              onTapOutside: dismissKeyboardOnTapOutside,
              key: const ValueKey('custom-theme-color-hex-field'),
              controller: _hexController,
              decoration: appDialogInputDecoration(hintText: '#0F8B8D'),
              onChanged: (_) => _applyHex(),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: 14),
          _HsvColorPalette(color: _color, onChanged: _setColor),
        ],
      ),
      confirmLabel: l10n.settingsAdd,
      onConfirm: _submit,
    );
  }
}

class _HsvColorPalette extends StatelessWidget {
  const _HsvColorPalette({required this.color, required this.onChanged});

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final hsv = HSVColor.fromColor(color);
    return LayoutBuilder(
      builder: (context, constraints) {
        final paletteSize = math.min(constraints.maxWidth - 44, 230.0);

        void updateHueSaturation(Offset position) {
          final hue = (position.dx.clamp(0, paletteSize) / paletteSize * 360)
              .clamp(0.0, 359.999);
          final saturation =
              1 - position.dy.clamp(0, paletteSize) / paletteSize;
          onChanged(
            hsv
                .withHue(hue)
                .withSaturation(saturation)
                .toColor()
                .withAlpha(255),
          );
        }

        void updateValue(double y) {
          final value = 1 - y.clamp(0, paletteSize) / paletteSize;
          onChanged(hsv.withValue(value).toColor().withAlpha(255));
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              slider: true,
              label: l10n.settingsHueSaturation,
              value: l10n.settingsHueSaturationValue(
                hsv.hue.round(),
                (hsv.saturation * 100).round(),
              ),
              increasedValue: l10n.settingsHueSaturationValue(
                ((hsv.hue + 5) % 360).round(),
                (hsv.saturation * 100).round(),
              ),
              decreasedValue: l10n.settingsHueSaturationValue(
                ((hsv.hue - 5) % 360).round(),
                (hsv.saturation * 100).round(),
              ),
              onIncrease: () => onChanged(
                hsv.withHue((hsv.hue + 5) % 360).toColor().withAlpha(255),
              ),
              onDecrease: () => onChanged(
                hsv.withHue((hsv.hue - 5) % 360).toColor().withAlpha(255),
              ),
              child: GestureDetector(
                key: const ValueKey('custom-theme-color-palette'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    updateHueSaturation(details.localPosition),
                onPanDown: (details) =>
                    updateHueSaturation(details.localPosition),
                onPanUpdate: (details) =>
                    updateHueSaturation(details.localPosition),
                child: CustomPaint(
                  size: Size.square(paletteSize),
                  painter: _HueSaturationPalettePainter(hsv),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              slider: true,
              label: l10n.settingsBrightness,
              value: '${(hsv.value * 100).round()}%',
              increasedValue:
                  '${((hsv.value + 0.05).clamp(0.0, 1.0) * 100).round()}%',
              decreasedValue:
                  '${((hsv.value - 0.05).clamp(0.0, 1.0) * 100).round()}%',
              onIncrease: () => onChanged(
                hsv
                    .withValue((hsv.value + 0.05).clamp(0.0, 1.0))
                    .toColor()
                    .withAlpha(255),
              ),
              onDecrease: () => onChanged(
                hsv
                    .withValue((hsv.value - 0.05).clamp(0.0, 1.0))
                    .toColor()
                    .withAlpha(255),
              ),
              child: GestureDetector(
                key: const ValueKey('custom-theme-color-value'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => updateValue(details.localPosition.dy),
                onPanDown: (details) => updateValue(details.localPosition.dy),
                onPanUpdate: (details) => updateValue(details.localPosition.dy),
                child: CustomPaint(
                  size: Size(28, paletteSize),
                  painter: _ColorValuePainter(hsv),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HueSaturationPalettePainter extends CustomPainter {
  const _HueSaturationPalettePainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.save();
    canvas.clipRRect(shape);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF0000),
            Color(0xFFFFFF00),
            Color(0xFF00FF00),
            Color(0xFF00FFFF),
            Color(0xFF0000FF),
            Color(0xFFFF00FF),
            Color(0xFFFF0000),
          ],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white],
        ).createShader(rect),
    );
    canvas.restore();
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.border,
    );

    final selector = Offset(
      hsv.hue / 360 * size.width,
      (1 - hsv.saturation) * size.height,
    );
    canvas.drawCircle(
      selector,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white,
    );
    canvas.drawCircle(
      selector,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.textPrimary,
    );
  }

  @override
  bool shouldRepaint(_HueSaturationPalettePainter oldDelegate) {
    return oldDelegate.hsv.hue != hsv.hue ||
        oldDelegate.hsv.saturation != hsv.saturation;
  }
}

class _ColorValuePainter extends CustomPainter {
  const _ColorValuePainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 12.0;
    final rect = Rect.fromLTWH(
      (size.width - barWidth) / 2,
      0,
      barWidth,
      size.height,
    );
    final shape = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(
      shape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [hsv.withValue(1).toColor(), Colors.black],
        ).createShader(rect),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.border,
    );

    final selector = Offset(size.width / 2, (1 - hsv.value) * size.height);
    canvas.drawCircle(selector, 8, Paint()..color = Colors.white);
    canvas.drawCircle(
      selector,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.textPrimary,
    );
  }

  @override
  bool shouldRepaint(_ColorValuePainter oldDelegate) {
    return oldDelegate.hsv.hue != hsv.hue ||
        oldDelegate.hsv.saturation != hsv.saturation ||
        oldDelegate.hsv.value != hsv.value;
  }
}

String _hexFromColor(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

Color? _colorFromHex(String source) {
  final normalized = source.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(normalized)) {
    return null;
  }
  return Color(int.parse('FF$normalized', radix: 16));
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = selected ? AppColors.accentForeground : scheme.outline;
    final foreground = selected
        ? AppColors.accentForeground
        : scheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.08)
              : scheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScaleStepper extends StatelessWidget {
  const _ScaleStepper({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final double value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperIconButton(icon: LucideIcons.minus, onTap: onDecrease),
          Container(
            width: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: AppColors.border),
              ),
            ),
            child: Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          _StepperIconButton(icon: LucideIcons.plus, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _PercentScaleControl extends StatelessWidget {
  const _PercentScaleControl({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.tickLabels,
    required this.onChanged,
    this.showStepper = true,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final List<String> tickLabels;
  final ValueChanged<double> onChanged;
  final bool showStepper;

  double get _step => (max - min) / divisions;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(min, max);
    return Column(
      children: [
        if (showStepper) ...[
          Align(
            alignment: Alignment.centerRight,
            child: _ScaleStepper(
              value: clampedValue,
              onDecrease: () {
                onChanged((clampedValue - _step).clamp(min, max));
              },
              onIncrease: () {
                onChanged((clampedValue + _step).clamp(min, max));
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: clampedValue,
            label: '${(clampedValue * 100).round()}%',
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in tickLabels)
                Text(label, style: _captionTextStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  const _StepperIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  const _FontSizeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.accentForeground : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppColors.accentForeground
                  : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnitabiServiceRow extends StatelessWidget {
  const _AnitabiServiceRow({
    super.key,
    required this.icon,
    required this.title,
    required this.url,
    required this.onTap,
    this.source = AnitabiServiceSource.builtIn,
    this.tested = false,
    this.elapsedMs,
    this.testing = false,
  });

  final IconData icon;
  final String title;
  final String url;
  final AnitabiServiceSource source;
  final VoidCallback onTap;
  final bool tested;

  /// Round-trip time of a successful probe; null when it failed.
  final int? elapsedMs;
  final bool testing;

  @override
  Widget build(BuildContext context) {
    final succeeded = elapsedMs != null;
    final compactStatus = !tested
        ? null
        : succeeded
        ? l10n.settingsProbeSucceeded(elapsedMs!)
        : l10n.settingsProbeFailed;
    final statusColor = succeeded
        ? AppColors.accentForeground
        : AppColors.error;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentForeground, size: 22),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        switch (source) {
                          AnitabiServiceSource.builtIn =>
                            l10n.settingsSourceDefault,
                          AnitabiServiceSource.remote =>
                            l10n.settingsSourceRemote,
                          AnitabiServiceSource.custom => l10n.settingsCustom,
                        },
                        key: ValueKey('anitabi-service-source-$title'),
                        style: TextStyle(
                          color: source == AnitabiServiceSource.builtIn
                              ? AppColors.textSecondary
                              : AppColors.accentForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _secondaryTextStyle,
                  ),
                ],
              ),
            ),
            if (testing) ...[
              const SizedBox(width: 8),
              const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ] else if (compactStatus != null) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 108),
                child: Text(
                  compactStatus,
                  key: ValueKey('anitabi-service-status-$title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 2),
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnitabiServiceEntryRow extends StatelessWidget {
  const _AnitabiServiceEntryRow({
    super.key,
    required this.siteUrl,
    required this.summary,
    required this.onTap,
  });

  final String siteUrl;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(LucideIcons.network, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    siteUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _secondaryTextStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapUrlRow extends StatelessWidget {
  const _MapUrlRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _secondaryTextStyle,
              ),
            ),
            const SizedBox(width: 10),
            Icon(LucideIcons.edit, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MapSourceGrid extends StatelessWidget {
  const _MapSourceGrid({
    required this.selectedProvider,
    required this.onSelected,
  });

  final MapTileProvider selectedProvider;
  final ValueChanged<MapTileProvider> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final option in mapTileProviderOptions)
              SizedBox(
                width: tileWidth,
                child: _MapSourceOptionCard(
                  option: option,
                  selected: selectedProvider == option.provider,
                  onTap: () => onSelected(option.provider),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OpenFreeMapStyleGrid extends StatelessWidget {
  const _OpenFreeMapStyleGrid({
    required this.selectedStyle,
    required this.onSelected,
  });

  final OpenFreeMapStyle selectedStyle;
  final ValueChanged<OpenFreeMapStyle> onSelected;

  @override
  Widget build(BuildContext context) {
    return _CompactOptionWrap(
      children: [
        for (final option in openFreeMapStyleOptions)
          _CompactOptionChip(
            label: option.label,
            selected: selectedStyle == option.style,
            icon: LucideIcons.layers,
            onTap: () => onSelected(option.style),
          ),
      ],
    );
  }
}

class _AnitabiImageSourceGrid extends StatelessWidget {
  const _AnitabiImageSourceGrid({
    required this.selectedSource,
    required this.onSelected,
  });

  final AnitabiImageSource selectedSource;
  final ValueChanged<AnitabiImageSource> onSelected;

  @override
  Widget build(BuildContext context) {
    return _CompactOptionWrap(
      children: [
        for (final source in AnitabiImageSource.values)
          _CompactOptionChip(
            label: _anitabiImageSourceLabel(source),
            selected: selectedSource == source,
            icon: _anitabiImageSourceIcon(source),
            onTap: () => onSelected(source),
          ),
      ],
    );
  }
}

class _CompactOptionWrap extends StatelessWidget {
  const _CompactOptionWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}

class _CompactOptionChip extends StatelessWidget {
  const _CompactOptionChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.accentForeground : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? LucideIcons.check : icon,
              color: selected ? AppColors.onAccent : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.onAccent : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSourceOptionCard extends StatelessWidget {
  const _MapSourceOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final MapTileProviderOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.accentForeground : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? LucideIcons.check : _mapProviderIcon(option.provider),
              color: selected ? AppColors.onAccent : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.onAccent
                          : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _mapProviderHint(option.provider),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.onAccent.withValues(alpha: 0.82)
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
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

class _NavigationAppGrid extends StatelessWidget {
  const _NavigationAppGrid({
    required this.selectedApp,
    required this.onSelected,
  });

  final NavigationApp selectedApp;
  final ValueChanged<NavigationApp> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final app in NavigationApp.values)
              SizedBox(
                width: tileWidth,
                child: _NavigationAppOptionCard(
                  app: app,
                  selected: selectedApp == app,
                  onTap: () => onSelected(app),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NavigationAppOptionCard extends StatelessWidget {
  const _NavigationAppOptionCard({
    required this.app,
    required this.selected,
    required this.onTap,
  });

  final NavigationApp app;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.accentForeground : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? LucideIcons.check : _navigationAppIcon(app),
              color: selected ? AppColors.onAccent : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.onAccent
                          : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _navigationAppHint(app),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.onAccent.withValues(alpha: 0.82)
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
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

IconData _mapProviderIcon(MapTileProvider provider) {
  return switch (provider) {
    MapTileProvider.openFreeMap => LucideIcons.map,
    MapTileProvider.openStreetMap => LucideIcons.globe,
    MapTileProvider.customXyz => LucideIcons.grid3X3,
    MapTileProvider.customMapLibreStyle => LucideIcons.braces,
  };
}

IconData _navigationAppIcon(NavigationApp app) {
  return switch (app) {
    NavigationApp.googleMaps => LucideIcons.compass,
    NavigationApp.amap => LucideIcons.navigation,
    NavigationApp.appleMaps => LucideIcons.map,
    NavigationApp.baiduMaps => LucideIcons.signpost,
  };
}

String _navigationAppHint(NavigationApp app) {
  return switch (app) {
    NavigationApp.googleMaps => l10n.settingsNavDefault,
    NavigationApp.amap => l10n.settingsNavPopularInChina,
    NavigationApp.appleMaps => l10n.settingsNavIosNative,
    NavigationApp.baiduMaps => l10n.settingsNavCity,
  };
}

String _navigationAppDescription(NavigationApp app) {
  return switch (app) {
    NavigationApp.googleMaps => l10n.settingsNavGoogleDescription,
    NavigationApp.appleMaps => l10n.settingsNavAppleDescription,
    NavigationApp.amap => l10n.settingsNavAmapDescription,
    NavigationApp.baiduMaps => l10n.settingsNavBaiduDescription,
  };
}

String _mapProviderHint(MapTileProvider provider) {
  return switch (provider) {
    MapTileProvider.openFreeMap => l10n.settingsMapRecommendedDefault,
    MapTileProvider.openStreetMap => l10n.settingsMapStandardTiles,
    MapTileProvider.customXyz => l10n.settingsMapTileTemplate,
    MapTileProvider.customMapLibreStyle => l10n.settingsMapStyleUrl,
  };
}

String _anitabiServiceSummary(AppSettings settings) {
  final sources = {
    for (final field in AnitabiServiceField.values)
      settings.resolvedAnitabiAddress(field).source,
  };
  if (sources.contains(AnitabiServiceSource.custom)) {
    return l10n.settingsAnitabiSummaryCustom;
  }
  if (sources.contains(AnitabiServiceSource.remote)) {
    return l10n.settingsAnitabiSummaryRemote;
  }
  return l10n.settingsAnitabiSummaryDefault;
}

String _anitabiImageSourceLabel(AnitabiImageSource source) {
  return switch (source) {
    AnitabiImageSource.auto => l10n.settingsImageSourceAuto,
    AnitabiImageSource.official => l10n.settingsImageSourceOfficial,
    AnitabiImageSource.mirror => l10n.settingsImageSourceMirror,
  };
}

String _anitabiImageSourceDescription(AppSettings settings) {
  final config = settings.anitabiServiceConfig;
  return switch (settings.anitabiImageSource) {
    AnitabiImageSource.auto => l10n.settingsImageSourceAutoDescription(
      config.officialImageBaseUrl,
      config.mirrorImageBaseUrl,
    ),
    AnitabiImageSource.official => l10n.settingsImageSourceFixedDescription(
      config.officialImageBaseUrl,
    ),
    AnitabiImageSource.mirror => l10n.settingsImageSourceFixedDescription(
      config.mirrorImageBaseUrl,
    ),
  };
}

IconData _anitabiImageSourceIcon(AnitabiImageSource source) {
  return switch (source) {
    AnitabiImageSource.auto => LucideIcons.sparkles,
    AnitabiImageSource.official => LucideIcons.image,
    AnitabiImageSource.mirror => LucideIcons.arrowLeftRight,
  };
}

class _AboutInfoTile extends StatelessWidget {
  const _AboutInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: _captionTextStyle),
                  const SizedBox(height: 2),
                  if (onTap == null)
                    CopyableText(
                      text: value,
                      copyLabel: value,
                      style: const TextStyle(fontSize: 14, letterSpacing: 0),
                    )
                  else
                    Text(
                      value,
                      style: const TextStyle(fontSize: 14, letterSpacing: 0),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutDataItem extends StatelessWidget {
  const _AboutDataItem({
    required this.icon,
    required this.label,
    required this.description,
    this.bottomSpacing = 12,
  });

  final IconData icon;
  final String label;
  final String description;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _captionTextStyle),
                const SizedBox(height: 2),
                Text(description, style: _secondaryParagraphTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppIconMark extends StatelessWidget {
  const _AppIconMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Image.asset('icon.jpg', fit: BoxFit.cover),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.palette,
    this.selected = false,
    this.customColorValue,
  });

  final AppThemePalette palette;
  final bool selected;
  final int? customColorValue;

  @override
  Widget build(BuildContext context) {
    final color = switch (palette) {
      AppThemePalette.classicGreen => AppColors.classicGreen,
      AppThemePalette.deepBlue => AppColors.deepBlue,
      AppThemePalette.cherryPink => AppColors.cherryPink,
      AppThemePalette.twilightPurple => AppColors.twilightPurple,
      AppThemePalette.miriaYellow => AppColors.miriaYellow,
      AppThemePalette.graphite => AppColors.graphite,
      AppThemePalette.aurora => Color(
        customColorValue ?? AppColors.customAccentValue,
      ),
    };
    return Container(
      width: selected ? 42 : 38,
      height: selected ? 42 : 38,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accentForeground : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: selected
            ? Icon(
                LucideIcons.check,
                color: AppColors.isDark
                    ? AppColors.foregroundOn(color)
                    : AppColors.onAccent,
                size: 18,
              )
            : null,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: CopyableText(
            text: text,
            copyLabel: text,
            style: const TextStyle(fontSize: 14, letterSpacing: 0),
          ),
        ),
      ],
    );
  }
}

TextStyle get _cardTitleTextStyle => TextStyle(
  color: AppColors.textPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w900,
  letterSpacing: 0,
);

TextStyle get _titleTextStyle => TextStyle(
  color: AppColors.textPrimary,
  fontSize: 15,
  fontWeight: FontWeight.w800,
  letterSpacing: 0,
);

TextStyle get _secondaryTextStyle =>
    TextStyle(color: AppColors.textSecondary, fontSize: 13, letterSpacing: 0);

TextStyle get _captionTextStyle => TextStyle(
  color: AppColors.textSecondary,
  fontSize: 12,
  fontWeight: FontWeight.w700,
  letterSpacing: 0,
);

TextStyle get _secondaryParagraphTextStyle => TextStyle(
  color: AppColors.textSecondary,
  fontSize: 13,
  height: 1.45,
  letterSpacing: 0,
);
