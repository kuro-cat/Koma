import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import 'map_colors.dart';
import 'map_marker_scale.dart';
import '../widgets/snackbar_helper.dart';
import '../camera_reference/camerawesome_reference_screen.dart';
import '../point_detail/point_detail_sheet.dart';
import '../plan/add_points_screen.dart';
import '../plan/plan_group_utils.dart';
import '../plan/plan_group_picker_sheet.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../plan/reference_image_status.dart';
import '../records/point_visit_records_screen.dart';
import '../records/visit_record_detail_screen.dart';
import '../utils/selected_item_order.dart';
import '../widgets/copyable_text.dart';
import '../widgets/app_motion.dart';
import '../widgets/split_navigation_button.dart';
import '../widgets/image_viewer_screen.dart';
import '../widgets/auto_caching_reference_thumbnail.dart';
import '../widgets/image_load_limiter.dart';
import '../widgets/map_thumbnail_marker.dart';
import 'navigation_route_confirm_screen.dart';
import 'map_navigation_launcher.dart';
import 'map_layers_panel.dart';
import 'map_marker_clustering.dart';
import 'map_tile_config.dart';
import 'map_location_tracker.dart';
import '../widgets/reference_thumbnail_stub.dart'
    if (dart.library.io) '../widgets/reference_thumbnail_io.dart';
import '../settings/app_settings_updater.dart';
import '../l10n/l10n.dart';
import '../widgets/rules.dart';

class PilgrimageMapScreen extends StatefulWidget {
  const PilgrimageMapScreen({
    required this.controller,
    required this.settings,
    this.isActive = true,
    this.locationTracker,
    this.onSettingsChanged,
    super.key,
  });

  final PilgrimagePlanController controller;
  final AppSettings settings;
  final bool isActive;
  final MapLocationTracker? locationTracker;

  /// Stores settings changed from the 图层 panel; resolves to false when
  /// they could not be saved.
  final Future<bool> Function(AppSettings settings)? onSettingsChanged;

  @override
  State<PilgrimageMapScreen> createState() => _PilgrimageMapScreenState();
}

class _OverlapPointBrowser {
  _OverlapPointBrowser({required List<String> pointIds})
    : pointIds = List.unmodifiable(pointIds);

  final List<String> pointIds;
}

class _PilgrimageMapScreenState extends State<PilgrimageMapScreen>
    with MapLocationLifecycle<PilgrimageMapScreen> {
  static const Duration _thumbnailBoundsDebounceDuration = Duration(
    milliseconds: 180,
  );

  final MapController _mapController = MapController();
  final MapNavigationLauncher _navigationLauncher =
      const MapNavigationLauncher();

  LatLng? _currentLocation;
  bool _isLocating = false;
  late final _locationTracker = widget.locationTracker ?? MapLocationTracker();
  String? _locationError;

  @override
  bool get locationPageEnabled => widget.isActive;

  @override
  void onLocationActivityChanged(bool active) => _locationTracker.configure(
    active: active,
    continuous: widget.settings.continuousMapLocation,
  );

  @override
  void initState() {
    super.initState();
    _locationTracker.addListener(_onLocationChanged);
  }

  void _onLocationChanged() {
    if (!mounted) return;
    final position = _locationTracker.position;
    final nextError = _locationTracker.error;
    if (nextError != null &&
        nextError != _locationError &&
        locationPageActive) {
      _showSnackBar(nextError);
    }
    setState(() {
      if (position != null) {
        _currentLocation = LatLng(position.latitude, position.longitude);
      }
      _isLocating = _locationTracker.locating;
      _locationError = nextError;
    });
  }

  bool get _showThumbnailMarkers => widget.settings.mapShowThumbnailMarkers;
  int _selectedGroupIndex = 0;
  _OverlapPointBrowser? _overlapPointBrowser;
  final ValueNotifier<LatLngBounds?> _visibleBoundsNotifier = ValueNotifier(
    null,
  );
  Timer? _thumbnailBoundsDebounce;
  late final ImageLoadLimiter _thumbnailLoadLimiter = ImageLoadLimiter(
    widget.settings.mapThumbnailConcurrentLoads,
  );

  PilgrimagePlanController get _controller => widget.controller;

  @override
  void didUpdateWidget(covariant PilgrimageMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncLocationActivity(force: true);
    if (oldWidget.settings.mapShowThumbnailMarkers !=
        widget.settings.mapShowThumbnailMarkers) {
      _syncThumbnailBounds();
    }
    if (oldWidget.settings.mapThumbnailConcurrentLoads !=
        widget.settings.mapThumbnailConcurrentLoads) {
      _thumbnailLoadLimiter.maxConcurrent =
          widget.settings.mapThumbnailConcurrentLoads;
    }
  }

  /// Thumbnails load for the visible area only; start or stop tracking it.
  void _syncThumbnailBounds() {
    if (!_showThumbnailMarkers) {
      _thumbnailBoundsDebounce?.cancel();
      _visibleBoundsNotifier.value = null;
      return;
    }
    try {
      _visibleBoundsNotifier.value = _mapController.camera.visibleBounds;
    } catch (_) {
      _visibleBoundsNotifier.value = null;
    }
  }

  Future<bool> _updateSettings(
    AppSettings Function(AppSettings settings) update,
  ) async {
    // Through the shell, on its current settings: two quick switches in
    // one frame would otherwise both start from the same widget.settings.
    final shell = AppSettingsUpdater.handler;
    if (shell != null) {
      return shell(update);
    }
    final save = widget.onSettingsChanged;
    if (save == null) {
      return false;
    }
    return save(update(widget.settings));
  }

  void _openLayers(BuildContext anchorContext) {
    final settings = widget.settings;
    unawaited(
      showMapLayersPanel(
        anchorContext,
        settings: settings,
        toggles: [
          MapLayerToggle(
            id: 'thumbnails',
            label: l10n.pilgrimageMapLayerThumbnails,
            icon: LucideIcons.image,
            value: settings.mapShowThumbnailMarkers,
            onChanged: (value) => _updateSettings(
              (s) => s.copyWith(mapShowThumbnailMarkers: value),
            ),
          ),
          MapLayerToggle(
            id: 'group-areas',
            label: l10n.pilgrimageMapLayerAreas,
            icon: LucideIcons.pentagon,
            value: settings.mapShowGroupAreas,
            onChanged: (value) =>
                _updateSettings((s) => s.copyWith(mapShowGroupAreas: value)),
          ),
          MapLayerToggle(
            id: 'hide-completed',
            label: l10n.pilgrimageMapLayerHideCompleted,
            icon: LucideIcons.circleCheck,
            value: settings.hideCompletedPointsOnMap,
            onChanged: (value) => _updateSettings(
              (s) => s.copyWith(hideCompletedPointsOnMap: value),
            ),
          ),
          MapLayerToggle(
            id: 'clustering',
            label: l10n.pilgrimageMapLayerClustering,
            icon: LucideIcons.group,
            value: settings.mapMarkerClusteringEnabled,
            onChanged: (value) => _updateSettings(
              (s) => s.copyWith(mapMarkerClusteringEnabled: value),
            ),
          ),
          MapLayerToggle(
            id: 'continuous-location',
            label: l10n.pilgrimageMapLayerContinuousLocation,
            description: l10n.pilgrimageMapLayerContinuousLocationHint,
            icon: LucideIcons.locateFixed,
            value: settings.continuousMapLocation,
            onChanged: (value) => _updateSettings(
              (s) => s.copyWith(continuousMapLocation: value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationTracker.removeListener(_onLocationChanged);
    _locationTracker.dispose();
    _thumbnailBoundsDebounce?.cancel();
    _visibleBoundsNotifier.dispose();
    super.dispose();
  }

  Future<void> _locateUser() async {
    final position = await _locationTracker.locate();
    if (mounted && locationPageActive && position != null) {
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        _mapController.camera.zoom,
      );
    }
  }

  Future<void> _openExternalNavigation(PilgrimagePoint point) async {
    final app = widget.settings.navigationApp;
    final opened = await _navigationLauncher.openWalking(point, app);
    if (!opened) {
      _showSnackBar(l10n.pilgrimageMapOpenAppFailed(app.label));
    }
  }

  void _openInAppNavigation(PilgrimagePoint point) {
    NavigationRouteConfirmScreen.openForPoint(
      context,
      point: point,
      settings: widget.settings,
      buckets: planGroupBuckets(
        _controller.plan,
        _controller.completedPointIds,
      ),
      planController: _controller,
    );
  }

  void _selectPoint(
    PilgrimagePoint point, {
    bool preserveOverlapBrowser = false,
    _OverlapPointBrowser? overlapPointBrowser,
  }) {
    final groups = planGroupBuckets(
      _controller.plan,
      _controller.completedPointIds,
    );
    final groupIndex = groups.indexWhere((group) {
      if (point.groupId == null) {
        return group.isUngrouped;
      }
      return group.id == point.groupId;
    });
    setState(() {
      if (overlapPointBrowser != null) {
        _overlapPointBrowser = overlapPointBrowser;
      } else if (!preserveOverlapBrowser) {
        _overlapPointBrowser = null;
      }
      if (groupIndex >= 0) {
        _selectedGroupIndex = groupIndex;
      }
    });
    _controller.selectPoint(point);
  }

  void _openOverlapPointBrowser(
    List<PilgrimagePoint> points,
    List<PlanGroupBucket> groups,
  ) {
    final orderedPoints = orderMapClusterItems<PilgrimagePoint>(
      items: points,
      planOrder: groups.expand((group) => group.points),
      idOf: (point) => point.id,
    );
    if (orderedPoints.isEmpty) {
      return;
    }
    if (orderedPoints.length == 1) {
      _selectPoint(orderedPoints.single);
      return;
    }

    _selectPoint(
      orderedPoints.first,
      overlapPointBrowser: _OverlapPointBrowser(
        pointIds: orderedPoints.map((point) => point.id).toList(),
      ),
    );
  }

  void _moveOverlapPoint(int offset) {
    final browser = _overlapPointBrowser;
    if (browser == null || browser.pointIds.length < 2) {
      return;
    }
    final points = <PilgrimagePoint>[];
    for (final pointId in browser.pointIds) {
      final point = _controller.pointById(pointId);
      if (point != null && point.hasCoordinate) {
        points.add(point);
      }
    }
    if (points.length < 2) {
      setState(() {
        _overlapPointBrowser = null;
      });
      return;
    }

    final selectedId = _controller.selectedPoint?.id;
    final selectedIndex = points.indexWhere((point) => point.id == selectedId);
    final currentIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final nextIndex = nextMapOverlapIndex(
      currentIndex: currentIndex,
      offset: offset,
      total: points.length,
    );
    _selectPoint(points[nextIndex], preserveOverlapBrowser: true);
  }

  void _centerPoint(PilgrimagePoint point) {
    if (!point.hasCoordinate) {
      return;
    }
    _mapController.move(point.position, _mapController.camera.zoom);
  }

  void _setCurrentPoint(PilgrimagePoint point) {
    _controller.setCurrentPoint(point);
    _selectPoint(point);
    _centerPoint(point);
  }

  void _selectGroup(int index, List<PlanGroupBucket> groups) {
    final nextIndex = index.clamp(0, groups.length - 1);
    final group = groups[nextIndex];
    setState(() {
      _selectedGroupIndex = nextIndex;
      _overlapPointBrowser = null;
    });
    final positions = [
      for (final point in group.points)
        if (point.hasCoordinate) point.position,
    ];
    if (positions.length == 1) {
      _mapController.move(positions.single, 15);
    } else if (positions.length > 1) {
      // A whole city can be an area: show all of it.
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: positions,
          padding: const EdgeInsets.fromLTRB(48, 120, 48, 220),
          maxZoom: 16,
        ),
      );
    }
  }

  void _handleMapEvent(MapEvent event) {
    if (_overlapPointBrowser != null && !isAtMaximumMapZoom(event.camera)) {
      setState(() {
        _overlapPointBrowser = null;
      });
    }
    if (!_showThumbnailMarkers) {
      return;
    }
    if (event is MapEventMoveStart ||
        event is MapEventFlingAnimationStart ||
        event is MapEventDoubleTapZoomStart) {
      _thumbnailBoundsDebounce?.cancel();
      return;
    }

    if (event is MapEventMoveEnd ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventFlingAnimationNotStarted ||
        event is MapEventDoubleTapZoomEnd) {
      _setThumbnailVisibleBounds(event.camera);
      return;
    }

    if (event is MapEventMove && event.source == MapEventSource.mapController) {
      _scheduleThumbnailVisibleBoundsRefresh();
      return;
    }

    if (event is MapEventScrollWheelZoom) {
      _scheduleThumbnailVisibleBoundsRefresh();
    }
  }

  void _scheduleThumbnailVisibleBoundsRefresh() {
    _thumbnailBoundsDebounce?.cancel();
    _thumbnailBoundsDebounce = Timer(_thumbnailBoundsDebounceDuration, () {
      if (!mounted || !_showThumbnailMarkers) {
        return;
      }
      try {
        _setThumbnailVisibleBounds(_mapController.camera);
      } catch (_) {
        // The controller may briefly be unavailable while the map mounts.
      }
    });
  }

  void _setThumbnailVisibleBounds(MapCamera camera) {
    _thumbnailBoundsDebounce?.cancel();
    if (!mounted || !_showThumbnailMarkers) {
      return;
    }
    _visibleBoundsNotifier.value = camera.visibleBounds;
  }

  Set<String> _thumbnailPointIdsForCurrentView(
    Iterable<PilgrimagePoint> points,
    LatLngBounds? bounds,
  ) {
    if (!_showThumbnailMarkers) {
      return const <String>{};
    }
    final threshold = widget.settings.mapThumbnailVisibleThreshold.clamp(
      0,
      200,
    );
    if (threshold <= 0) {
      return const <String>{};
    }
    final visiblePoints = bounds == null
        ? points.toList(growable: false)
        : points
              .where((point) => bounds.contains(point.position))
              .toList(growable: false);
    if (visiblePoints.length > threshold) {
      return const <String>{};
    }
    return visiblePoints.map((point) => point.id).toSet();
  }

  bool _shouldShowPointOnMap(PilgrimagePoint point) {
    if (!point.hasCoordinate) {
      return false;
    }
    if (!widget.settings.hideCompletedPointsOnMap) {
      return true;
    }
    return _controller.statusFor(point) != VisitStatus.completed;
  }

  void _moveToCurrentTarget() {
    final currentPoint = _controller.currentPoint;
    if (currentPoint == null) {
      _showSnackBar(
        l10n.pilgrimageMapNoSpotsSnack,
        kind: AppStatusBannerKind.warning,
      );
      return;
    }

    _selectPoint(currentPoint);
    _centerPoint(currentPoint);
  }

  void _openCamera(PilgrimagePoint point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CamerawesomeReferenceScreen(
          point: point,
          controller: _controller,
          settings: widget.settings,
        ),
      ),
    );
  }

  void _showPointDetail(PilgrimagePoint point) {
    PointDetailSheet.show(
      context,
      point: point,
      status: _controller.statusFor(point),
      onSetCurrent: () => _setCurrentPoint(point),
      onOpenCamera: () => _openCamera(point),
      onComplete: () => _controller.statusFor(point) == VisitStatus.completed
          ? _controller.reopenPoint(point)
          : _controller.completePoint(point),
      onReplaceReference: (point, image) => _controller.updatePoint(
        point.copyWith(
          referenceImageUrl: null,
          referenceThumbnailPath: image.thumbnailPath,
          referenceFullImagePath: image.fullImagePath,
        ),
      ),
      groups: _controller.plan.groups,
      groupBuckets: planGroupBuckets(
        _controller.plan,
        _controller.completedPointIds,
      ),
      onMoveToGroup: _controller.movePointToGroup,
      records: _controller.recordsForPoint(point.id),
      onOpenRecords: () => _openPointRecords(point),
      onOpenRecord: _openRecordDetail,
      onEditPoint: () => _editPoint(point),
      onDelete: _controller.deletePoint,
      navigationApp: widget.settings.navigationApp,
      settings: widget.settings,
      planController: _controller,
    );
  }

  Future<void> _editPoint(PilgrimagePoint point) async {
    final repository = _controller.repository;
    if (repository == null) {
      _showSnackBar(
        l10n.pilgrimageMapCannotEdit,
        kind: AppStatusBannerKind.warning,
      );
      return;
    }
    final updated = await EditPointScreen.open(
      context,
      plan: _controller.plan,
      repository: repository,
      point: point,
    );
    if (updated != true || !mounted) {
      return;
    }
    final updatedPlan = await repository.loadActivePlan();
    if (!mounted) {
      return;
    }
    _controller.replacePlan(updatedPlan);
  }

  void _openPointRecords(PilgrimagePoint point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PointVisitRecordsScreen(
          point: point,
          controller: _controller,
          settings: widget.settings,
        ),
      ),
    );
  }

  void _openRecordDetail(PilgrimageVisitRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitRecordDetailScreen(
          record: record,
          point: _controller.pointById(record.pointId),
          controller: _controller,
          settings: widget.settings,
          onDelete: () => _controller.deleteVisitRecord(record),
        ),
      ),
    );
  }

  void _showSnackBar(
    String message, {
    AppStatusBannerKind kind = AppStatusBannerKind.error,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showStatusSnack(kind: kind, title: message);
  }

  Marker _buildPointMarker({
    required PilgrimagePoint point,
    required PilgrimagePoint? selectedPoint,
    required Set<String> thumbnailPointIds,
    required List<PlanGroupBucket> groups,
  }) {
    final isSelected = point.id == selectedPoint?.id;
    final showThumbnail =
        _showThumbnailMarkers &&
        (isSelected || thumbnailPointIds.contains(point.id));
    final scale = normalizedMapMarkerScale(widget.settings.mapMarkerScale);
    final baseWidth = _showThumbnailMarkers
        ? (showThumbnail ? 84.0 : 24.0)
        : 44.0;
    final baseHeight = _showThumbnailMarkers
        ? (showThumbnail ? 82.0 : 24.0)
        : 44.0;
    return Marker(
      key: ValueKey('plan-map-marker-${point.id}'),
      point: point.position,
      width: scaledMapMarkerDimension(baseWidth, scale),
      height: scaledMapMarkerDimension(baseHeight, scale),
      alignment: _showThumbnailMarkers
          ? (showThumbnail ? Alignment.topCenter : Alignment.center)
          : Alignment.center,
      child: ScaledMapMarker(
        baseWidth: baseWidth,
        baseHeight: baseHeight,
        scale: scale,
        child: _showThumbnailMarkers
            ? MapThumbnailMarker(
                key: ValueKey('plan-map-thumbnail-marker-${point.id}'),
                selected: isSelected,
                imported: _controller.statusFor(point) == VisitStatus.completed,
                showThumbnail: showThumbnail,
                markerColor: mapColorForPoint(point, groups),
                imageLoadLimiter: _thumbnailLoadLimiter,
                localPath: point.referenceThumbnailPath,
                imageUrl: hasRemoteReferenceImage(point)
                    ? point.referenceImageUrl
                    : null,
                imageSource: widget.settings.anitabiImageSource,
                onTap: () => _selectPoint(point),
              )
            : _PointMarker(
                selected: isSelected,
                status: _controller.statusFor(point),
                onTap: () => _selectPoint(point),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = planGroupBuckets(
      _controller.plan,
      _controller.completedPointIds,
    );
    if (_selectedGroupIndex >= groups.length) {
      _selectedGroupIndex = groups.isEmpty ? 0 : groups.length - 1;
    }
    final selectedGroup = groups.isEmpty ? null : groups[_selectedGroupIndex];
    final selectedPoint =
        _controller.points.any(
          (point) => point.id == _controller.selectedPoint?.id,
        )
        ? _controller.selectedPoint
        : null;
    final currentPoint =
        _controller.points.any(
          (point) => point.id == _controller.currentPoint?.id,
        )
        ? _controller.currentPoint
        : null;
    final positionedPoints = _controller.points
        .where(_shouldShowPointOnMap)
        .toList(growable: false);
    final initialFocusPoint = (selectedPoint?.hasCoordinate ?? false)
        ? selectedPoint
        : (currentPoint?.hasCoordinate ?? false)
        ? currentPoint
        : positionedPoints.firstOrNull;
    final groupCenter = selectedGroup != null && groupHasPosition(selectedGroup)
        ? groupMapCenter(selectedGroup)
        : null;
    // With nothing to show yet, start where the user is, or on all of Japan.
    final showsOverview =
        initialFocusPoint == null &&
        groupCenter == null &&
        _currentLocation == null;
    final initialCenter =
        initialFocusPoint?.position ??
        groupCenter ??
        _currentLocation ??
        _japanCenter;
    final selectedGroupId = selectedGroup?.id ?? '';
    final mapPoints = selectedItemsLast<PilgrimagePoint>(
      positionedPoints,
      isSelected: (point) => point.id == selectedPoint?.id,
    );
    final overlapPoints = <PilgrimagePoint>[];
    for (final pointId in _overlapPointBrowser?.pointIds ?? const <String>[]) {
      final point = _controller.pointById(pointId);
      if (point != null && _shouldShowPointOnMap(point)) {
        overlapPoints.add(point);
      }
    }
    final overlapPointIndex = overlapPoints.indexWhere(
      (point) => point.id == selectedPoint?.id,
    );
    final hasActiveOverlapBrowser =
        overlapPoints.length > 1 && overlapPointIndex >= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: showsOverview ? 5 : 15,
              minZoom: 4,
              maxZoom: widget.settings.mapMaxZoom.toDouble(),
              onMapEvent: _handleMapEvent,
              keepAlive: true,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              configuredMapTileLayer(widget.settings),
              if (widget.settings.mapShowGroupAreas)
                PolygonLayer(
                  simplificationTolerance: 0,
                  polygons: groupAreaPolygons(
                    groups,
                    selectedGroupId: selectedGroupId,
                    radiusMeters: widget.settings.mapGroupAreaRadiusMeters
                        .toDouble(),
                  ),
                ),
              ValueListenableBuilder<LatLngBounds?>(
                valueListenable: _visibleBoundsNotifier,
                builder: (context, visibleBounds, _) {
                  final camera = MapCamera.of(context);
                  final thumbnailPointIds = _thumbnailPointIdsForCurrentView(
                    positionedPoints,
                    visibleBounds,
                  );
                  final atMaximumZoom = isAtMaximumMapZoom(camera);
                  final normalClusteringEnabled =
                      widget.settings.mapMarkerClusteringEnabled &&
                      camera.zoom <= widget.settings.mapMarkerClusterMaxZoom;
                  final overlapClusteringEnabled =
                      widget.settings.mapMarkerClusteringEnabled &&
                      camera.zoom > widget.settings.mapMarkerClusterMaxZoom;
                  final clusteringEnabled =
                      normalClusteringEnabled || overlapClusteringEnabled;
                  final activeOverlapPointIds =
                      hasActiveOverlapBrowser && atMaximumZoom
                      ? overlapPoints.map((point) => point.id).toSet()
                      : const <String>{};
                  final clusterItems = activeOverlapPointIds.isEmpty
                      ? mapPoints
                      : mapPoints
                            .where(
                              (point) =>
                                  !activeOverlapPointIds.contains(point.id),
                            )
                            .toList(growable: false);
                  final terminalRadiusLimit = scaledMapMarkerDimension(
                    _showThumbnailMarkers ? 52 : 44,
                    widget.settings.mapMarkerScale,
                  );
                  final clusterRadius = normalClusteringEnabled
                      ? effectiveClusterRadius(
                          widget.settings.mapMarkerClusterRadius.toDouble(),
                          widget.settings.mapMarkerScale,
                        )
                      : widget.settings.mapMarkerClusterRadius
                            .toDouble()
                            .clamp(1, terminalRadiusLimit)
                            .toDouble();
                  final markerClusters = clusteringEnabled
                      ? clusterMapMarkers<PilgrimagePoint>(
                          items: clusterItems,
                          positionOf: (point) => point.position,
                          camera: camera,
                          radiusPixels: clusterRadius,
                          keepSeparate: (point) =>
                              activeOverlapPointIds.isEmpty &&
                              normalClusteringEnabled &&
                              point.id == selectedPoint?.id,
                        )
                      : [
                          for (final point in clusterItems)
                            MapMarkerCluster(
                              items: [point],
                              position: point.position,
                            ),
                          if (activeOverlapPointIds.isNotEmpty &&
                              selectedPoint != null &&
                              _shouldShowPointOnMap(selectedPoint))
                            MapMarkerCluster(
                              items: [selectedPoint],
                              position: selectedPoint.position,
                            ),
                        ];
                  if (clusteringEnabled &&
                      activeOverlapPointIds.isNotEmpty &&
                      selectedPoint != null &&
                      _shouldShowPointOnMap(selectedPoint)) {
                    markerClusters.add(
                      MapMarkerCluster(
                        items: [selectedPoint],
                        position: selectedPoint.position,
                      ),
                    );
                  }
                  return MarkerLayer(
                    markers: [
                      for (final cluster in markerClusters)
                        if (cluster.isCluster)
                          Marker(
                            key: ValueKey(
                              'plan-map-cluster-${cluster.items.first.id}-${cluster.items.length}',
                            ),
                            point: cluster.position,
                            width: scaledMapMarkerDimension(
                              mapClusterMarkerExtent,
                              widget.settings.mapMarkerScale,
                            ),
                            height: scaledMapMarkerDimension(
                              mapClusterMarkerExtent,
                              widget.settings.mapMarkerScale,
                            ),
                            child: ScaledMapMarker(
                              baseWidth: mapClusterMarkerExtent,
                              baseHeight: mapClusterMarkerExtent,
                              scale: widget.settings.mapMarkerScale,
                              child: Center(
                                child: MapMarkerClusterBadge(
                                  count: cluster.items.length,
                                  doneCount: cluster.items
                                      .where(
                                        (point) =>
                                            _controller.statusFor(point) ==
                                            VisitStatus.completed,
                                      )
                                      .length,
                                  doneLabel: l10n.pilgrimageMapVisitedLabel,
                                  opensPointBrowser: atMaximumZoom,
                                  onTap: atMaximumZoom
                                      ? () => _openOverlapPointBrowser(
                                          cluster.items,
                                          groups,
                                        )
                                      : () => _mapController.move(
                                          cluster.position,
                                          normalClusteringEnabled
                                              ? nextClusterZoom(
                                                  camera,
                                                  widget
                                                      .settings
                                                      .mapMarkerClusterMaxZoom,
                                                )
                                              : nextOverlapClusterZoom(camera),
                                        ),
                                ),
                              ),
                            ),
                          )
                        else
                          _buildPointMarker(
                            point: cluster.items.single,
                            selectedPoint: selectedPoint,
                            thumbnailPointIds: thumbnailPointIds,
                            groups: groups,
                          ),
                      if (_currentLocation != null)
                        Marker(
                          point: _currentLocation!,
                          width: scaledMapMarkerDimension(
                            44,
                            widget.settings.mapMarkerScale,
                          ),
                          height: scaledMapMarkerDimension(
                            44,
                            widget.settings.mapMarkerScale,
                          ),
                          child: ScaledMapMarker(
                            baseWidth: 44,
                            baseHeight: 44,
                            scale: widget.settings.mapMarkerScale,
                            child: Tooltip(
                              message:
                                  _locationError ??
                                  l10n.pilgrimageMapCurrentLocation,
                              child: Opacity(
                                opacity: _locationError == null ? 1 : 0.4,
                                child: const _CurrentLocationMarker(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              configuredMapAttribution(widget.settings),
            ],
          ),
          if (selectedGroup != null)
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: SafeArea(
                bottom: false,
                child: _MapGroupFilterBar(
                  group: selectedGroup,
                  onTap: () => _showGroupPicker(context, groups),
                ),
              ),
            ),
          Positioned(
            right: 12,
            top: 76,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _MapFloatingIconButton(
                    tooltip: l10n.pilgrimageMapLocate,
                    onTap: _isLocating ? null : _locateUser,
                    child: _isLocating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.locateFixed, size: 20),
                  ),
                  const SizedBox(height: 8),
                  _MapFloatingIconButton(
                    tooltip: l10n.pilgrimageMapCurrentTarget,
                    onTap: _moveToCurrentTarget,
                    child: const Icon(LucideIcons.flag, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (buttonContext) => _MapFloatingIconButton(
                      key: const ValueKey('map-layers-button'),
                      tooltip: l10n.pilgrimageMapLayers,
                      onTap: () => _openLayers(buttonContext),
                      child: const Icon(LucideIcons.layers, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: selectedPoint == null
                ? const _EmptyMapCard()
                : _PointCard(
                    controller: _controller,
                    point: selectedPoint,
                    status: _controller.statusFor(selectedPoint),
                    recordCount: _controller
                        .recordsForPoint(selectedPoint.id)
                        .length,
                    onSetCurrent: selectedPoint.hasCoordinate
                        ? () => _setCurrentPoint(selectedPoint)
                        : null,
                    onOpenDetail: () => _showPointDetail(selectedPoint),
                    onOpenInAppNavigation: selectedPoint.hasCoordinate
                        ? () => _openInAppNavigation(selectedPoint)
                        : null,
                    onOpenExternalNavigation: selectedPoint.hasCoordinate
                        ? () => _openExternalNavigation(selectedPoint)
                        : null,
                    onOpenCamera: () => _openCamera(selectedPoint),
                    onComplete: () =>
                        _controller.statusFor(selectedPoint) ==
                            VisitStatus.completed
                        ? _controller.reopenPoint(selectedPoint)
                        : _controller.completePoint(selectedPoint),
                    overlapPointIndex: hasActiveOverlapBrowser
                        ? overlapPointIndex
                        : null,
                    overlapPointCount: hasActiveOverlapBrowser
                        ? overlapPoints.length
                        : null,
                    onPreviousOverlapPoint: hasActiveOverlapBrowser
                        ? () => _moveOverlapPoint(-1)
                        : null,
                    onNextOverlapPoint: hasActiveOverlapBrowser
                        ? () => _moveOverlapPoint(1)
                        : null,
                  ),
          ),
        ],
      ),
    );
  }

  static const _japanCenter = LatLng(36.2, 138.25);

  Future<void> _showGroupPicker(
    BuildContext context,
    List<PlanGroupBucket> groups,
  ) async {
    await showPlanGroupPickerSheet(
      context: context,
      groups: groups,
      selectedGroupId: groups[_selectedGroupIndex].id,
      showProgressRing: widget.settings.showPlanGroupProgress,
      onSelectGroup: (selectedGroup) {
        final index = groups.indexWhere(
          (group) => group.id == selectedGroup.id,
        );
        if (index >= 0) {
          _selectGroup(index, groups);
        }
      },
    );
  }
}

class _MapGroupFilterBar extends StatelessWidget {
  const _MapGroupFilterBar({required this.group, required this.onTap});

  final PlanGroupBucket group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('map-group-filter-bar'),
      color: MapColors.surface.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.ink)),
      child: InkWell(
        borderRadius: BorderRadius.zero,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              const Icon(LucideIcons.folder, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${group.name} · ${group.completedCount}/${group.points.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const Icon(LucideIcons.chevronDown, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapFloatingIconButton extends StatelessWidget {
  const _MapFloatingIconButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
    super.key,
  });

  final String tooltip;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: MapColors.surface.withValues(alpha: 0.94),
        shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.ink)),
        child: InkWell(
          borderRadius: BorderRadius.zero,
          onTap: onTap,
          child: IconTheme(
            data: IconThemeData(color: AppColors.textPrimary),
            child: SizedBox(width: 38, height: 38, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}

class _PointMarker extends StatelessWidget {
  const _PointMarker({
    required this.selected,
    required this.status,
    required this.onTap,
  });

  final bool selected;
  final VisitStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final markerColors = switch (status) {
      VisitStatus.current => (MapColors.accent, MapColors.onAccent),
      VisitStatus.completed => (
        MapColors.surfaceMuted,
        AppColors.textSecondary,
      ),
      VisitStatus.pending => (MapColors.surface, MapColors.accentDark),
    };

    return IconButton(
      tooltip: l10n.pilgrimageMapPointMarker,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: markerColors.$1,
        foregroundColor: markerColors.$2,
        side: BorderSide(
          color: selected ? AppColors.warning : MapColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      icon: Icon(
        status == VisitStatus.completed
            ? LucideIcons.check
            : LucideIcons.mapPin,
        size: 24,
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: MapColors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}

const _mapPointActionExtent = 44.0;
const _mapPointPrimaryActionWidth = 52.0;

ButtonStyle _mapPointIconButtonStyle(double width) {
  return IconButton.styleFrom(
    minimumSize: Size(width, _mapPointActionExtent),
    maximumSize: Size(width, _mapPointActionExtent),
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}

class _PointCard extends StatelessWidget {
  const _PointCard({
    required this.controller,
    required this.point,
    required this.status,
    required this.recordCount,
    required this.onSetCurrent,
    required this.onOpenDetail,
    required this.onOpenInAppNavigation,
    required this.onOpenExternalNavigation,
    required this.onOpenCamera,
    required this.onComplete,
    this.overlapPointIndex,
    this.overlapPointCount,
    this.onPreviousOverlapPoint,
    this.onNextOverlapPoint,
  });

  final PilgrimagePlanController controller;
  final PilgrimagePoint point;
  final VisitStatus status;
  final int recordCount;
  final VoidCallback? onSetCurrent;
  final VoidCallback onOpenDetail;
  final VoidCallback? onOpenInAppNavigation;
  final VoidCallback? onOpenExternalNavigation;
  final VoidCallback onOpenCamera;
  final VoidCallback onComplete;
  final int? overlapPointIndex;
  final int? overlapPointCount;
  final VoidCallback? onPreviousOverlapPoint;
  final VoidCallback? onNextOverlapPoint;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final showOverlapPager =
        overlapPointIndex != null &&
        overlapPointCount != null &&
        onPreviousOverlapPoint != null &&
        onNextOverlapPoint != null;

    // A panel on the bottom edge, like a sheet: raise with an ink top edge.
    // No side padding: the pager's divider runs edge to edge, everything
    // else carries the 12dp inset.
    return Container(
      padding: EdgeInsets.fromLTRB(
        0,
        showOverlapPager ? 6 : 12,
        0,
        12 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: MapColors.surface,
        border: Border(top: BorderSide(color: AppColors.ink)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final child in <Widget>[
            if (showOverlapPager) ...[
              MapOverlapPointPager(
                currentIndex: overlapPointIndex!,
                total: overlapPointCount!,
                onPrevious: onPreviousOverlapPoint!,
                onNext: onNextOverlapPoint!,
              ),
              const RowDivider(key: ValueKey('map-overlap-point-divider')),
              const SizedBox(height: 6),
            ],
            GestureDetector(
              key: const ValueKey('map-point-card-content'),
              behavior: HitTestBehavior.opaque,
              onTap: onOpenDetail,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PointThumbnail(controller: controller, point: point),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppContentFade(
                      revision: (point.id, status),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _StatusBadge(status: status),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CopyableText(
                                  key: ValueKey(
                                    'map-point-card-content-${point.id}',
                                  ),
                                  text: point.name,
                                  copyLabel: l10n.pilgrimageMapCopySpotName,
                                  onTap: onOpenDetail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          CopyableText(
                            text: _metaText,
                            copyText: _copySummary,
                            copyLabel: l10n.pilgrimageMapCopySpotInfo,
                            onTap: onOpenDetail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final navigation = SplitNavigationButton(
                  inAppLabel: point.hasCoordinate
                      ? l10n.pilgrimageMapNavigate
                      : l10n.pilgrimageMapCoordinatesMissing,
                  onOpenInAppNavigation: onOpenInAppNavigation,
                  onOpenExternalNavigation: onOpenExternalNavigation,
                  height: _mapPointActionExtent,
                );
                final showCurrent =
                    point.hasCoordinate &&
                    status != VisitStatus.current &&
                    status != VisitStatus.completed;
                final actions = <Widget>[
                  SizedBox(
                    width: _mapPointPrimaryActionWidth,
                    height: _mapPointActionExtent,
                    child: IconButton.outlined(
                      tooltip: l10n.pilgrimageMapCamera,
                      onPressed: onOpenCamera,
                      style: _mapPointIconButtonStyle(
                        _mapPointPrimaryActionWidth,
                      ),
                      icon: SizedBox(
                        width: 24,
                        height: 24,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(child: Icon(LucideIcons.camera)),
                            if (recordCount > 0)
                              Positioned(
                                top: -5,
                                right: -5,
                                child: _MapRecordBadge(
                                  stacked: recordCount > 1,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: _mapPointPrimaryActionWidth,
                    height: _mapPointActionExtent,
                    child: IconButton.outlined(
                      tooltip: status == VisitStatus.completed
                          ? l10n.pilgrimageMapUndoVisit
                          : l10n.pilgrimageMapMarkComplete,
                      onPressed: onComplete,
                      style: _mapPointIconButtonStyle(
                        _mapPointPrimaryActionWidth,
                      ),
                      icon: Icon(
                        status == VisitStatus.completed
                            ? LucideIcons.undo2
                            : LucideIcons.circleCheckBig,
                      ),
                    ),
                  ),
                  if (showCurrent) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      width: _mapPointActionExtent,
                      height: _mapPointActionExtent,
                      child: IconButton.outlined(
                        tooltip: l10n.pilgrimageMapSetCurrent,
                        onPressed: onSetCurrent,
                        style: _mapPointIconButtonStyle(_mapPointActionExtent),
                        icon: const Icon(LucideIcons.flag),
                      ),
                    ),
                  ],
                ];
                final minimumWidth =
                    _mapPointActionExtent * 2 +
                    1 +
                    _mapPointPrimaryActionWidth * 2 +
                    8 +
                    (showCurrent ? _mapPointActionExtent + 4 : 0);
                if (constraints.maxWidth < minimumWidth) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      navigation,
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions,
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: navigation),
                    const SizedBox(width: 4),
                    ...actions,
                  ],
                );
              },
            ),
          ])
            child is RowDivider
                ? child
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: child,
                  ),
        ],
      ),
    );
  }

  String get _metaText {
    final episodeLabel = point.episodeLabel.trim();
    if (episodeLabel.isEmpty) {
      return point.work.title;
    }
    return '${point.work.title} / $episodeLabel';
  }

  String get _copySummary {
    return [
      point.name,
      joinLabels([point.work.title, point.work.displaySubtitle]),
      point.subtitle,
      point.displayEpisodeLabel,
      point.hasCoordinate
          ? '${point.position.latitude.toStringAsFixed(5)},${point.position.longitude.toStringAsFixed(5)}'
          : l10n.pilgrimageMapCoordinatesMissing,
    ].where((value) => value.trim().isNotEmpty).join('\n');
  }
}

class _PointThumbnail extends StatelessWidget {
  const _PointThumbnail({required this.controller, required this.point});

  final PilgrimagePlanController controller;
  final PilgrimagePoint point;

  @override
  Widget build(BuildContext context) {
    final repository = controller.repository;
    final remoteImageUrl = hasRemoteReferenceImage(point)
        ? point.referenceImageUrl
        : null;
    return GestureDetector(
      onTap: () => ImageViewerScreen.show(
        context,
        filePath: point.referenceFullImagePath,
        imageUrl: remoteImageUrl,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Container(
          width: 64,
          height: 64,
          color: MapColors.surfaceMuted,
          child: repository == null
              ? ReferenceThumbnail(
                  localPath: point.referenceThumbnailPath,
                  imageUrl: remoteImageUrl,
                  placeholder: Icon(
                    LucideIcons.image,
                    color: MapColors.accentDark,
                  ),
                )
              : AutoCachingReferenceThumbnail(
                  planId: controller.plan.id,
                  point: point,
                  repository: repository,
                  onPlanUpdated: controller.replacePlan,
                  placeholder: Icon(
                    LucideIcons.image,
                    color: MapColors.accentDark,
                  ),
                ),
        ),
      ),
    );
  }
}

class _MapRecordBadge extends StatelessWidget {
  const _MapRecordBadge({required this.stacked});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('map-point-shot-badge'),
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MapColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.ink),
      ),
      child: Icon(
        stacked ? LucideIcons.images : LucideIcons.image,
        size: 10,
        color: MapColors.accentDark,
      ),
    );
  }
}

class _EmptyMapCard extends StatelessWidget {
  const _EmptyMapCard();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      key: const ValueKey('map-empty-card'),
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
      decoration: BoxDecoration(
        color: MapColors.surface,
        border: Border(top: BorderSide(color: AppColors.ink)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.map, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pilgrimageMapEmptyTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.pilgrimageMapEmptyBody,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                    letterSpacing: 0,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final VisitStatus status;

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      VisitStatus.current => l10n.pilgrimageMapStatusCurrent,
      VisitStatus.completed => l10n.pilgrimageMapStatusCompleted,
      VisitStatus.pending => l10n.pilgrimageMapStatusPending,
    };

    final current = status == VisitStatus.current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: current ? AppColors.accentWash : AppColors.surfaceMuted,
      child: Text(
        text,
        style: TextStyle(
          color: current ? AppColors.accentForeground : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
