import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

import 'current_location_resolver.dart';
import '../l10n/l10n.dart';

/// A visible ordinary map owns its subscription, never the photo resolver.
class MapLocationTracker extends ChangeNotifier {
  MapLocationTracker({
    Future<Position> Function(Future<void> cancelled)? resolve,
    LocationStreamFactory? streamFactory,
    this.staleAfter = const Duration(seconds: 60),
  }) : _resolve =
           resolve ??
           ((cancelled) => resolveCurrentLocation(cancelled: cancelled)),
       _streamFactory =
           streamFactory ??
           ((settings) =>
               Geolocator.getPositionStream(locationSettings: settings));

  final Future<Position> Function(Future<void> cancelled) _resolve;
  final LocationStreamFactory _streamFactory;
  final Duration staleAfter;
  Position? position;
  String? error;
  bool locating = false;
  bool enabled = false;
  bool _active = false;
  bool _continuous = true;
  bool _disposed = false;
  int _request = 0;
  int _session = 0;
  StreamSubscription<Position>? _subscription;
  Future<void> _cancelled = Future<void>.value();
  Future<void> _requestStopped = Future<void>.value();
  Timer? _freshness;
  Completer<void>? _requestCancelled;
  bool _resumeRequest = false;

  void configure({required bool active, required bool continuous}) {
    if (_active == active && _continuous == continuous) return;
    _active = active;
    _continuous = continuous;
    if (!active && locating) {
      _resumeRequest = true;
      _cancelRequest();
    }
    if (active && _resumeRequest) {
      final request = _request;
      scheduleMicrotask(() {
        if (!_disposed && _active && _resumeRequest && request == _request) {
          _resumeRequest = false;
          unawaited(locate());
        }
      });
    }
    _restart();
  }

  Future<Position?> locate() async {
    _cancelRequest();
    _resumeRequest = false;
    final request = ++_request;
    final cancellation = _requestCancelled = Completer<void>();
    _stop();
    locating = true;
    error = null;
    notifyListeners();
    try {
      await _cancelled;
      if (_disposed || request != _request) return null;
      final resolution = _resolve(cancellation.future);
      _requestStopped = resolution.then<void>(
        (_) {},
        onError: (Object _, StackTrace _) {},
      );
      final result = await resolution;
      if (_disposed || request != _request) return null;
      if (!validMapPosition(result)) {
        throw const CurrentLocationException(CurrentLocationFailure.timeout);
      }
      position = result;
      enabled = true;
      return result;
    } catch (exception) {
      if (!_disposed && request == _request) {
        error = locationUpdateError(exception);
      }
      return null;
    } finally {
      if (!_disposed && request == _request) {
        locating = false;
        notifyListeners();
        _restart();
      }
    }
  }

  void disable() {
    _cancelRequest();
    _resumeRequest = false;
    enabled = false;
    locating = false;
    error = null;
    _stop();
    notifyListeners();
  }

  void _cancelRequest() {
    ++_request;
    final cancellation = _requestCancelled;
    _requestCancelled = null;
    if (cancellation != null && !cancellation.isCompleted) {
      cancellation.complete();
    }
    // Await resolver cleanup as well as continuous-stream cancellation before
    // opening a new platform stream after a quick hide/resume.
    _cancelled = Future.wait<void>([_cancelled, _requestStopped]).then((_) {});
    locating = false;
  }

  void _stop() {
    ++_session;
    _freshness?.cancel();
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      _cancelled = Future.wait<void>([
        _cancelled,
        subscription.cancel().catchError((Object _) {}),
      ]).then((_) {});
    }
  }

  void _restart() {
    _stop();
    if (_disposed || !_active || !_continuous || !enabled || locating) return;
    final session = _session;
    unawaited(_start(session));
  }

  Future<void> _start(int session) async {
    await _cancelled;
    if (_disposed || session != _session) return;
    try {
      final settings =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0,
              intervalDuration: const Duration(seconds: 5),
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0,
            );
      _subscription = _streamFactory(settings).listen(
        (value) {
          if (_disposed || session != _session) return;
          if (!validMapPosition(value)) return;
          position = value;
          error = null;
          notifyListeners();
          _armFreshness(session);
        },
        onError: (Object exception) {
          if (_disposed || session != _session) return;
          error = locationUpdateError(exception);
          notifyListeners();
        },
        onDone: () {
          if (_disposed || session != _session) return;
          error = l10n.mapLocationTrackerStopped;
          notifyListeners();
        },
      );
      _armFreshness(session);
    } catch (exception) {
      if (_disposed || session != _session) return;
      error = locationUpdateError(exception);
      notifyListeners();
    }
  }

  void _armFreshness(int session) {
    _freshness?.cancel();
    _freshness = Timer(staleAfter, () {
      if (_disposed || session != _session) return;
      error = l10n.mapLocationTrackerStale;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelRequest();
    _stop();
    super.dispose();
  }
}

bool validMapPosition(Position position) =>
    position.latitude.isFinite &&
    position.longitude.isFinite &&
    position.latitude.abs() <= 90 &&
    position.longitude.abs() <= 180;

String locationUpdateError(Object exception) {
  if (exception is CurrentLocationException) {
    return currentLocationFailureMessage(exception);
  }
  if (exception is LocationServiceDisabledException) {
    return l10n.mapLocationTrackerServiceDisabled;
  }
  if (exception is PermissionDeniedException) {
    return l10n.mapLocationTrackerPermissionDenied;
  }
  return l10n.mapLocationTrackerFailed;
}

/// IndexedStack visibility is explicit; route coverage and app state are observed.
mixin MapLocationLifecycle<T extends StatefulWidget> on State<T> {
  bool get locationPageEnabled;
  void onLocationActivityChanged(bool active);
  bool _routeVisible = true;
  bool _foreground = true;
  bool? _lastActive;
  late final _observer = _MapLifecycleObserver((state) {
    _foreground = state == AppLifecycleState.resumed;
    syncLocationActivity();
  });

  @override
  void initState() {
    super.initState();
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(_observer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeVisible = ModalRoute.isCurrentOf(context) ?? true;
    syncLocationActivity();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncLocationActivity();
  }

  bool get locationPageActive =>
      _routeVisible && _foreground && locationPageEnabled;

  void syncLocationActivity({bool force = false}) {
    final active = locationPageActive;
    if (!force && _lastActive == active) return;
    _lastActive = active;
    onLocationActivityChanged(active);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }
}

class _MapLifecycleObserver extends WidgetsBindingObserver {
  _MapLifecycleObserver(this.onState);
  final ValueChanged<AppLifecycleState> onState;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onState(state);
}
