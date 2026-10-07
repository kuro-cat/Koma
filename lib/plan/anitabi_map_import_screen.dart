import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/app_motion.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../map/map_colors.dart';
import '../map/map_layers_panel.dart';
import '../map/map_marker_clustering.dart';
import '../map/map_marker_scale.dart';
import '../map/map_navigation_launcher.dart';
import '../map/map_tile_config.dart';
import '../widgets/snackbar_helper.dart';
import '../data/anitabi_client.dart';
import '../data/bangumi_api_client.dart';
import '../data/anitabi_image_url.dart';
import '../data/anitabi_link_parser.dart';
import '../data/pilgrimage_repository.dart';
import '../data/reference_image_cache_stub.dart'
    if (dart.library.io) '../data/reference_image_cache_io.dart'
    as reference_image_cache;
import '../widgets/copyable_text.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/input_dialog.dart';
import '../widgets/auto_caching_reference_thumbnail.dart';
import '../widgets/image_viewer_screen.dart';
import '../widgets/image_load_limiter.dart';
import '../widgets/map_thumbnail_marker.dart';
import '../widgets/reference_thumbnail_stub.dart'
    if (dart.library.io) '../widgets/reference_thumbnail_io.dart';
import '../widgets/responsive_button.dart';
import '../widgets/app_scaled_route.dart';
import '../widgets/app_back_button.dart';
import '../utils/limited_concurrency.dart';
import '../utils/selected_item_order.dart';
import 'add_points_screen.dart';
import 'nearest_group_assign_screen.dart';
import 'pilgrimage_models.dart';
import 'pilgrimage_work_dropdown.dart';
import 'plan_group_picker_sheet.dart';
import 'plan_group_utils.dart';
import '../settings/app_settings_updater.dart';

class AnitabiMapImportScreen extends StatefulWidget {
  const AnitabiMapImportScreen({
    required this.plan,
    required this.repository,
    this.initialBangumiId,
    this.initialPointId,
    this.initialSettings,
    this.anitabiClient,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;
  final int? initialBangumiId;
  final String? initialPointId;
  final AppSettings? initialSettings;

  /// Injected in tests; otherwise the page creates and closes its own.
  final AnitabiClient? anitabiClient;

  @override
  State<AnitabiMapImportScreen> createState() => _AnitabiMapImportScreenState();
}

class _ImportOverlapPointBrowser {
  _ImportOverlapPointBrowser({required List<String> pointIds})
    : pointIds = List.unmodifiable(pointIds);

  final List<String> pointIds;
}

class _AnitabiMapImportScreenState extends State<AnitabiMapImportScreen> {
  late final AnitabiClient _anitabiClient;
  late final bool _ownsAnitabiClient;
  static const double _fallbackLoadedPointsZoom = 15;
  static const Duration _thumbnailBoundsDebounceDuration = Duration(
    milliseconds: 180,
  );

  final MapController _mapController = MapController();
  late final Set<String> _importedPointIds;
  late PilgrimagePlan _importedPlan = widget.plan;
  PilgrimageWork? _selectedWork;
  late AppSettings _settings = widget.initialSettings ?? const AppSettings();
  AnitabiBangumiLite? _lite;
  List<AnitabiPoint> _points = const [];
  AnitabiPoint? _selectedPoint;
  _ImportOverlapPointBrowser? _overlapPointBrowser;
  Object? _error;
  bool _isLoading = false;
  bool _isImporting = false;
  _ImportProgress? _importProgress;
  bool _didUpdatePlan = false;
  bool get _showThumbnailMarkers => _settings.importMapShowThumbnailMarkers;
  bool _isBoxSelecting = false;
  Offset? _selectionStart;
  Offset? _selectionEnd;
  int _loadGeneration = 0;
  final ValueNotifier<LatLngBounds?> _visibleBoundsNotifier = ValueNotifier(
    null,
  );
  Timer? _thumbnailBoundsDebounce;
  LatLng? _pendingMapCenter;
  double? _pendingMapZoom;
  late final ImageLoadLimiter _thumbnailLoadLimiter = ImageLoadLimiter(
    _settings.mapThumbnailConcurrentLoads,
  );

  List<PilgrimageWork> get _works {
    final selectedWork = _selectedWork;
    if (selectedWork == null ||
        _importedPlan.works.any((work) => work.id == selectedWork.id)) {
      return _importedPlan.works;
    }
    return [..._importedPlan.works, selectedWork];
  }

  int _nextLoadGeneration() {
    _loadGeneration += 1;
    return _loadGeneration;
  }

  bool _isActiveLoad(int generation) {
    return mounted && generation == _loadGeneration;
  }

  @override
  void initState() {
    super.initState();
    _ownsAnitabiClient = widget.anitabiClient == null;
    _anitabiClient =
        widget.anitabiClient ??
        AnitabiClient(
          serviceConfig: widget.initialSettings?.anitabiServiceConfig,
        );
    _importedPointIds = widget.plan.points.map((point) => point.id).toSet();
    _loadSettings();
    final initialBangumiId = widget.initialBangumiId;
    final initialPointId = widget.initialPointId;
    if (initialBangumiId != null && initialPointId != null) {
      _loadInitialPointLink(initialBangumiId, initialPointId);
      return;
    }

    if (initialBangumiId != null) {
      _loadInitialBangumiId(initialBangumiId);
    } else {
      final works = _works;
      if (works.isNotEmpty) {
        final bangumiWork = works
            .where((work) => work.bangumiId != null)
            .firstOrNull;
        final initialWork = bangumiWork ?? works.first;
        _selectedWork = initialWork;
        if (initialWork.bangumiId != null) {
          _loadPoints(initialWork);
        }
      }
    }
  }

  Future<void> _loadSettings() async {
    final settings = await widget.repository.loadAppSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = settings;
    });
    _thumbnailLoadLimiter.maxConcurrent = settings.mapThumbnailConcurrentLoads;
  }

  /// Applies a map display change right away and remembers it; on failure
  /// the previous value comes back. Returns whether it was saved.
  Future<void> _settingsSaveQueue = Future.value();

  Future<bool> _updateSettings(
    AppSettings Function(AppSettings settings) update,
  ) async {
    final previous = _settings;
    final next = update(_settings);
    setState(() => _settings = next);
    if (previous.importMapShowThumbnailMarkers !=
        next.importMapShowThumbnailMarkers) {
      _syncThumbnailBounds();
    }
    // One save at a time: each reads the stored settings the previous one
    // wrote, so quick successive switches never overwrite each other.
    final save = _settingsSaveQueue.then((_) async {
      if (!await AppSettingsUpdater.update(widget.repository, update)) {
        throw StateError('settings not saved');
      }
    });
    _settingsSaveQueue = save.then((_) {}, onError: (Object _) {});
    try {
      await save;
      return true;
    } on Object catch (error) {
      debugPrint('Failed to save import map settings: $error');
      if (mounted) {
        // Only undo this change; a newer one decides for itself.
        if (identical(_settings, next)) {
          setState(() => _settings = previous);
          _syncThumbnailBounds();
        }
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.anitabiMapImportSettingsSaveFailed,
          subtitle: l10n.anitabiMapImportTryLater,
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    _thumbnailBoundsDebounce?.cancel();
    _visibleBoundsNotifier.dispose();
    if (_ownsAnitabiClient) {
      _anitabiClient.close();
    }
    super.dispose();
  }

  Future<void> _refreshAnitabiData() async {
    _anitabiClient.clearStaticCache();
    ScaffoldMessenger.of(context).showStatusSnack(
      kind: AppStatusBannerKind.running,
      title: l10n.anitabiMapImportClearingCache,
      icon: LucideIcons.brushCleaning,
    );

    final initialBangumiId = widget.initialBangumiId;
    final initialPointId = widget.initialPointId;
    if (initialBangumiId != null && initialPointId != null) {
      await _loadInitialPointLink(initialBangumiId, initialPointId);
      return;
    }

    if (initialBangumiId != null && _selectedWork == null) {
      await _loadInitialBangumiId(initialBangumiId);
      return;
    }

    final works = _works;
    final work =
        _selectedWork ??
        works.where((work) => work.bangumiId != null).firstOrNull ??
        works.firstOrNull;
    if (work?.bangumiId != null) {
      await _loadPoints(work!);
      return;
    }

    setState(() {
      _error = null;
    });
  }

  /// Searches Bangumi and shows the chosen work's spots. The work joins the
  /// plan only when its spots are imported.
  Future<void> _searchWork() async {
    final client = BangumiApiClient();
    final PilgrimageWork? picked;
    try {
      picked = await Navigator.of(context).push<PilgrimageWork>(
        appScaledMaterialPageRoute<PilgrimageWork>(
          settings: _settings,
          builder: (_) => BangumiWorkSearchScreen(
            plan: _importedPlan,
            repository: widget.repository,
            bangumiApiClient: client,
            pickOnly: true,
          ),
        ),
      );
    } finally {
      client.close();
    }
    final bangumiId = picked?.bangumiId;
    if (picked == null || bangumiId == null || !mounted) {
      return;
    }
    await _loadPoints(_workForBangumiId(bangumiId) ?? picked);
  }

  Future<void> _openLink() async {
    final link = await Navigator.of(context).push<AnitabiImportLink>(
      appScaledMaterialPageRoute<AnitabiImportLink>(
        settings: _settings,
        builder: (_) =>
            AnitabiLinkInputScreen(plan: _importedPlan, settings: _settings),
      ),
    );
    final bangumiId = link?.bangumiId;
    if (link == null || bangumiId == null || !mounted) {
      return;
    }
    if (link.hasPointId) {
      await _loadInitialPointLink(bangumiId, link.pointId!);
    } else {
      await _loadInitialBangumiId(bangumiId);
    }
  }

  Future<void> _loadPoints(PilgrimageWork work) async {
    final generation = _nextLoadGeneration();
    final bangumiId = work.bangumiId;
    if (bangumiId == null) {
      setState(() {
        _selectedWork = work;
        _isLoading = false;
        _error = null;
        _lite = null;
        _points = const [];
        _overlapPointBrowser = null;
        _selectedPoint = null;
      });
      _showManualWorkMessage();
      return;
    }

    setState(() {
      _selectedWork = work;
      _isLoading = true;
      _error = null;
      _points = const [];
      _overlapPointBrowser = null;
      _selectedPoint = null;
    });

    try {
      final lite = await _fetchBangumiLite(work);
      if (!_isActiveLoad(generation)) {
        return;
      }
      final points = await _anitabiClient.fetchPoints(bangumiId, lite: lite);
      if (!_isActiveLoad(generation)) {
        return;
      }

      setState(() {
        _lite = lite;
        _points = points;
        _overlapPointBrowser = null;
        _selectedPoint = _initialSelectedPointForLoadedPoints(points, lite);
      });
      _requestMapMove(
        _centerForLoadedPoints(points, lite),
        _zoomForLoadedPoints(points, lite),
      );
    } catch (error) {
      if (!_isActiveLoad(generation)) {
        return;
      }

      setState(() {
        _error = error;
      });
    } finally {
      if (_isActiveLoad(generation)) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showManualWorkMessage() {
    ScaffoldMessenger.of(context).showStatusSnack(
      kind: AppStatusBannerKind.warning,
      title: l10n.anitabiMapImportManualWorkNoId,
    );
  }

  void _requestMapMove(LatLng center, double zoom) {
    _pendingMapCenter = center;
    _pendingMapZoom = zoom;
    _moveMapAfterBuild(center, zoom);
  }

  void _moveMapAfterBuild(LatLng center, double zoom, {int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      try {
        _mapController.move(center, zoom);
        if (_pendingMapCenter == center && _pendingMapZoom == zoom) {
          _pendingMapCenter = null;
          _pendingMapZoom = null;
        }
      } catch (_) {
        if (attempt < 5) {
          Future<void>.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              _moveMapAfterBuild(center, zoom, attempt: attempt + 1);
            }
          });
        }
      }
    });
  }

  void _handleMapReady() {
    final center = _pendingMapCenter;
    final zoom = _pendingMapZoom;
    if (center != null && zoom != null) {
      _moveMapAfterBuild(center, zoom);
    }
  }

  Future<void> _loadInitialBangumiId(int bangumiId) async {
    final generation = _nextLoadGeneration();
    setState(() {
      _isLoading = true;
      _error = null;
      _points = const [];
      _overlapPointBrowser = null;
      _selectedPoint = null;
    });

    try {
      final lite = await _fetchBangumiLiteForBangumiId(bangumiId);
      if (!_isActiveLoad(generation)) {
        return;
      }
      final work = _workForBangumiId(lite.bangumiId) ?? _workFromLite(lite);

      final points = await _anitabiClient.fetchPoints(
        lite.bangumiId,
        lite: lite,
      );
      if (!_isActiveLoad(generation)) {
        return;
      }

      setState(() {
        _selectedWork = work;
        _lite = lite;
        _points = points;
        _overlapPointBrowser = null;
        _selectedPoint = _initialSelectedPointForLoadedPoints(points, lite);
      });
      _requestMapMove(
        _centerForLoadedPoints(points, lite),
        _zoomForLoadedPoints(points, lite),
      );
    } catch (error) {
      if (!_isActiveLoad(generation)) {
        return;
      }

      setState(() {
        _error = error;
      });
    } finally {
      if (_isActiveLoad(generation)) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadInitialPointLink(int bangumiId, String pointId) async {
    final generation = _nextLoadGeneration();
    setState(() {
      _isLoading = true;
      _error = null;
      _points = const [];
      _overlapPointBrowser = null;
      _selectedPoint = null;
    });

    try {
      final result =
          await _anitabiClient.findPointGlobally(pointId: pointId) ??
          await _anitabiClient.findPointInBangumi(
            bangumiId: bangumiId,
            pointId: pointId,
          );
      if (!_isActiveLoad(generation)) {
        return;
      }
      if (result == null) {
        throw const AnitabiPointNotFoundException();
      }

      final lite = result.work;
      final work = _workForBangumiId(lite.bangumiId) ?? _workFromLite(lite);

      setState(() {
        _selectedWork = work;
        _lite = lite;
        _points = result.points;
        _overlapPointBrowser = null;
        _selectedPoint = result.point;
      });
      _requestMapMove(result.point.position, math.max(lite.zoom, 15));
    } catch (error) {
      if (!_isActiveLoad(generation)) {
        return;
      }

      setState(() {
        _error = error;
      });
    } finally {
      if (_isActiveLoad(generation)) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<AnitabiBangumiLite> _fetchBangumiLite(PilgrimageWork work) async {
    final bangumiId = work.bangumiId;
    if (bangumiId == null) {
      throw const AnitabiStaticDataUnavailableException('Missing Bangumi ID');
    }

    final staticLite = await _fetchStaticBangumiLiteIfSupported(bangumiId);
    if (staticLite != null) {
      return staticLite;
    }

    try {
      return await _anitabiClient.fetchBangumiLite(bangumiId);
    } catch (_) {
      return AnitabiBangumiLite(
        bangumiId: bangumiId,
        title: work.title,
        subtitle: work.subtitle,
        city: work.city,
        center: const LatLng(35.0, 135.0),
        zoom: 12,
        pointsLength: 0,
      );
    }
  }

  Future<AnitabiBangumiLite> _fetchBangumiLiteForBangumiId(
    int bangumiId,
  ) async {
    final staticLite = await _fetchStaticBangumiLiteIfSupported(bangumiId);
    if (staticLite != null) {
      return staticLite;
    }
    return _anitabiClient.fetchBangumiLite(bangumiId);
  }

  Future<AnitabiBangumiLite?> _fetchStaticBangumiLiteIfSupported(
    int bangumiId,
  ) {
    if (_anitabiClient.runtimeType != AnitabiClient) {
      return Future.value();
    }
    return _anitabiClient.fetchBangumiLiteFromStatic(bangumiId);
  }

  PilgrimageWork? _workForBangumiId(int bangumiId) {
    for (final work in _importedPlan.works) {
      if (work.bangumiId == bangumiId) {
        return work;
      }
    }
    return null;
  }

  PilgrimageWork _workFromLite(AnitabiBangumiLite lite) {
    // Anitabi's title is the Chinese name when there is one, its subtitle
    // the Japanese name.
    final (:title, :subtitle) = bangumiWorkTitles(
      bangumiId: lite.bangumiId,
      name: lite.subtitle,
      nameCn: lite.title,
    );
    return PilgrimageWork(
      id: 'bangumi-${lite.bangumiId}',
      bangumiId: lite.bangumiId,
      title: title,
      subtitle: subtitle,
      city: lite.city,
      source: WorkSource.bangumi,
      coverImageUrl: lite.coverImageUrl,
    );
  }

  /// The work to store with imported points: fills a cover the plan's copy
  /// is missing, never replacing one it already has.
  PilgrimageWork _workForImport(PilgrimageWork work) {
    final lite = _lite;
    if (lite == null || lite.bangumiId != work.bangumiId) {
      return work;
    }
    return fillMissingWorkFields(work, _workFromLite(lite));
  }

  void _replaceImportedPlan(PilgrimagePlan plan) {
    final previousSelectedWork = _selectedWork;
    _importedPlan = plan;
    if (previousSelectedWork != null) {
      _selectedWork = _matchingWorkInPlan(plan, previousSelectedWork);
    }
    _importedPointIds
      ..clear()
      ..addAll(plan.points.map((point) => point.id));
  }

  PilgrimageWork? _matchingWorkInPlan(
    PilgrimagePlan plan,
    PilgrimageWork selectedWork,
  ) {
    for (final work in plan.works) {
      if (work.id == selectedWork.id) {
        return work;
      }
    }
    final bangumiId = selectedWork.bangumiId;
    if (bangumiId != null) {
      for (final work in plan.works) {
        if (work.bangumiId == bangumiId) {
          return work;
        }
      }
    }
    return plan.works.firstOrNull;
  }

  void _selectPoint(
    AnitabiPoint point, {
    bool preserveOverlapBrowser = false,
    _ImportOverlapPointBrowser? overlapPointBrowser,
  }) {
    if (_isImporting) {
      return;
    }
    final selectedBangumiId = _selectedWork?.bangumiId;
    if (selectedBangumiId == null || point.bangumiId != selectedBangumiId) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.clearSnackBars();
    setState(() {
      if (overlapPointBrowser != null) {
        _overlapPointBrowser = overlapPointBrowser;
      } else if (!preserveOverlapBrowser) {
        _overlapPointBrowser = null;
      }
      _selectedPoint = point;
    });
  }

  void _openOverlapPointBrowser(
    List<AnitabiPoint> points,
    List<AnitabiPoint> visiblePoints,
  ) {
    if (_isImporting) {
      return;
    }
    final orderedPoints = orderMapClusterItems<AnitabiPoint>(
      items: points,
      planOrder: visiblePoints,
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
      overlapPointBrowser: _ImportOverlapPointBrowser(
        pointIds: orderedPoints.map((point) => point.id).toList(),
      ),
    );
  }

  void _moveOverlapPoint(int offset) {
    final browser = _overlapPointBrowser;
    if (browser == null || browser.pointIds.length < 2) {
      return;
    }
    final pointsById = {
      for (final point in _pointsForWork(_selectedWork)) point.id: point,
    };
    final points = [
      for (final pointId in browser.pointIds) ?pointsById[pointId],
    ];
    if (points.length < 2) {
      setState(() => _overlapPointBrowser = null);
      return;
    }
    final selectedIndex = points.indexWhere(
      (point) => point.id == _selectedPoint?.id,
    );
    final nextIndex = nextMapOverlapIndex(
      currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
      offset: offset,
      total: points.length,
    );
    _selectPoint(points[nextIndex], preserveOverlapBrowser: true);
  }

  PilgrimagePoint? _importedPointFor(AnitabiPoint point) {
    final importedPointId = point.toPilgrimagePoint(_selectedWork!).id;
    for (final importedPoint in _importedPlan.points) {
      if (importedPoint.id == importedPointId) {
        return importedPoint;
      }
    }
    return null;
  }

  List<AnitabiPoint> get _availablePoints {
    final work = _selectedWork;
    if (work == null) {
      return const [];
    }
    return _pointsForWork(work)
        .where(
          (point) =>
              !_importedPointIds.contains(point.toPilgrimagePoint(work).id),
        )
        .toList(growable: false);
  }

  List<AnitabiPoint> _pointsForWork(PilgrimageWork? work) {
    final bangumiId = work?.bangumiId;
    if (bangumiId == null) {
      return const [];
    }
    return _points
        .where((point) => point.bangumiId == bangumiId)
        .toList(growable: false);
  }

  AnitabiPoint? _selectedPointForWork(PilgrimageWork? work) {
    final point = _selectedPoint;
    final bangumiId = work?.bangumiId;
    if (point == null || bangumiId == null || point.bangumiId != bangumiId) {
      return null;
    }
    return point;
  }

  LatLng _initialMapCenter({
    required AnitabiPoint? selectedPoint,
    required List<AnitabiPoint> visiblePoints,
  }) {
    final pendingCenter = _pendingMapCenter;
    if (pendingCenter != null) {
      return pendingCenter;
    }
    if (selectedPoint != null) {
      return selectedPoint.position;
    }
    return _centerForLoadedPoints(visiblePoints, _lite);
  }

  double _initialMapZoom({required AnitabiPoint? selectedPoint}) {
    final pendingZoom = _pendingMapZoom;
    if (pendingZoom != null) {
      return pendingZoom;
    }
    final liteZoom = _lite?.zoom;
    if (selectedPoint != null) {
      return math.max(liteZoom ?? 15, 15);
    }
    return liteZoom ?? 12;
  }

  LatLng _centerForLoadedPoints(
    List<AnitabiPoint> points,
    AnitabiBangumiLite? lite,
  ) {
    final center = lite?.center;
    if (center != null && _isValidMapCenter(center)) {
      return center;
    }
    if (points.isEmpty) {
      return const LatLng(35.0, 135.0);
    }
    final boundsCenter = _pointBoundsCenter(points);
    return _nearestPointTo(boundsCenter, points).position;
  }

  LatLng _pointBoundsCenter(List<AnitabiPoint> points) {
    var minLat = points.first.position.latitude;
    var maxLat = minLat;
    var minLng = points.first.position.longitude;
    var maxLng = minLng;
    for (final point in points.skip(1)) {
      minLat = math.min(minLat, point.position.latitude);
      maxLat = math.max(maxLat, point.position.latitude);
      minLng = math.min(minLng, point.position.longitude);
      maxLng = math.max(maxLng, point.position.longitude);
    }
    return LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  double _zoomForLoadedPoints(
    List<AnitabiPoint> points,
    AnitabiBangumiLite? lite,
  ) {
    final center = lite?.center;
    if (points.isNotEmpty && (center == null || !_isValidMapCenter(center))) {
      return _fallbackLoadedPointsZoom;
    }
    return lite?.zoom ?? 12;
  }

  AnitabiPoint? _initialSelectedPointForLoadedPoints(
    List<AnitabiPoint> points,
    AnitabiBangumiLite? lite,
  ) {
    if (points.isEmpty) {
      return null;
    }

    final center = lite?.center;
    if (center != null && _isValidMapCenter(center)) {
      return points.first;
    }

    return _nearestPointTo(_pointBoundsCenter(points), points);
  }

  AnitabiPoint _nearestPointTo(LatLng center, List<AnitabiPoint> points) {
    var nearest = points.first;
    var nearestDistance = _roughDistanceSquared(center, nearest.position);
    for (final point in points.skip(1)) {
      final distance = _roughDistanceSquared(center, point.position);
      if (distance < nearestDistance) {
        nearest = point;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  double _roughDistanceSquared(LatLng first, LatLng second) {
    final lat = first.latitude - second.latitude;
    final lng = first.longitude - second.longitude;
    return lat * lat + lng * lng;
  }

  bool _isValidMapCenter(LatLng center) {
    final latitude = center.latitude;
    final longitude = center.longitude;
    if (!latitude.isFinite || !longitude.isFinite) {
      return false;
    }
    if (latitude.abs() < 0.0001 && longitude.abs() < 0.0001) {
      return false;
    }
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  Rect? get _selectionRect {
    final start = _selectionStart;
    final end = _selectionEnd;
    if (start == null || end == null) {
      return null;
    }
    return Rect.fromPoints(start, end);
  }

  List<AnitabiPoint> _pointsInSelection() {
    final rect = _selectionRect;
    final work = _selectedWork;
    if (rect == null || work == null) {
      return const [];
    }

    return _availablePoints
        .where((point) {
          final offset = _mapController.camera.latLngToScreenOffset(
            point.position,
          );
          return rect.contains(offset);
        })
        .toList(growable: false);
  }

  Future<void> _importSelectedPoint() async {
    final work = _selectedWork;
    final point = _selectedPoint;
    if (work == null ||
        point == null ||
        point.bangumiId != work.bangumiId ||
        _isImporting) {
      return;
    }

    final pilgrimagePoint = point.toPilgrimagePoint(work);
    if (_importedPointIds.contains(pilgrimagePoint.id)) {
      return;
    }

    await _importPoints(
      [point],
      successMessage: l10n.anitabiMapImportAddedContinue,
      failureMessage: l10n.anitabiMapImportSpotImportFailed,
    );
  }

  Future<void> _importAllAvailablePoints() async {
    final points = _availablePoints;
    final confirmed = await _confirmBulkImport(
      title: l10n.anitabiMapImportAddAll,
      message: l10n.anitabiMapImportAddAllMessage(points.length),
      confirmLabel: l10n.anitabiMapImportAddAllConfirm,
    );
    if (!confirmed) {
      return;
    }

    await _importPoints(
      points,
      successMessage: l10n.anitabiMapImportAddedAll,
      failureMessage: l10n.anitabiMapImportBulkFailed,
    );
  }

  Future<void> _importSelectedBoxPoints() async {
    final points = _pointsInSelection();
    if (points.isEmpty) {
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.warning,
        title: l10n.anitabiMapImportBoxEmpty,
      );
      return;
    }

    final confirmed = await _confirmBulkImport(
      title: l10n.anitabiMapImportAddBoxTitle,
      message: l10n.anitabiMapImportAddBoxMessage(points.length),
      confirmLabel: l10n.anitabiMapImportAddBoxConfirm,
    );
    if (!confirmed) {
      return;
    }

    await _importPoints(
      points,
      successMessage: l10n.anitabiMapImportAddedBox,
      failureMessage: l10n.anitabiMapImportBoxFailed,
      exitBoxSelectionOnSuccess: true,
    );
  }

  Future<void> _importPoints(
    List<AnitabiPoint> points, {
    required String successMessage,
    required String failureMessage,
    bool exitBoxSelectionOnSuccess = false,
  }) async {
    final selectedWork = _selectedWork;
    if (selectedWork == null || points.isEmpty || _isImporting) {
      return;
    }
    final work = _workForImport(selectedWork);

    final pilgrimagePoints = points
        .where((point) => point.bangumiId == work.bangumiId)
        .map((point) => point.toPilgrimagePoint(work))
        .where((point) => !_importedPointIds.contains(point.id))
        .toList(growable: false);
    if (pilgrimagePoints.isEmpty) {
      return;
    }

    setState(() {
      _isImporting = true;
      _importProgress = _ImportProgress.importing(
        total: pilgrimagePoints.length,
      );
    });

    var shouldShowOrganizeGuide = false;
    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showStatusSnack(
        kind: AppStatusBannerKind.running,
        title: l10n.anitabiMapImportImporting(pilgrimagePoints.length),
        icon: LucideIcons.mapPinPlus,
      );
      var importedPlan = pilgrimagePoints.length == 1
          ? await widget.repository.addPointToPlan(
              planId: widget.plan.id,
              point: pilgrimagePoints.single,
            )
          : await widget.repository.addPointsToPlan(
              planId: widget.plan.id,
              points: pilgrimagePoints,
            );
      _didUpdatePlan = true;
      if (!mounted) {
        return;
      }

      setState(() {
        _replaceImportedPlan(importedPlan);
        _didUpdatePlan = true;
        _selectionStart = null;
        _selectionEnd = null;
        if (exitBoxSelectionOnSuccess) {
          _isBoxSelecting = false;
        }
        _importProgress = _ImportProgress.caching(
          total: pilgrimagePoints.length,
        );
      });

      var cached = 0;
      var cacheFailed = 0;
      var processed = 0;
      var lastProgressSnackBarAt = DateTime.fromMillisecondsSinceEpoch(0);
      final imageCacheUpdates = <String, PointImageCacheUpdate>{};
      await runLimitedConcurrent<PilgrimagePoint, _ThumbnailCacheResult>(
        items: pilgrimagePoints,
        maxConcurrent: _settings.mapThumbnailConcurrentLoads,
        task: (pilgrimagePoint, _) async {
          try {
            final thumbnailPath = await reference_image_cache
                .ensureReferenceThumbnailCached(
                  pilgrimagePoint,
                  imageSource: _settings.anitabiImageSource,
                );
            if (thumbnailPath == null || thumbnailPath.isEmpty) {
              return _ThumbnailCacheResult.failed(pilgrimagePoint.id);
            }
            return _ThumbnailCacheResult.succeeded(
              pointId: pilgrimagePoint.id,
              referenceThumbnailPath: thumbnailPath,
            );
          } catch (_) {
            return _ThumbnailCacheResult.failed(pilgrimagePoint.id);
          }
        },
        onResult: (result) {
          processed += 1;
          if (result.referenceThumbnailPath == null) {
            cacheFailed += 1;
          } else {
            cached += 1;
            imageCacheUpdates[result.pointId] = PointImageCacheUpdate(
              referenceThumbnailPath: result.referenceThumbnailPath,
              referenceFullImagePath: importedPlan.points
                  .firstWhere((point) => point.id == result.pointId)
                  .referenceFullImagePath,
            );
          }

          if (!mounted) {
            return;
          }
          setState(() {
            _replaceImportedPlan(importedPlan);
            _didUpdatePlan = true;
            _importProgress = _ImportProgress.caching(
              total: pilgrimagePoints.length,
              processed: processed,
              succeeded: cached,
            );
          });
          final now = DateTime.now();
          final shouldShowProgressSnackBar =
              processed == pilgrimagePoints.length ||
              now.difference(lastProgressSnackBarAt) >=
                  const Duration(milliseconds: 450);
          if (shouldShowProgressSnackBar) {
            lastProgressSnackBarAt = now;
            messenger.showStatusSnack(
              kind: AppStatusBannerKind.running,
              title: l10n.anitabiMapImportCachingThumbnails(
                processed,
                pilgrimagePoints.length,
                cached,
              ),
              icon: LucideIcons.images,
              duration: const Duration(milliseconds: 1200),
            );
          }
        },
      );

      if (!mounted) {
        return;
      }

      if (imageCacheUpdates.isNotEmpty) {
        importedPlan = await widget.repository.updatePointImageCaches(
          planId: widget.plan.id,
          updatesByPointId: imageCacheUpdates,
        );
      }

      if (!mounted) return;

      setState(() {
        _replaceImportedPlan(importedPlan);
        _didUpdatePlan = true;
        _selectionStart = null;
        _selectionEnd = null;
        if (exitBoxSelectionOnSuccess) {
          _isBoxSelecting = false;
        }
      });
      messenger.showStatusSnack(
        kind: cacheFailed == 0
            ? AppStatusBannerKind.success
            : AppStatusBannerKind.warning,
        title: cacheFailed == 0
            ? successMessage
            : l10n.anitabiMapImportImportedPartialCache(
                pilgrimagePoints.length,
                cached,
              ),
      );
      shouldShowOrganizeGuide = pilgrimagePoints.length > 1;
    } catch (error, stackTrace) {
      debugPrint('Failed to import Anitabi points: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showStatusSnack(kind: AppStatusBannerKind.error, title: failureMessage);
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _importProgress = null;
        });
      }
    }

    if (!mounted || !shouldShowOrganizeGuide) {
      return;
    }
    try {
      await _showOrganizeImportedPointsGuide(pilgrimagePoints);
    } catch (error, stackTrace) {
      debugPrint('Failed to organize imported Anitabi points: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.warning,
          title: l10n.anitabiMapImportOrganizeOpenFailed,
        );
      }
    }
  }

  Future<bool> _confirmBulkImport({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return showConfirmActionDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    );
  }

  Future<void> _showOrganizeImportedPointsGuide(
    List<PilgrimagePoint> importedPoints,
  ) async {
    final action = await showDialog<_ImportOrganizeAction>(
      context: context,
      builder: (context) => _ImportOrganizeDialog(
        importedCount: importedPoints.length,
        onNearestAssign: () =>
            Navigator.of(context).pop(_ImportOrganizeAction.nearestAssign),
        onAssignToGroup: () =>
            Navigator.of(context).pop(_ImportOrganizeAction.assignToGroup),
        onLater: () => Navigator.of(context).pop(_ImportOrganizeAction.later),
      ),
    );
    if (!mounted || action == null || action == _ImportOrganizeAction.later) {
      return;
    }

    switch (action) {
      case _ImportOrganizeAction.assignToGroup:
        await _assignImportedPointsToGroup(
          importedPoints.map((point) => point.id).toSet(),
        );
      case _ImportOrganizeAction.nearestAssign:
        await _openNearestAssign();
      case _ImportOrganizeAction.later:
        break;
    }
  }

  Future<void> _assignImportedPointsToGroup(Set<String> pointIds) async {
    const ungroupedOptionId = '__ungrouped__';
    final groups = sortGroupsByPlanOrder(_importedPlan.groups);
    final selectedGroupId = await showPlanGroupSelectionSheet(
      context: context,
      title: l10n.anitabiMapImportAssignToArea,
      subtitle: l10n.anitabiMapImportAssignToAreaSubtitle,
      selectedOptionId: ungroupedOptionId,
      options: [
        PlanGroupSelectionOption(
          id: ungroupedOptionId,
          title: l10n.anitabiMapImportNotInArea,
        ),
        for (final group in groups)
          PlanGroupSelectionOption(id: group.id, title: group.name),
      ],
      onCreateOption: () async {
        final created = await _createGroupForAssignment();
        return created == null
            ? null
            : PlanGroupSelectionOption(id: created.id, title: created.name);
      },
    );
    if (!mounted || selectedGroupId == null) {
      return;
    }

    final groupId = selectedGroupId == ungroupedOptionId
        ? null
        : selectedGroupId;
    try {
      final updatedPlan = await widget.repository.movePointsToGroup(
        planId: _importedPlan.id,
        pointIds: pointIds,
        groupId: groupId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _replaceImportedPlan(updatedPlan);
        _didUpdatePlan = true;
      });
      final groupName = groupId == null
          ? l10n.anitabiMapImportNotInArea
          : updatedPlan.groups
                    .where((group) => group.id == groupId)
                    .map((group) => group.name)
                    .firstOrNull ??
                l10n.anitabiMapImportSelectedArea;
      ScaffoldMessenger.of(context).showStatusSnack(
        kind: AppStatusBannerKind.success,
        title: l10n.anitabiMapImportAssigned(pointIds.length, groupName),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.anitabiMapImportAssignFailed,
        );
      }
    }
  }

  Future<PilgrimagePlanGroup?> _createGroupForAssignment() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _ImportedPointsCreateGroupDialog(),
    );
    final trimmedName = name?.trim();
    if (trimmedName == null || trimmedName.isEmpty || !mounted) {
      return null;
    }

    final nextOrderIndex = _importedPlan.groups.isEmpty
        ? 0
        : _importedPlan.groups
                  .map((group) => group.orderIndex)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    final now = DateTime.now();
    final group = PilgrimagePlanGroup(
      id: 'group-${now.microsecondsSinceEpoch}',
      name: trimmedName,
      orderIndex: nextOrderIndex,
      createdAt: now,
    );
    try {
      final updatedPlan = await widget.repository.createPlanGroup(
        planId: _importedPlan.id,
        group: group,
      );
      if (!mounted) {
        return null;
      }
      setState(() {
        _replaceImportedPlan(updatedPlan);
        _didUpdatePlan = true;
      });
      return updatedPlan.groups
          .where((candidate) => candidate.id == group.id)
          .firstOrNull;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.anitabiMapImportCreateAreaFailed,
        );
      }
      return null;
    }
  }

  Future<void> _openNearestAssign() async {
    final settings = await widget.repository.loadAppSettings();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<bool>(
      appScaledMaterialPageRoute<bool>(
        settings: settings,
        builder: (_) => NearestGroupAssignScreen(
          plan: _importedPlan,
          settings: settings,
          repository: widget.repository,
        ),
      ),
    );
    if (mounted) {
      await _reloadImportedPlan();
    }
  }

  Future<void> _reloadImportedPlan() async {
    final plan = await widget.repository.loadActivePlan();
    if (!mounted) {
      return;
    }
    setState(() {
      _replaceImportedPlan(plan);
      _didUpdatePlan = true;
    });
  }

  void _toggleBoxSelection() {
    setState(() {
      _isBoxSelecting = !_isBoxSelecting;
      _selectionStart = null;
      _selectionEnd = null;
    });
  }

  void _handleMapEvent(MapEvent event) {
    if (_overlapPointBrowser != null && !isAtMaximumMapZoom(event.camera)) {
      setState(() => _overlapPointBrowser = null);
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
    Iterable<AnitabiPoint> points,
    LatLngBounds? bounds,
  ) {
    if (!_showThumbnailMarkers) {
      return const <String>{};
    }
    final threshold = _settings.mapThumbnailVisibleThreshold.clamp(0, 200);
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

  void _openLayers(BuildContext anchorContext) {
    final settings = _settings;
    unawaited(
      showMapLayersPanel(
        anchorContext,
        settings: settings,
        toggles: [
          MapLayerToggle(
            id: 'thumbnails',
            label: l10n.anitabiMapImportThumbnailMarkers,
            icon: LucideIcons.image,
            value: settings.importMapShowThumbnailMarkers,
            onChanged: (value) => _updateSettings(
              (s) => s.copyWith(importMapShowThumbnailMarkers: value),
            ),
          ),
          MapLayerToggle(
            id: 'hide-imported',
            label: l10n.anitabiMapImportOnlyNotAdded,
            description: l10n.anitabiMapImportOnlyNotAddedDesc,
            icon: LucideIcons.eyeOff,
            value: settings.hideImportedPointsOnImportMap,
            onChanged: (value) => _updateSettings(
              (s) => s.copyWith(hideImportedPointsOnImportMap: value),
            ),
          ),
          MapLayerToggle(
            id: 'group-areas',
            label: l10n.anitabiMapImportAreaBounds,
            description: l10n.anitabiMapImportAreaBoundsDesc,
            icon: LucideIcons.pentagon,
            value: settings.importMapShowGroupAreas,
            onChanged: (value) => _updateSettings(
              (s) => s.copyWith(importMapShowGroupAreas: value),
            ),
          ),
          MapLayerToggle(
            id: 'clustering',
            label: l10n.anitabiMapImportClustering,
            icon: LucideIcons.group,
            value: settings.mapMarkerClusteringEnabled,
            onChanged: (value) => _updateSettings(
              (s) => s.copyWith(mapMarkerClusteringEnabled: value),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildImportPointMarker({
    required AnitabiPoint point,
    required AnitabiPoint? selectedPoint,
    required Set<String> thumbnailPointIds,
  }) {
    final imported = _importedPointIds.contains(
      point.toPilgrimagePoint(_selectedWork!).id,
    );
    final isSelected = selectedPoint?.id == point.id;
    final showThumbnail =
        _showThumbnailMarkers &&
        (isSelected || thumbnailPointIds.contains(point.id));
    final scale = normalizedMapMarkerScale(_settings.mapMarkerScale);
    final baseWidth = _showThumbnailMarkers
        ? (showThumbnail ? 84.0 : 24.0)
        : 40.0;
    final baseHeight = _showThumbnailMarkers
        ? (showThumbnail ? 82.0 : 24.0)
        : 40.0;
    return Marker(
      key: ValueKey('anitabi-import-marker-${point.id}'),
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
                key: ValueKey('anitabi-import-thumbnail-marker-${point.id}'),
                selected: isSelected,
                imported: imported,
                showThumbnail: showThumbnail,
                markerColor: imported
                    ? AppColors.textSecondary
                    : AppColors.accent,
                imageLoadLimiter: _thumbnailLoadLimiter,
                localPath: _importedPointFor(point)?.referenceThumbnailPath,
                imageUrl: _anitabiThumbnailUrl(point.referenceImageUrl),
                imageSource: _settings.anitabiImageSource,
                tooltip: l10n.anitabiMapImportAnitabiSpot,
                onTap: _isImporting ? null : () => _selectPoint(point),
              )
            : _ImportMarker(
                selected: isSelected,
                imported: imported,
                onTap: _isImporting ? null : () => _selectPoint(point),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final works = _works;
    final selectedWork = _selectedWork;
    final visiblePoints = _pointsForWork(selectedWork);
    final selectedPoint = _selectedPointForWork(selectedWork);
    // 只看未加入: imported points leave the map (and its clusters), except
    // the selected one, so its card and marker do not vanish mid-action.
    final shownPoints = _settings.hideImportedPointsOnImportMap
        ? [
            for (final point in visiblePoints)
              if (point.id == selectedPoint?.id ||
                  !_importedPointIds.contains(point.pilgrimagePointId))
                point,
          ]
        : visiblePoints;
    final mapPoints = selectedItemsLast<AnitabiPoint>(
      shownPoints,
      isSelected: (point) => point.id == selectedPoint?.id,
    );
    final pointsById = {for (final point in visiblePoints) point.id: point};
    final overlapPoints = [
      for (final pointId in _overlapPointBrowser?.pointIds ?? const <String>[])
        ?pointsById[pointId],
    ];
    final overlapPointIndex = overlapPoints.indexWhere(
      (point) => point.id == selectedPoint?.id,
    );
    final hasActiveOverlapBrowser =
        overlapPoints.length > 1 && overlapPointIndex >= 0;

    return PopScope(
      canPop: !_isImporting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _isImporting) {
          return;
        }

        Navigator.of(context).pop(_didUpdatePlan);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: ModalRoute.of(context)?.canPop == true
              ? AppBackButton(
                  onPressed: () {
                    if (!_isImporting) {
                      Navigator.of(context).pop(_didUpdatePlan);
                    }
                  },
                )
              : null,
          title: Text(l10n.anitabiMapImportTitle),
          actions: [
            Builder(
              builder: (buttonContext) => IconButton(
                key: const ValueKey('map-layers-button'),
                tooltip: l10n.anitabiMapImportLayers,
                onPressed: () => _openLayers(buttonContext),
                icon: const Icon(LucideIcons.layers),
              ),
            ),
            Tooltip(
              message: l10n.anitabiMapImportClearCacheReload,
              child: IconButton(
                onPressed: _isLoading || _isImporting
                    ? null
                    : _refreshAnitabiData,
                icon: const Icon(LucideIcons.refreshCw),
              ),
            ),
          ],
          bottom: works.isEmpty
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(58),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: PilgrimageWorkDropdown(
                            works: works,
                            value: _selectedWork,
                            settings: _settings,
                            omitScrollbarInsetWhenUnscrollable: true,
                            onChanged: _isImporting
                                ? null
                                : (work) {
                                    if (work != null) {
                                      _loadPoints(work);
                                    }
                                  },
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('import-search-work-button'),
                          tooltip: l10n.anitabiMapImportSearchWork,
                          onPressed: _isImporting ? null : _searchWork,
                          icon: const Icon(LucideIcons.search),
                        ),
                        IconButton(
                          key: const ValueKey('import-paste-link-button'),
                          tooltip: l10n.anitabiMapImportPasteLink,
                          onPressed: _isImporting ? null : _openLink,
                          icon: const Icon(LucideIcons.link),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        body: Builder(
          builder: (context) {
            if (_error != null) {
              return _ImportErrorState(
                message: _errorMessageFor(_error),
                detail: _errorDetailFor(_error),
                onRetry: _refreshAnitabiData,
              );
            }

            if (_isLoading && _points.isEmpty) {
              return const _ImportLoadingState();
            }

            if (works.isEmpty) {
              return _EmptyImportState(
                onSearch: _searchWork,
                onPasteLink: _openLink,
              );
            }

            if (!_isLoading &&
                selectedWork?.bangumiId == null &&
                visiblePoints.isEmpty) {
              return const _ManualWorkImportState();
            }

            if (!_isLoading &&
                selectedWork?.bangumiId != null &&
                _lite != null &&
                visiblePoints.isEmpty) {
              return _NoAnitabiPointsState(workTitle: selectedWork!.title);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final selectedBoxCount = _pointsInSelection().length;

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialMapCenter(
                          selectedPoint: selectedPoint,
                          visiblePoints: visiblePoints,
                        ),
                        initialZoom: _initialMapZoom(
                          selectedPoint: selectedPoint,
                        ),
                        minZoom: 4,
                        maxZoom: _settings.mapMaxZoom.toDouble(),
                        onMapReady: _handleMapReady,
                        onMapEvent: _handleMapEvent,
                        keepAlive: true,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        configuredMapTileLayer(_settings),
                        if (_settings.importMapShowGroupAreas)
                          PolygonLayer(
                            simplificationTolerance: 0,
                            polygons: groupAreaPolygons(
                              planGroupBuckets(
                                _importedPlan,
                                _importedPlan.completedPointIds,
                              ),
                              selectedGroupId: '',
                              radiusMeters: _settings.mapGroupAreaRadiusMeters
                                  .toDouble(),
                            ),
                          ),
                        ValueListenableBuilder<LatLngBounds?>(
                          valueListenable: _visibleBoundsNotifier,
                          builder: (context, visibleBounds, _) {
                            final camera = MapCamera.of(context);
                            final thumbnailPointIds =
                                _thumbnailPointIdsForCurrentView(
                                  shownPoints,
                                  visibleBounds,
                                );
                            final atMaximumZoom = isAtMaximumMapZoom(camera);
                            final normalClusteringEnabled =
                                _settings.mapMarkerClusteringEnabled &&
                                camera.zoom <=
                                    _settings.mapMarkerClusterMaxZoom;
                            final overlapClusteringEnabled =
                                _settings.mapMarkerClusteringEnabled &&
                                camera.zoom > _settings.mapMarkerClusterMaxZoom;
                            final clusteringEnabled =
                                normalClusteringEnabled ||
                                overlapClusteringEnabled;
                            final activeOverlapPointIds =
                                hasActiveOverlapBrowser && atMaximumZoom
                                ? overlapPoints.map((point) => point.id).toSet()
                                : const <String>{};
                            final clusterItems = activeOverlapPointIds.isEmpty
                                ? mapPoints
                                : mapPoints
                                      .where(
                                        (point) => !activeOverlapPointIds
                                            .contains(point.id),
                                      )
                                      .toList(growable: false);
                            final terminalRadiusLimit =
                                scaledMapMarkerDimension(
                                  _showThumbnailMarkers ? 52 : 44,
                                  _settings.mapMarkerScale,
                                );
                            final clusterRadius = normalClusteringEnabled
                                ? effectiveClusterRadius(
                                    _settings.mapMarkerClusterRadius.toDouble(),
                                    _settings.mapMarkerScale,
                                  )
                                : _settings.mapMarkerClusterRadius
                                      .toDouble()
                                      .clamp(1, terminalRadiusLimit)
                                      .toDouble();
                            final markerClusters = clusteringEnabled
                                ? clusterMapMarkers<AnitabiPoint>(
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
                                        selectedPoint != null)
                                      MapMarkerCluster(
                                        items: [selectedPoint],
                                        position: selectedPoint.position,
                                      ),
                                  ];
                            if (clusteringEnabled &&
                                activeOverlapPointIds.isNotEmpty &&
                                selectedPoint != null) {
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
                                        'anitabi-import-cluster-${cluster.items.first.id}-${cluster.items.length}',
                                      ),
                                      point: cluster.position,
                                      width: scaledMapMarkerDimension(
                                        mapClusterMarkerExtent,
                                        _settings.mapMarkerScale,
                                      ),
                                      height: scaledMapMarkerDimension(
                                        mapClusterMarkerExtent,
                                        _settings.mapMarkerScale,
                                      ),
                                      child: ScaledMapMarker(
                                        baseWidth: mapClusterMarkerExtent,
                                        baseHeight: mapClusterMarkerExtent,
                                        scale: _settings.mapMarkerScale,
                                        child: Center(
                                          child: MapMarkerClusterBadge(
                                            count: cluster.items.length,
                                            doneCount: cluster.items
                                                .where(
                                                  (point) => _importedPointIds
                                                      .contains(
                                                        point.pilgrimagePointId,
                                                      ),
                                                )
                                                .length,
                                            doneLabel: l10n
                                                .anitabiMapImportClusterAdded,
                                            opensPointBrowser: atMaximumZoom,
                                            onTap: atMaximumZoom
                                                ? () =>
                                                      _openOverlapPointBrowser(
                                                        cluster.items,
                                                        visiblePoints,
                                                      )
                                                : () => _mapController.move(
                                                    cluster.position,
                                                    normalClusteringEnabled
                                                        ? nextClusterZoom(
                                                            camera,
                                                            _settings
                                                                .mapMarkerClusterMaxZoom,
                                                          )
                                                        : nextOverlapClusterZoom(
                                                            camera,
                                                          ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    _buildImportPointMarker(
                                      point: cluster.items.single,
                                      selectedPoint: selectedPoint,
                                      thumbnailPointIds: thumbnailPointIds,
                                    ),
                              ],
                            );
                          },
                        ),
                        configuredMapAttribution(_settings),
                      ],
                    ),
                    if (_isBoxSelecting)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: (details) {
                            setState(() {
                              _selectionStart = details.localPosition;
                              _selectionEnd = details.localPosition;
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _selectionEnd = details.localPosition;
                            });
                          },
                          child: CustomPaint(
                            painter: _SelectionRectPainter(_selectionRect),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: _ImportSummary(
                        isLoading: _isLoading,
                        isImporting: _isImporting,
                        importProgress: _importProgress,
                        importedCount: visiblePoints
                            .where(
                              (point) => _importedPointIds.contains(
                                point.toPilgrimagePoint(selectedWork!).id,
                              ),
                            )
                            .length,
                        totalCount: shownPoints.length,

                        expectedCount: _lite?.pointsLength,
                        availableCount: _availablePoints.length,
                        boxSelectionEnabled: _isBoxSelecting,
                        selectedBoxCount: selectedBoxCount,
                        onToggleBoxSelection: _toggleBoxSelection,
                        onImportAll: _importAllAvailablePoints,
                        onImportSelection: _importSelectedBoxPoints,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: selectedPoint == null
                          ? _isLoading
                                ? const SizedBox.shrink()
                                : _NoPointSelectedCard(
                                    hasPoints: visiblePoints.isNotEmpty,
                                    expectedCount: _lite?.pointsLength,
                                  )
                          : _AnitabiPointCard(
                              point: selectedPoint,
                              planId: _importedPlan.id,
                              repository: widget.repository,
                              onPlanUpdated: (plan) {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _replaceImportedPlan(plan);
                                  _didUpdatePlan = true;
                                });
                              },
                              importedPoint: _importedPointFor(selectedPoint),
                              navigationPoint: selectedPoint.toPilgrimagePoint(
                                _selectedWork!,
                              ),
                              navigationApp: _settings.navigationApp,
                              imported: _importedPointIds.contains(
                                selectedPoint
                                    .toPilgrimagePoint(_selectedWork!)
                                    .id,
                              ),
                              isImporting: _isImporting,
                              onImport: _importSelectedPoint,
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
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _errorMessageFor(Object? error) {
    if (error is AnitabiStaticDataUnavailableException) {
      return l10n.anitabiMapImportErrorDataUnavailable;
    }

    if (error is AnitabiWorkNotFoundException) {
      return l10n.anitabiMapImportErrorWorkNotFound;
    }

    if (error is AnitabiNoPointsException) {
      return l10n.anitabiMapImportErrorNoPoints;
    }

    if (error is AnitabiPartialPointsException) {
      return l10n.anitabiMapImportErrorPartial;
    }

    if (error is AnitabiException && error.statusCode == 404) {
      return l10n.anitabiMapImportError404;
    }

    if (error is AnitabiPointNotFoundException) {
      return l10n.anitabiMapImportErrorPointNotFound;
    }

    return l10n.anitabiMapImportErrorGeneric;
  }

  String _errorDetailFor(Object? error) {
    if (error is AnitabiStaticDataUnavailableException) {
      if (kIsWeb) {
        return l10n.anitabiMapImportDetailDataUnavailableWeb;
      }
      return l10n.anitabiMapImportDetailDataUnavailable;
    }

    if (error is AnitabiWorkNotFoundException) {
      return l10n.anitabiMapImportDetailWorkNotFound;
    }

    if (error is AnitabiNoPointsException) {
      return l10n.anitabiMapImportDetailNoPoints;
    }

    if (error is AnitabiPartialPointsException) {
      return l10n.anitabiMapImportDetailPartial(
        error.loadedCount,
        error.expectedCount,
      );
    }

    if (error is AnitabiException && error.statusCode == 404) {
      return l10n.anitabiMapImportDetail404;
    }

    if (error is AnitabiPointNotFoundException) {
      return l10n.anitabiMapImportDetailPointNotFound;
    }

    return l10n.anitabiMapImportDetailGeneric;
  }
}

enum _ImportProgressStage { importing, caching }

class _ImportProgress {
  const _ImportProgress.importing({required this.total})
    : stage = _ImportProgressStage.importing,
      processed = 0,
      succeeded = 0;

  const _ImportProgress.caching({
    required this.total,
    this.processed = 0,
    this.succeeded = 0,
  }) : stage = _ImportProgressStage.caching;

  final _ImportProgressStage stage;
  final int total;
  final int processed;
  final int succeeded;

  String get label {
    return switch (stage) {
      _ImportProgressStage.importing => l10n.anitabiMapImportImporting(total),
      _ImportProgressStage.caching => l10n.anitabiMapImportCachingThumbnails(
        processed,
        total,
        succeeded,
      ),
    };
  }
}

class _ImportOrganizeDialog extends StatelessWidget {
  const _ImportOrganizeDialog({
    required this.importedCount,
    required this.onNearestAssign,
    required this.onAssignToGroup,
    required this.onLater,
  });

  final int importedCount;
  final VoidCallback onNearestAssign;
  final VoidCallback onAssignToGroup;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.anitabiMapImportOrganizeTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  text: l10n.anitabiMapImportOrganizeLead,
                  children: [
                    TextSpan(
                      text: l10n.anitabiMapImportSpotCount(importedCount),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: l10n.anitabiMapImportOrganizeTail),
                  ],
                ),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.55,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onNearestAssign,
                child: Text(l10n.anitabiMapImportNearestAssign),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onAssignToGroup,
                child: Text(l10n.anitabiMapImportAssignToArea),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onLater,
                child: Text(l10n.anitabiMapImportLater),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportedPointsCreateGroupDialog extends StatefulWidget {
  const _ImportedPointsCreateGroupDialog();

  @override
  State<_ImportedPointsCreateGroupDialog> createState() =>
      _ImportedPointsCreateGroupDialogState();
}

class _ImportedPointsCreateGroupDialogState
    extends State<_ImportedPointsCreateGroupDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = l10n.anitabiMapImportAreaNameEmpty);
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AppInputDialog(
      title: l10n.anitabiMapImportNewArea,
      content: AppDialogField(
        label: l10n.anitabiMapImportAreaName,
        child: TextField(
          onTapOutside: dismissKeyboardOnTapOutside,
          key: const ValueKey('anitabi-import-group-name-field'),
          controller: _controller,
          autofocus: true,
          decoration: appDialogInputDecoration(errorText: _errorText),
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
          onSubmitted: (_) => _submit(),
        ),
      ),
      confirmLabel: l10n.anitabiMapImportCreate,
      onConfirm: _submit,
    );
  }
}

enum _ImportOrganizeAction { later, assignToGroup, nearestAssign }

class _ThumbnailCacheResult {
  const _ThumbnailCacheResult._({
    required this.pointId,
    required this.referenceThumbnailPath,
  });

  factory _ThumbnailCacheResult.succeeded({
    required String pointId,
    required String referenceThumbnailPath,
  }) {
    return _ThumbnailCacheResult._(
      pointId: pointId,
      referenceThumbnailPath: referenceThumbnailPath,
    );
  }

  factory _ThumbnailCacheResult.failed(String pointId) {
    return _ThumbnailCacheResult._(
      pointId: pointId,
      referenceThumbnailPath: null,
    );
  }

  final String pointId;
  final String? referenceThumbnailPath;
}

class _ImportMarker extends StatelessWidget {
  const _ImportMarker({
    required this.selected,
    required this.imported,
    required this.onTap,
  });

  final bool selected;
  final bool imported;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: imported
          ? l10n.anitabiMapImportImportedSpot
          : l10n.anitabiMapImportImportableSpot,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: imported ? MapColors.surfaceMuted : MapColors.surface,
        foregroundColor: imported ? AppColors.textSecondary : MapColors.accent,
        side: BorderSide(
          color: selected ? AppColors.warning : MapColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      icon: Icon(imported ? LucideIcons.check : LucideIcons.mapPin, size: 22),
    );
  }
}

class _ImportSummary extends StatelessWidget {
  const _ImportSummary({
    required this.isLoading,
    required this.isImporting,
    required this.importProgress,
    required this.importedCount,
    required this.totalCount,
    required this.expectedCount,
    required this.availableCount,
    required this.boxSelectionEnabled,
    required this.selectedBoxCount,
    required this.onToggleBoxSelection,
    required this.onImportAll,
    required this.onImportSelection,
  });

  final bool isLoading;
  final bool isImporting;
  final _ImportProgress? importProgress;
  final int importedCount;
  final int totalCount;
  final int? expectedCount;
  final int availableCount;
  final bool boxSelectionEnabled;
  final int selectedBoxCount;
  final VoidCallback onToggleBoxSelection;
  final VoidCallback onImportAll;
  final VoidCallback onImportSelection;

  @override
  Widget build(BuildContext context) {
    final expected = expectedCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (isLoading || isImporting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(LucideIcons.map, color: AppColors.accentForeground),
              const SizedBox(width: 10),
              Expanded(
                child: AppContentFade(
                  revision: (isLoading, isImporting),
                  child: Text(
                    isLoading
                        ? l10n.anitabiMapImportLoadingSpots
                        : importProgress?.label ??
                              (expected == null
                                  ? l10n.anitabiMapImportShownCount(
                                      importedCount,
                                      totalCount,
                                    )
                                  : l10n.anitabiMapImportShownCountOfTotal(
                                      importedCount,
                                      totalCount,
                                      expected,
                                    )),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isLoading) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 36,
                  child: IconButton.outlined(
                    tooltip: l10n.anitabiMapImportAddAll,
                    onPressed: isImporting || availableCount == 0
                        ? null
                        : onImportAll,
                    icon: const Icon(LucideIcons.listChecks, size: 18),
                    style: _summaryIconButtonStyle(false),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  height: 36,
                  child: IconButton.outlined(
                    tooltip: boxSelectionEnabled
                        ? l10n.anitabiMapImportExitBox
                        : l10n.anitabiMapImportBoxSelect,
                    isSelected: boxSelectionEnabled,
                    onPressed: isImporting ? null : onToggleBoxSelection,
                    icon: const Icon(LucideIcons.scan, size: 18),
                    selectedIcon: const Icon(LucideIcons.scan, size: 18),
                    style: _summaryIconButtonStyle(boxSelectionEnabled),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: FilledButton(
                      onPressed:
                          isImporting ||
                              !boxSelectionEnabled ||
                              selectedBoxCount == 0
                          ? null
                          : onImportSelection,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      child: ResponsiveButtonContent(
                        icon: LucideIcons.mapPinPlus,
                        iconSize: 16,
                        label: selectedBoxCount == 0
                            ? l10n.anitabiMapImportImportSelection
                            : l10n.anitabiMapImportImportCount(
                                selectedBoxCount,
                              ),
                        shortLabel: l10n.anitabiMapImportImport,
                        semanticLabel: l10n.anitabiMapImportImportSelection,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  ButtonStyle _summaryIconButtonStyle(bool selected) {
    return IconButton.styleFrom(
      backgroundColor: selected
          ? AppColors.accent.withValues(alpha: 0.12)
          : AppColors.surface,
      foregroundColor: selected ? AppColors.accentDark : AppColors.textPrimary,
      disabledBackgroundColor: AppColors.surfaceMuted,
      disabledForegroundColor: AppColors.textSecondary,
      fixedSize: const Size.square(36),
      minimumSize: const Size.square(36),
      padding: EdgeInsets.zero,
      side: BorderSide(
        color: selected ? AppColors.accent : AppColors.border,
        width: selected ? 2 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }
}

class _SelectionRectPainter extends CustomPainter {
  const _SelectionRectPainter(this.rect);

  final Rect? rect;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = this.rect;
    if (rect == null) {
      return;
    }

    final normalized = Rect.fromLTRB(
      math.min(rect.left, rect.right),
      math.min(rect.top, rect.bottom),
      math.max(rect.left, rect.right),
      math.max(rect.top, rect.bottom),
    );
    final fillPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(normalized, fillPaint);
    canvas.drawRect(normalized, strokePaint);
  }

  @override
  bool shouldRepaint(_SelectionRectPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}

class _AnitabiPointCard extends StatelessWidget {
  const _AnitabiPointCard({
    required this.point,
    required this.planId,
    required this.repository,
    required this.onPlanUpdated,
    required this.importedPoint,
    required this.navigationPoint,
    required this.navigationApp,
    required this.imported,
    required this.isImporting,
    required this.onImport,
    this.overlapPointIndex,
    this.overlapPointCount,
    this.onPreviousOverlapPoint,
    this.onNextOverlapPoint,
  });

  final AnitabiPoint point;
  final String planId;
  final PilgrimageRepository repository;
  final ValueChanged<PilgrimagePlan> onPlanUpdated;
  final PilgrimagePoint? importedPoint;
  final PilgrimagePoint navigationPoint;
  final NavigationApp navigationApp;
  final bool imported;
  final bool isImporting;
  final VoidCallback onImport;
  final int? overlapPointIndex;
  final int? overlapPointCount;
  final VoidCallback? onPreviousOverlapPoint;
  final VoidCallback? onNextOverlapPoint;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final imageUrl = _anitabiThumbnailUrl(point.referenceImageUrl);
    final fullImageUrl = anitabiFullResolutionImageUrl(point.referenceImageUrl);
    final localThumbnailPath = importedPoint?.referenceThumbnailPath;
    final localFullPath = importedPoint?.referenceFullImagePath;
    final showOverlapPager =
        overlapPointIndex != null &&
        overlapPointCount != null &&
        onPreviousOverlapPoint != null &&
        onNextOverlapPoint != null;
    void openFullImage() {
      if (fullImageUrl == null) {
        return;
      }
      ImageViewerScreen.show(
        context,
        filePath: localFullPath,
        imageUrl: fullImageUrl,
      );
    }

    void openDetail() {
      _AnitabiPointDetailSheet.show(
        context,
        point: point,
        imageUrl: imageUrl,
        fullImageUrl: fullImageUrl,
        localThumbnailPath: localThumbnailPath,
        localFullPath: localFullPath,
        imported: imported,
        isImporting: isImporting,
        onImport: onImport,
      );
    }

    Future<void> openNavigation() async {
      final opened = await const MapNavigationLauncher().openWalking(
        navigationPoint,
        navigationApp,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: l10n.anitabiMapImportOpenAppFailed(navigationApp.label),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showOverlapPager) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: MapOverlapPointPager(
                  currentIndex: overlapPointIndex!,
                  total: overlapPointCount!,
                  onPrevious: onPreviousOverlapPoint!,
                  onNext: onNextOverlapPoint!,
                ),
              ),
              Divider(
                key: ValueKey('anitabi-import-overlap-point-divider'),
                height: 1,
                indent: 14,
                endIndent: 14,
                color: AppColors.border,
              ),
            ],
            InkWell(
              key: ValueKey('anitabi-point-card-${point.id}'),
              onTap: openDetail,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: Material(
                            color: AppColors.surfaceMuted,
                            child: InkWell(
                              onTap: fullImageUrl == null
                                  ? null
                                  : openFullImage,
                              child: SizedBox(
                                key: ValueKey(
                                  'anitabi-point-thumbnail-${point.id}',
                                ),
                                width: 80,
                                height: 80,
                                child: importedPoint == null
                                    ? ReferenceThumbnail(
                                        localPath: localThumbnailPath,
                                        imageUrl: imageUrl,
                                        placeholder: const Icon(
                                          LucideIcons.image,
                                        ),
                                      )
                                    : AutoCachingReferenceThumbnail(
                                        planId: planId,
                                        point: importedPoint!,
                                        repository: repository,
                                        onPlanUpdated: onPlanUpdated,
                                        placeholder: const Icon(
                                          LucideIcons.image,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ConstrainedBox(
                            key: ValueKey('anitabi-point-text-${point.id}'),
                            constraints: const BoxConstraints(minHeight: 80),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CopyableText(
                                  text: point.name,
                                  copyLabel: l10n.anitabiMapImportSpotName,
                                  onTap: openDetail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                CopyableText(
                                  text: _anitabiPointCaption(point),
                                  copyText: _copySummary,
                                  copyLabel: l10n.anitabiMapImportSpotInfo,
                                  onTap: openDetail,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                CopyableText(
                                  text: point.origin,
                                  copyLabel: l10n.anitabiMapImportSource,
                                  onTap: openDetail,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ResponsiveTwoButtonRow(
                      first: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          key: ValueKey('anitabi-point-navigation-${point.id}'),
                          onPressed: openNavigation,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: ResponsiveButtonContent(
                            icon: LucideIcons.navigation,
                            iconSize: 17,
                            label: l10n.anitabiMapImportNavigate,
                            semanticLabel: l10n.anitabiMapImportOpenNavigation,
                          ),
                        ),
                      ),
                      second: SizedBox(
                        height: 40,
                        child: FilledButton(
                          key: ValueKey('anitabi-point-import-${point.id}'),
                          onPressed: imported || isImporting ? null : onImport,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: ResponsiveButtonContent(
                            icon: imported
                                ? LucideIcons.check
                                : LucideIcons.mapPinPlus,
                            label: imported
                                ? l10n.anitabiMapImportInPlan
                                : l10n.anitabiMapImportAddToPlan,
                            shortLabel: imported
                                ? l10n.anitabiMapImportAdded
                                : l10n.anitabiMapImportAddShort,
                            semanticLabel: imported
                                ? l10n.anitabiMapImportInPlan
                                : l10n.anitabiMapImportAddToPlan,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _copySummary {
    return [
      point.name,
      point.subtitle,
      point.episodeLabel,
      point.note ?? '',
      point.origin,
      '${point.position.latitude.toStringAsFixed(5)},${point.position.longitude.toStringAsFixed(5)}',
    ].where((value) => value.trim().isNotEmpty).join('\n');
  }
}

class _AnitabiPointDetailSheet extends StatelessWidget {
  const _AnitabiPointDetailSheet({
    required this.point,
    required this.imageUrl,
    required this.fullImageUrl,
    required this.localThumbnailPath,
    required this.localFullPath,
    required this.imported,
    required this.isImporting,
    required this.onImport,
  });

  final AnitabiPoint point;
  final String? imageUrl;
  final String? fullImageUrl;
  final String? localThumbnailPath;
  final String? localFullPath;
  final bool imported;
  final bool isImporting;
  final VoidCallback onImport;

  static Future<void> show(
    BuildContext context, {
    required AnitabiPoint point,
    required String? imageUrl,
    required String? fullImageUrl,
    required String? localThumbnailPath,
    required String? localFullPath,
    required bool imported,
    required bool isImporting,
    required VoidCallback onImport,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => _AnitabiPointDetailSheet(
        point: point,
        imageUrl: imageUrl,
        fullImageUrl: fullImageUrl,
        localThumbnailPath: localThumbnailPath,
        localFullPath: localFullPath,
        imported: imported,
        isImporting: isImporting,
        onImport: onImport,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Material(
                      color: AppColors.surfaceMuted,
                      child: InkWell(
                        onTap: fullImageUrl == null
                            ? null
                            : () => ImageViewerScreen.show(
                                context,
                                filePath: localFullPath,
                                imageUrl: fullImageUrl,
                              ),
                        child: SizedBox(
                          width: 112,
                          height: 112,
                          child: ReferenceThumbnail(
                            localPath: localThumbnailPath,
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: const Icon(LucideIcons.image),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CopyableText(
                          text: point.name,
                          copyLabel: l10n.anitabiMapImportSpotName,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _AnitabiDetailInfoLine(
                          icon: LucideIcons.film,
                          label: l10n.anitabiMapImportScene,
                          value: _anitabiPointCaption(point),
                        ),
                        if (point.note?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          _AnitabiDetailInfoLine(
                            icon: LucideIcons.stickyNote,
                            label: l10n.anitabiMapImportNote,
                            value: point.note!,
                          ),
                        ],
                        const SizedBox(height: 6),
                        _AnitabiDetailInfoLine(
                          icon: LucideIcons.fileCode,
                          label: l10n.anitabiMapImportSource,
                          value: point.origin,
                        ),
                        const SizedBox(height: 6),
                        _AnitabiDetailInfoLine(
                          icon: LucideIcons.mapPin,
                          label: l10n.anitabiMapImportCoordinates,
                          value:
                              '${point.position.latitude.toStringAsFixed(5)}, ${point.position.longitude.toStringAsFixed(5)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: imported || isImporting
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onImport();
                        },
                  child: ResponsiveButtonContent(
                    icon: imported ? LucideIcons.check : LucideIcons.mapPinPlus,
                    label: imported
                        ? l10n.anitabiMapImportInPlan
                        : l10n.anitabiMapImportAddToPlan,
                    shortLabel: imported
                        ? l10n.anitabiMapImportAdded
                        : l10n.anitabiMapImportAddShort,
                    semanticLabel: imported
                        ? l10n.anitabiMapImportInPlan
                        : l10n.anitabiMapImportAddToPlan,
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

class _AnitabiDetailInfoLine extends StatelessWidget {
  const _AnitabiDetailInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 38,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CopyableText(
            text: value,
            copyLabel: label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoPointSelectedCard extends StatelessWidget {
  const _NoPointSelectedCard({
    required this.hasPoints,
    required this.expectedCount,
  });

  final bool hasPoints;
  final int? expectedCount;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final message = hasPoints
        ? l10n.anitabiMapImportTapSpotHint
        : expectedCount == null || expectedCount == 0
        ? l10n.anitabiMapImportNoImportableSpots
        : l10n.anitabiMapImportNoImageSpots(expectedCount ?? 0);

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.pointer, color: AppColors.accentForeground),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
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

String? _anitabiThumbnailUrl(String? url) {
  final fullUrl = anitabiFullResolutionImageUrl(url);
  if (fullUrl == null || fullUrl.isEmpty) {
    return fullUrl;
  }

  final uri = Uri.tryParse(fullUrl);
  if (uri == null || !anitabiImageHosts.contains(uri.host)) {
    return fullUrl;
  }

  return uri
      .replace(queryParameters: {...uri.queryParameters, 'plan': 'h160'})
      .toString();
}

class _EmptyImportState extends StatelessWidget {
  const _EmptyImportState({required this.onSearch, required this.onPasteLink});

  final VoidCallback onSearch;
  final VoidCallback onPasteLink;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.clapperboard,
                    color: AppColors.accentForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.anitabiMapImportNoWorks,
                    style: TextStyle(
                      color: AppColors.accentStrongForeground,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _ImportWorkGuideTimeline(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('import-empty-search-button'),
                  onPressed: onSearch,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: const Icon(LucideIcons.search, size: 20),
                  label: Text(l10n.anitabiMapImportSearchWork),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onPasteLink,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: const Icon(LucideIcons.link, size: 20),
                  label: Text(l10n.anitabiMapImportPasteLink),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImportWorkGuideTimeline extends StatelessWidget {
  const _ImportWorkGuideTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ImportWorkGuideStep(
          title: l10n.anitabiMapImportFromBangumiTitle,
          body: l10n.anitabiMapImportFromBangumiBody,
          isLast: true,
        ),
      ],
    );
  }
}

class _ImportWorkGuideStep extends StatelessWidget {
  const _ImportWorkGuideStep({
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Stack(
              children: [
                if (!isLast)
                  Positioned(
                    left: 8,
                    top: 10,
                    bottom: 0,
                    child: Container(width: 2, color: AppColors.border),
                  ),
                Positioned(
                  left: 4,
                  top: 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
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

class _ManualWorkImportState extends StatelessWidget {
  const _ManualWorkImportState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          l10n.anitabiMapImportManualWorkState,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.45,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _NoAnitabiPointsState extends StatelessWidget {
  const _NoAnitabiPointsState({required this.workTitle});

  final String workTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.anitabiMapImportWorkNoSpots(workTitle),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.45,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _ImportLoadingState extends StatelessWidget {
  const _ImportLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              l10n.anitabiMapImportLoadingWorks,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportErrorState extends StatelessWidget {
  const _ImportErrorState({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  final String message;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.map, color: AppColors.textSecondary, size: 32),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw),
              label: Text(l10n.anitabiMapImportClearCacheReload),
            ),
          ],
        ),
      ),
    );
  }
}

/// Location note (when it differs from the name) and known episode.
String _anitabiPointCaption(AnitabiPoint point) => joinLabels([
  if (point.subtitle.trim() != point.name.trim()) point.subtitle,
  formatEpisodeLabelForDisplay(point.episodeLabel),
]);
