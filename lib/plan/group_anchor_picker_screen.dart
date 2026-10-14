import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../map/map_colors.dart';
import '../widgets/app_back_button.dart';
import '../widgets/clear_anchor_selection_button.dart';
import '../widgets/confirm_action_dialog.dart';
import '../map/map_tile_config.dart';
import '../map/map_marker_scale.dart';
import '../utils/selected_item_order.dart';
import '../map/current_location_resolver.dart';
import '../widgets/snackbar_helper.dart';
import 'coordinate_input_dialog.dart';
import 'pilgrimage_models.dart';
import '../l10n/l10n.dart';

class GroupAnchorSelection {
  const GroupAnchorSelection({
    required this.name,
    required this.position,
    required this.pointId,
  });

  const GroupAnchorSelection.clear()
    : name = null,
      position = null,
      pointId = null;

  final String? name;
  final LatLng? position;
  final String? pointId;
}

class GroupAnchorPickerScreen extends StatefulWidget {
  const GroupAnchorPickerScreen({
    required this.group,
    required this.points,
    required this.groupNameForPoint,
    required this.settings,
    this.forWalkStart = false,
    super.key,
  });

  /// Picks where an area's walk starts instead of its anchor: adds "My
  /// location", allows sorting with no start, and words things for that.
  final bool forWalkStart;

  final PilgrimagePlanGroup group;
  final List<PilgrimagePoint> points;
  final String Function(PilgrimagePoint point) groupNameForPoint;
  final AppSettings settings;

  @override
  State<GroupAnchorPickerScreen> createState() =>
      _GroupAnchorPickerScreenState();
}

class _GroupAnchorPickerScreenState extends State<GroupAnchorPickerScreen> {
  final MapController _mapController = MapController();
  PilgrimagePoint? _selectedPoint;
  LatLng? _manualPosition;
  var _manualPickMode = false;

  /// Whether [_manualPosition] is the phone's location.
  var _isMyLocation = false;

  /// The saved name of the starting [_manualPosition] (e.g. "My location"),
  /// shown until another point is picked.
  String? _savedManualName;
  var _locating = false;

  @override
  void initState() {
    super.initState();
    final anchorPointId = widget.group.anchorPointId;
    if (anchorPointId != null) {
      _selectedPoint = widget.points
          .where((point) => point.id == anchorPointId && point.hasCoordinate)
          .firstOrNull;
    }
    if (_selectedPoint == null &&
        widget.group.anchorLatitude != null &&
        widget.group.anchorLongitude != null) {
      _manualPosition = LatLng(
        widget.group.anchorLatitude!,
        widget.group.anchorLongitude!,
      );
      _savedManualName = widget.group.anchorName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPosition = _selectedPoint?.position ?? _manualPosition;
    final mapPoints = selectedItemsLast<PilgrimagePoint>(
      widget.points.where((point) => point.hasCoordinate),
      isSelected: (point) => point.id == _selectedPoint?.id,
    );

    return Scaffold(
      appBar: AppBar(
        leading: appBackButtonIfCanPop(context),
        title: Text(
          widget.forWalkStart
              ? l10n.walkStartPickerTitle
              : l10n.groupAnchorPickerTitle,
        ),
        actions: [
          ClearAnchorSelectionButton(
            onPressed: _selectedPoint == null && _manualPosition == null
                ? null
                : _confirmClearSelection,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedPosition ?? _pointsCenter,
              initialZoom: 15,
              // With nothing chosen yet, show all the spots to choose from.
              initialCameraFit:
                  selectedPosition == null && _positioned.length > 1
                  ? CameraFit.coordinates(
                      coordinates: _positioned,
                      padding: const EdgeInsets.fromLTRB(48, 48, 80, 140),
                      maxZoom: 16,
                    )
                  : null,
              minZoom: 4,
              maxZoom: widget.settings.mapMaxZoom.toDouble(),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, latLng) {
                if (!_manualPickMode) {
                  return;
                }
                setState(() {
                  _selectedPoint = null;
                  _manualPosition = latLng;
                  _isMyLocation = false;
                  _savedManualName = null;
                });
              },
            ),
            children: [
              configuredMapTileLayer(widget.settings),
              MarkerLayer(
                markers: [
                  for (final point in mapPoints)
                    Marker(
                      point: point.position,
                      width: scaledMapMarkerDimension(
                        42,
                        widget.settings.mapMarkerScale,
                      ),
                      height: scaledMapMarkerDimension(
                        42,
                        widget.settings.mapMarkerScale,
                      ),
                      child: ScaledMapMarker(
                        baseWidth: 42,
                        baseHeight: 42,
                        scale: widget.settings.mapMarkerScale,
                        child: _AnchorPointMarker(
                          selected: _selectedPoint?.id == point.id,
                          onTap: () => _selectPoint(point),
                        ),
                      ),
                    ),
                  if (_manualPosition != null)
                    Marker(
                      point: _manualPosition!,
                      width: scaledMapMarkerDimension(
                        46,
                        widget.settings.mapMarkerScale,
                      ),
                      height: scaledMapMarkerDimension(
                        46,
                        widget.settings.mapMarkerScale,
                      ),
                      child: ScaledMapMarker(
                        baseWidth: 46,
                        baseHeight: 46,
                        scale: widget.settings.mapMarkerScale,
                        child: const _ManualAnchorMarker(),
                      ),
                    ),
                ],
              ),
              configuredMapAttribution(widget.settings),
            ],
          ),
          Positioned(
            right: 12,
            top: 12,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _MapToolButton(
                    tooltip: _manualPickMode
                        ? l10n.groupAnchorPickerExitMapPick
                        : l10n.groupAnchorPickerStartMapPick,
                    selected: _manualPickMode,
                    onTap: () {
                      setState(() {
                        _manualPickMode = !_manualPickMode;
                      });
                    },
                    icon: LucideIcons.mousePointerClick,
                  ),
                  const SizedBox(height: 8),
                  _MapToolButton(
                    tooltip: l10n.groupAnchorPickerEnterCoordinates,
                    selected: false,
                    onTap: _showCoordinateInput,
                    icon: LucideIcons.mapPinPen,
                  ),
                  if (widget.forWalkStart) ...[
                    const SizedBox(height: 8),
                    _MapToolButton(
                      key: const ValueKey('walk-start-my-location'),
                      tooltip: l10n.walkStartPickerUseLocation,
                      selected: _isMyLocation,
                      onTap: _locating ? () {} : _useMyLocation,
                      icon: LucideIcons.locateFixed,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _AnchorSelectionCard(
              selectedPoint: _selectedPoint,
              manualPosition: _manualPosition,
              groupNameForPoint: widget.groupNameForPoint,
              manualPickMode: _manualPickMode,
              forWalkStart: widget.forWalkStart,
              isMyLocation: _isMyLocation,
              savedManualName: _savedManualName,
              // A walk can also be sorted without a start.
              onSave: selectedPosition == null && !widget.forWalkStart
                  ? null
                  : _saveSelection,
            ),
          ),
        ],
      ),
    );
  }

  late final _positioned = [
    for (final point in widget.points)
      if (point.hasCoordinate) point.position,
  ];

  LatLng get _pointsCenter {
    final positionedPoints = widget.points
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

  Future<void> _confirmClearSelection() async {
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.groupAnchorPickerClearSelection,
      message: l10n.groupAnchorPickerClearMessage,
      confirmLabel: l10n.groupAnchorPickerClearSelection,
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() {
      _selectedPoint = null;
      _manualPosition = null;
      _manualPickMode = false;
      _isMyLocation = false;
      _savedManualName = null;
    });
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      final position = await resolveCurrentLocation();
      if (!mounted) return;
      final here = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPoint = null;
        _manualPosition = here;
        _manualPickMode = false;
        _isMyLocation = true;
        _savedManualName = null;
      });
      _mapController.move(here, 16);
    } on CurrentLocationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showStatusSnack(
          kind: AppStatusBannerKind.error,
          title: currentLocationFailureMessage(error),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _selectPoint(PilgrimagePoint point) {
    setState(() {
      _selectedPoint = point;
      _manualPosition = null;
      _manualPickMode = false;
      _isMyLocation = false;
      _savedManualName = null;
    });
    _mapController.move(point.position, 16);
  }

  Future<void> _showCoordinateInput() async {
    final current =
        _manualPosition ?? _selectedPoint?.position ?? _pointsCenter;
    final result = await showCoordinateInputDialog(
      context: context,
      current: current,
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _selectedPoint = null;
      _manualPosition = result;
      _manualPickMode = false;
      _isMyLocation = false;
      _savedManualName = null;
    });
    _mapController.move(result, 16);
  }

  void _saveSelection() {
    final selectedPoint = _selectedPoint;
    if (selectedPoint != null) {
      Navigator.of(context).pop(
        GroupAnchorSelection(
          name: selectedPoint.name,
          position: selectedPoint.position,
          pointId: selectedPoint.id,
        ),
      );
      return;
    }
    final manualPosition = _manualPosition;
    if (manualPosition == null) {
      if (widget.forWalkStart) {
        Navigator.of(context).pop(const GroupAnchorSelection.clear());
      }
      return;
    }
    Navigator.of(context).pop(
      GroupAnchorSelection(
        name:
            _savedManualName ??
            (widget.forWalkStart
                ? (_isMyLocation
                      ? l10n.walkStartPickerMyLocation
                      : l10n.walkStartPickerPoint)
                : l10n.groupAnchorPickerManualAnchor),
        position: manualPosition,
        pointId: null,
      ),
    );
  }
}

class _AnchorPointMarker extends StatelessWidget {
  const _AnchorPointMarker({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: l10n.groupAnchorPickerSelectPoint,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: selected ? MapColors.accent : MapColors.surface,
        foregroundColor: selected ? MapColors.onAccent : MapColors.accent,
        side: BorderSide(
          color: selected ? AppColors.warning : MapColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      icon: const Icon(LucideIcons.mapPin, size: 21),
    );
  }
}

class _ManualAnchorMarker extends StatelessWidget {
  const _ManualAnchorMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: const Icon(LucideIcons.mapPinPlus, color: Colors.white),
    );
  }
}

class _MapToolButton extends StatelessWidget {
  const _MapToolButton({
    required this.tooltip,
    super.key,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // A standalone key on the map: ink frame, inverts to ink when on.
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      shape: Border.all(color: AppColors.ink),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon),
        color: selected ? AppColors.background : AppColors.textPrimary,
      ),
    );
  }
}

class _AnchorSelectionCard extends StatelessWidget {
  const _AnchorSelectionCard({
    required this.selectedPoint,
    required this.manualPosition,
    required this.groupNameForPoint,
    required this.manualPickMode,
    required this.forWalkStart,
    required this.isMyLocation,
    required this.savedManualName,
    required this.onSave,
  });

  final String? savedManualName;

  final bool forWalkStart;
  final bool isMyLocation;
  final PilgrimagePoint? selectedPoint;
  final LatLng? manualPosition;
  final String Function(PilgrimagePoint point) groupNameForPoint;
  final bool manualPickMode;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final point = selectedPoint;
    final position = point?.position ?? manualPosition;
    final title =
        point?.name ??
        (position != null ? savedManualName : null) ??
        (forWalkStart
            ? (position == null
                  ? l10n.walkStartPickerNone
                  : isMyLocation
                  ? l10n.walkStartPickerMyLocation
                  : l10n.walkStartPickerPoint)
            : position == null
            ? l10n.groupAnchorPickerNoneSelected
            : l10n.groupAnchorPickerManualAnchor);
    final subtitle = point == null
        ? (manualPickMode
              ? (forWalkStart
                    ? l10n.walkStartPickerMapHint
                    : l10n.groupAnchorPickerMapPickHint)
              : l10n.groupAnchorPickerIdleHint)
        : joinLabels([groupNameForPoint(point), point.displaySubtitle]);

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.ink),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.flag, color: AppColors.textSecondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position == null
                      ? subtitle
                      : '$subtitle\n${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
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
          FilledButton(
            key: const ValueKey('anchor-picker-save'),
            onPressed: onSave,
            child: Text(
              forWalkStart ? l10n.walkStartPickerSort : l10n.commonSave,
            ),
          ),
        ],
      ),
    );
  }
}
