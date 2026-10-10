import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../plan/pilgrimage_models.dart';
import 'map_colors.dart';
import 'localized_map_style.dart';
import 'synced_maplibre_layer.dart';
import '../l10n/l10n.dart';

const openFreeMapStyleUrl = 'https://tiles.openfreemap.org/styles/liberty';
const readableDarkMapStyleAsset = 'assets/maps/readable_dark.json';

String darkMapStyleAsset(OpenFreeMapStyle style) =>
    style == OpenFreeMapStyle.dark
    ? readableDarkMapStyleAsset
    : 'assets/maps/${style.name}_dark.json';
const openStreetMapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const mapUserAgentPackageName = 'io.github.kurocat.koma';

class OpenFreeMapStyleOption {
  const OpenFreeMapStyleOption({
    required this.style,
    required this.label,
    required this.styleUrl,
  });

  final OpenFreeMapStyle style;
  final String label;
  final String styleUrl;

  String get description => switch (style) {
    OpenFreeMapStyle.liberty => l10n.mapTileConfigLibertyDescription,
    OpenFreeMapStyle.bright => l10n.mapTileConfigBrightDescription,
    OpenFreeMapStyle.positron => l10n.mapTileConfigPositronDescription,
    OpenFreeMapStyle.dark => l10n.mapTileConfigDarkDescription,
    OpenFreeMapStyle.fiord => l10n.mapTileConfigFiordDescription,
  };
}

class MapTileProviderOption {
  const MapTileProviderOption({required this.provider});

  final MapTileProvider provider;

  String get label => switch (provider) {
    MapTileProvider.openFreeMap => 'OpenFreeMap',
    MapTileProvider.openStreetMap => 'OpenStreetMap',
    MapTileProvider.customXyz => l10n.mapTileConfigCustomXyzLabel,
    MapTileProvider.customMapLibreStyle =>
      l10n.mapTileConfigCustomMapLibreLabel,
  };

  String get description => switch (provider) {
    MapTileProvider.openFreeMap => l10n.mapTileConfigOpenFreeMapDescription,
    MapTileProvider.openStreetMap => l10n.mapTileConfigOpenStreetMapDescription,
    MapTileProvider.customXyz => l10n.mapTileConfigCustomXyzDescription(
      '{z}/{x}/{y}',
    ),
    MapTileProvider.customMapLibreStyle =>
      l10n.mapTileConfigCustomMapLibreDescription,
  };
}

const openFreeMapStyleOptions = [
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.liberty,
    label: 'Liberty',
    styleUrl: 'https://tiles.openfreemap.org/styles/liberty',
  ),
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.bright,
    label: 'Bright',
    styleUrl: 'https://tiles.openfreemap.org/styles/bright',
  ),
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.positron,
    label: 'Positron',
    styleUrl: 'https://tiles.openfreemap.org/styles/positron',
  ),
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.dark,
    label: 'Dark',
    styleUrl: 'https://tiles.openfreemap.org/styles/dark',
  ),
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.fiord,
    label: 'Fiord',
    styleUrl: 'https://tiles.openfreemap.org/styles/fiord',
  ),
];

const mapTileProviderOptions = [
  MapTileProviderOption(provider: MapTileProvider.openFreeMap),
  MapTileProviderOption(provider: MapTileProvider.openStreetMap),
  MapTileProviderOption(provider: MapTileProvider.customXyz),
  MapTileProviderOption(provider: MapTileProvider.customMapLibreStyle),
];

OpenFreeMapStyleOption openFreeMapStyleOption(OpenFreeMapStyle style) {
  return openFreeMapStyleOptions.firstWhere(
    (option) => option.style == style,
    orElse: () => openFreeMapStyleOptions.first,
  );
}

MapTileProviderOption mapTileProviderOption(MapTileProvider provider) {
  return mapTileProviderOptions.firstWhere(
    (option) => option.provider == provider,
    orElse: () => mapTileProviderOptions.first,
  );
}

bool mapProviderUsesMapLibre(MapTileProvider provider) {
  return provider == MapTileProvider.openFreeMap ||
      provider == MapTileProvider.customMapLibreStyle;
}

String mapLibreStyleUrl(AppSettings settings) {
  if (settings.mapTileProvider == MapTileProvider.customMapLibreStyle) {
    final custom = settings.customMapLibreStyleUrl.trim();
    if (_isHttpUrl(custom)) {
      return custom;
    }
  }
  return openFreeMapStyleOption(settings.openFreeMapStyle).styleUrl;
}

String resolvedMapLibreStyle(AppSettings settings, {required bool dark}) {
  if (settings.mapTileProvider != MapTileProvider.openFreeMap) {
    return mapLibreStyleUrl(settings);
  }
  if (usesDarkMapStyle(settings, dark: dark)) {
    return darkMapStyleAsset(settings.openFreeMapStyle);
  }
  return openFreeMapStyleOption(settings.openFreeMapStyle).styleUrl;
}

bool usesDarkMapStyle(AppSettings settings, {required bool dark}) {
  if (settings.mapTileProvider != MapTileProvider.openFreeMap) return false;
  // Dark is a named, intrinsically dark style, not a substitute for other styles.
  if (settings.openFreeMapStyle == OpenFreeMapStyle.dark) return true;
  return switch (settings.mapAppearance) {
    MapAppearance.automatic => dark,
    MapAppearance.light => false,
    MapAppearance.dark => true,
  };
}

String xyzTileUrl(AppSettings settings) {
  if (settings.mapTileProvider == MapTileProvider.customXyz) {
    final custom = settings.customXyzTileUrl.trim();
    if (isValidXyzTileUrl(custom)) {
      return custom;
    }
  }
  return openStreetMapTileUrl;
}

Color configuredMapRouteColor(AppSettings settings, {required bool dark}) {
  return MapColors.readable(
    AppColors.accent,
    dark:
        dark ||
        usesDarkMapStyle(settings, dark: dark) ||
        // The upstream Fiord preset is also intrinsically dark.
        (settings.mapTileProvider == MapTileProvider.openFreeMap &&
            settings.openFreeMapStyle == OpenFreeMapStyle.fiord),
  );
}

Widget configuredNavigationMapTileLayer(
  AppSettings settings, {
  required bool dark,
}) {
  return configuredMapTileLayer(settings, dark: dark);
}

Widget configuredMapTileLayer(AppSettings settings, {bool? dark}) {
  final style = resolvedMapLibreStyle(settings, dark: dark ?? AppColors.isDark);
  final layerKey = ValueKey('${mapTileConfigSignature(settings)}|$style');
  if (mapProviderUsesMapLibre(settings.mapTileProvider) &&
      !_isFlutterWidgetTest) {
    // OpenFreeMap styles have a known label layout that can be localized; a
    // user-supplied MapLibre style is used exactly as provided.
    if (settings.mapTileProvider == MapTileProvider.openFreeMap) {
      return LocalizedMapLibreLayer(key: layerKey, style: style);
    }
    return SyncedMapLibreLayer(key: layerKey, initStyle: style);
  }
  return configuredRasterTileLayer(settings, key: layerKey);
}

/// Starts loading the localized OpenFreeMap style for [settings] so the first
/// map does not wait for it.
void warmConfiguredMapStyle(AppSettings settings, {required bool dark}) {
  if (_isFlutterWidgetTest ||
      settings.mapTileProvider != MapTileProvider.openFreeMap) {
    return;
  }
  unawaited(
    LocalizedMapStyleCache.instance.load(
      resolvedMapLibreStyle(settings, dark: dark),
    ),
  );
}

TileLayer configuredRasterTileLayer(AppSettings settings, {Key? key}) {
  return TileLayer(
    key: key,
    urlTemplate: xyzTileUrl(settings),
    userAgentPackageName: mapUserAgentPackageName,
  );
}

String mapTileConfigSignature(AppSettings settings) {
  return [
    settings.mapTileProvider.name,
    settings.openFreeMapStyle.name,
    settings.mapAppearance.name,
    settings.customXyzTileUrl.trim(),
    settings.customMapLibreStyleUrl.trim(),
  ].join('|');
}

RichAttributionWidget configuredMapAttribution(AppSettings settings) {
  final provider = settings.mapTileProvider;
  if (mapProviderUsesMapLibre(provider)) {
    return RichAttributionWidget(
      attributions: [
        TextSourceAttribution(
          'OpenMapTiles',
          onTap: () => launchUrl(Uri.parse('https://openmaptiles.org/')),
        ),
        TextSourceAttribution(
          '© OpenStreetMap contributors',
          onTap: () =>
              launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
        ),
        TextSourceAttribution(
          'OpenFreeMap / OpenMapTiles contributors',
          onTap: () {
            launchUrl(
              Uri.parse('https://openfreemap.org/'),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      ],
    );
  }
  return RichAttributionWidget(
    attributions: [
      TextSourceAttribution(
        'OpenStreetMap contributors',
        onTap: () {
          launchUrl(
            Uri.parse('https://www.openstreetmap.org/copyright'),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
    ],
  );
}

String? validateMapTileSettings(AppSettings settings) {
  return switch (settings.mapTileProvider) {
    MapTileProvider.customXyz =>
      isValidXyzTileUrl(settings.customXyzTileUrl.trim())
          ? null
          : l10n.mapTileConfigCustomXyzInvalid('{z}', '{x}', '{y}'),
    MapTileProvider.customMapLibreStyle =>
      _isHttpUrl(settings.customMapLibreStyleUrl.trim())
          ? null
          : l10n.mapTileConfigCustomMapLibreInvalid,
    _ => null,
  };
}

bool isValidXyzTileUrl(String value) {
  return _isHttpUrl(value) &&
      value.contains('{z}') &&
      value.contains('{x}') &&
      value.contains('{y}');
}

bool _isHttpUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}

bool get _isFlutterWidgetTest {
  return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgets');
}
