import 'package:flutter/foundation.dart';
import 'package:maplibre/maplibre.dart';

import '../plan/auto_areas.dart';
import '../plan/pilgrimage_models.dart';
import 'map_tile_config.dart';

/// Spots within this distance share one downloaded map region.
const _regionLinkMeters = 2000.0;

/// Margin around a region's spots, in degrees (about 1 km).
const _regionPadding = 0.01;

/// OpenFreeMap has no detail beyond zoom 14; closer zooms reuse those tiles.
const _minZoom = 10.0;
const _maxZoom = 14.0;

/// Whether this device and map setting can save the map for offline use.
bool canSaveMapOffline(AppSettings settings) =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) &&
    mapProviderUsesMapLibre(settings.mapTileProvider);

/// Downloads the base map around [plan]'s spots so it shows without signal,
/// replacing what was saved for the plan before. [onProgress] gets the share
/// done, 0 to 1. Returns false when nothing could be saved.
Future<bool> saveMapForOffline({
  required PilgrimagePlan plan,
  required AppSettings settings,
  void Function(double done)? onProgress,
}) async {
  if (!canSaveMapOffline(settings) || !OfflineManager.isSupported) {
    return false;
  }
  final clusters = clusterSpotsByDistance(
    plan.points.where((point) => point.hasCoordinate).toList(),
    linkMeters: _regionLinkMeters,
  );
  if (clusters.isEmpty) return false;

  final manager = await OfflineManager.createInstance();
  try {
    for (final region in await manager.listOfflineRegions()) {
      if (region.metadata['planId'] == plan.id) {
        await manager.deleteRegion(regionId: region.id);
      }
    }
    final pixelRatio =
        PlatformDispatcher.instance.views.firstOrNull?.devicePixelRatio ?? 2;
    var saved = 0;
    for (final (index, cluster) in clusters.indexed) {
      final latitudes = cluster.map((spot) => spot.position.latitude);
      final longitudes = cluster.map((spot) => spot.position.longitude);
      try {
        await for (final progress in manager.downloadRegion(
          mapStyleUrl: mapLibreStyleUrl(settings),
          bounds: LngLatBounds(
            longitudeWest: longitudes.reduce(_min) - _regionPadding,
            longitudeEast: longitudes.reduce(_max) + _regionPadding,
            latitudeSouth: latitudes.reduce(_min) - _regionPadding,
            latitudeNorth: latitudes.reduce(_max) + _regionPadding,
          ),
          minZoom: _minZoom,
          maxZoom: _maxZoom,
          pixelDensity: pixelRatio,
          metadata: {'planId': plan.id},
        )) {
          onProgress?.call(
            (index + (progress.progress ?? 0)) / clusters.length,
          );
          if (progress.downloadCompleted) {
            saved++;
            break;
          }
        }
      } on Object catch (error) {
        // One region failing (e.g. the connection dropped) shouldn't stop
        // the others.
        debugPrint('Offline map region failed: $error');
      }
    }
    onProgress?.call(1);
    return saved > 0;
  } finally {
    manager.dispose();
  }
}

double _min(double a, double b) => a < b ? a : b;
double _max(double a, double b) => a > b ? a : b;
