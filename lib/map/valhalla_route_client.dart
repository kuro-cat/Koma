import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../data/valhalla_service_config.dart';
import '../l10n/l10n.dart';

class NavigationRoute {
  const NavigationRoute({
    required this.shape,
    required this.maneuvers,
    required this.distanceKm,
    required this.duration,
    List<NavigationLeg>? legs,
  }) : _explicitLegs = legs;

  final List<LatLng> shape;
  final List<NavigationManeuver> maneuvers;
  final double distanceKm;
  final Duration duration;
  final List<NavigationLeg>? _explicitLegs;

  /// Route legs between consecutive stops. Routes built without explicit legs
  /// are treated as a single leg covering the whole shape.
  List<NavigationLeg> get legs {
    final legs = _explicitLegs;
    if (legs != null && legs.isNotEmpty) return legs;
    return [
      NavigationLeg(
        startShapeIndex: 0,
        endShapeIndex: shape.isEmpty ? 0 : shape.length - 1,
        firstManeuverIndex: 0,
        maneuverCount: maneuvers.length,
        distanceKm: distanceKm,
        duration: duration,
      ),
    ];
  }
}

class NavigationLeg {
  const NavigationLeg({
    required this.startShapeIndex,
    required this.endShapeIndex,
    required this.firstManeuverIndex,
    required this.maneuverCount,
    required this.distanceKm,
    required this.duration,
  });

  final int startShapeIndex;
  final int endShapeIndex;
  final int firstManeuverIndex;
  final int maneuverCount;
  final double distanceKm;
  final Duration duration;

  int get endManeuverIndex => firstManeuverIndex + maneuverCount;
}

class NavigationManeuver {
  const NavigationManeuver({
    required this.type,
    required this.instruction,
    required this.distanceKm,
    required this.beginShapeIndex,
    required this.endShapeIndex,
  });

  final int type;
  final String instruction;
  final double distanceKm;
  final int beginShapeIndex;
  final int endShapeIndex;
}

class ValhallaRouteException implements Exception {
  const ValhallaRouteException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ValhallaRouteClient {
  ValhallaRouteClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
    this.cacheDuration = const Duration(minutes: 5),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final Duration cacheDuration;
  final Map<String, _CachedRoute> _cache = {};

  Future<NavigationRoute> route({
    required String baseUrl,
    required List<LatLng> locations,
  }) async {
    if (locations.length < 2) {
      throw ValhallaRouteException(l10n.valhallaRouteClientNeedsTwoStops);
    }
    final normalizedBaseUrl = normalizeValhallaBaseUrl(baseUrl);
    final validationError = validateValhallaBaseUrl(normalizedBaseUrl);
    if (validationError != null) {
      throw ValhallaRouteException(validationError);
    }

    final cacheKey = _cacheKey(normalizedBaseUrl, locations);
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.createdAt) < cacheDuration) {
      return cached.route;
    }

    final uri = Uri.parse('$normalizedBaseUrl/route');
    late http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-Client-Id': 'Koma',
            },
            body: jsonEncode({
              'locations': [
                for (final point in locations)
                  {
                    'lat': point.latitude,
                    'lon': point.longitude,
                    'type': 'break',
                  },
              ],
              'costing': 'pedestrian',
              'units': 'kilometers',
              'language': 'en-US',
              'directions_options': {'units': 'kilometers'},
              'shape_format': 'polyline6',
            }),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw ValhallaRouteException(l10n.valhallaRouteClientTimeout);
    } on Object catch (error) {
      throw ValhallaRouteException(
        l10n.valhallaRouteClientConnectionFailed('$error'),
      );
    }

    if (response.statusCode == 429) {
      throw ValhallaRouteException(l10n.valhallaRouteClientRateLimited);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final known = valhallaErrorMessage(response.body);
      throw ValhallaRouteException(
        known ??
            (response.statusCode >= 500
                ? l10n.valhallaRouteClientServiceUnavailable(
                    response.statusCode,
                  )
                : l10n.valhallaRouteClientRouteFailed(response.statusCode)),
      );
    }

    final parsed = _parseRoute(response.body);
    _cache[cacheKey] = _CachedRoute(parsed, DateTime.now());
    _cache.removeWhere(
      (_, entry) => DateTime.now().difference(entry.createdAt) >= cacheDuration,
    );
    return parsed;
  }

  Future<void> testConnection(String baseUrl) async {
    final normalized = normalizeValhallaBaseUrl(baseUrl);
    final validationError = validateValhallaBaseUrl(normalized);
    if (validationError != null) {
      throw ValhallaRouteException(validationError);
    }
    try {
      final response = await _client
          .get(
            Uri.parse('$normalized/status'),
            headers: const {
              'Accept': 'application/json',
              'X-Client-Id': 'Koma',
            },
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ValhallaRouteException(
          l10n.valhallaRouteClientStatus(response.statusCode),
        );
      }
    } on TimeoutException {
      throw ValhallaRouteException(l10n.valhallaRouteClientTestTimeout);
    }
  }

  NavigationRoute _parseRoute(String body) {
    try {
      final root = jsonDecode(body) as Map<String, dynamic>;
      final trip = root['trip'] as Map<String, dynamic>;
      final summary = trip['summary'] as Map<String, dynamic>;
      final legs = (trip['legs'] as List<dynamic>).cast<Map<String, dynamic>>();
      final shape = <LatLng>[];
      final maneuvers = <NavigationManeuver>[];
      final parsedLegs = <NavigationLeg>[];

      for (final leg in legs) {
        final legShape = decodePolyline6(leg['shape'] as String);
        final sharesFirstPoint =
            shape.isNotEmpty &&
            legShape.isNotEmpty &&
            shape.last == legShape.first;
        final offset = sharesFirstPoint ? shape.length - 1 : shape.length;
        if (sharesFirstPoint) {
          shape.addAll(legShape.skip(1));
        } else {
          shape.addAll(legShape);
        }
        final firstManeuverIndex = maneuvers.length;
        for (final raw in (leg['maneuvers'] as List<dynamic>? ?? const [])) {
          final maneuver = raw as Map<String, dynamic>;
          final type = (maneuver['type'] as num?)?.toInt() ?? 0;
          final begin = (maneuver['begin_shape_index'] as num?)?.toInt() ?? 0;
          final end = (maneuver['end_shape_index'] as num?)?.toInt() ?? begin;
          maneuvers.add(
            NavigationManeuver(
              type: type,
              instruction: localizedManeuverInstruction(
                type,
                streetNames: [
                  ?preferredStreetName(
                    beginStreetNames: _stringList(
                      maneuver['begin_street_names'],
                    ),
                    streetNames: _stringList(maneuver['street_names']),
                  ),
                ],
                fallbackInstruction: maneuver['instruction'] as String?,
              ),
              distanceKm: (maneuver['length'] as num?)?.toDouble() ?? 0,
              beginShapeIndex: (offset + begin).clamp(0, shape.length - 1),
              endShapeIndex: (offset + end).clamp(0, shape.length - 1),
            ),
          );
        }
        final legSummary = leg['summary'] as Map<String, dynamic>?;
        parsedLegs.add(
          NavigationLeg(
            startShapeIndex: offset.clamp(0, shape.length - 1),
            endShapeIndex: shape.length - 1,
            firstManeuverIndex: firstManeuverIndex,
            maneuverCount: maneuvers.length - firstManeuverIndex,
            distanceKm: (legSummary?['length'] as num?)?.toDouble() ?? 0,
            duration: Duration(
              seconds: (legSummary?['time'] as num?)?.round() ?? 0,
            ),
          ),
        );
      }
      if (shape.length < 2) {
        throw const FormatException('missing route shape');
      }
      return NavigationRoute(
        shape: List.unmodifiable(shape),
        maneuvers: List.unmodifiable(maneuvers),
        distanceKm: (summary['length'] as num?)?.toDouble() ?? 0,
        duration: Duration(seconds: (summary['time'] as num?)?.round() ?? 0),
        legs: List.unmodifiable(parsedLegs),
      );
    } on Object {
      throw ValhallaRouteException(l10n.valhallaRouteClientBadResponse);
    }
  }
}

List<String> _stringList(Object? value) => value is List
    ? value.whereType<String>().toList(growable: false)
    : const [];

final _cjkPattern = RegExp(
  r'[\u3040-\u30ff\u3400-\u9fff\uf900-\ufaff\uac00-\ud7af]',
);
// Route numbers such as "15", "467", "R1" or "E1-2" rather than street names.
// Uppercase-only prefixes/suffixes keep "1st Avenue" or "N 1st St".
final _routeRefPattern = RegExp(
  r'^(?:[A-Z]{1,3}[\s-]?)?\d+[A-Z]?(?:[-/.]\d+[A-Z]?)*$',
);

/// Picks the street name to show for a maneuver.
///
/// Valhalla lists every name of a way, e.g. `['さんさん通り', 'Sun Sun Street',
/// '52', '沼津停車場線']` or `['467', '国道467号']`. Names at the turn itself
/// (`begin_street_names`) are preferred; bare route numbers are skipped; and a
/// Chinese/Japanese/Korean name wins over a romanised one when both exist.
String? preferredStreetName({
  List<String> beginStreetNames = const [],
  List<String> streetNames = const [],
}) {
  for (final names in [beginStreetNames, streetNames]) {
    final candidates = [
      for (final name in names)
        if (name.trim().isNotEmpty && !_routeRefPattern.hasMatch(name.trim()))
          name.trim(),
    ];
    if (candidates.isEmpty) continue;
    return candidates.firstWhere(
      _cjkPattern.hasMatch,
      orElse: () => candidates.first,
    );
  }
  return null;
}

/// Readable message for a Valhalla error response body, or null when the
/// body is not a recognised Valhalla error.
String? valhallaErrorMessage(String body) {
  Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return null;
  }
  if (decoded is! Map) return null;
  final code = switch (decoded['error_code']) {
    final num value => value.toInt(),
    _ => null,
  };
  return switch (code) {
    170 => l10n.valhallaRouteClientError170,
    171 => l10n.valhallaRouteClientError171,
    154 => l10n.valhallaRouteClientError154,
    442 => l10n.valhallaRouteClientError442,
    _ => null,
  };
}

String localizedManeuverInstruction(
  int type, {
  List<String> streetNames = const [],
  String? fallbackInstruction,
}) {
  final road = streetNames.where((name) => name.trim().isNotEmpty).firstOrNull;
  // Values follow Valhalla Directions Maneuver.Type.
  return switch (type) {
    1 =>
      road == null
          ? l10n.valhallaRouteClientStartWalking
          : l10n.valhallaRouteClientStartAlong(road),
    2 =>
      road == null
          ? l10n.valhallaRouteClientHeadRight
          : l10n.valhallaRouteClientHeadRightOnto(road),
    3 =>
      road == null
          ? l10n.valhallaRouteClientHeadLeft
          : l10n.valhallaRouteClientHeadLeftOnto(road),
    4 || 5 || 6 =>
      road == null
          ? l10n.valhallaRouteClientArrive
          : l10n.valhallaRouteClientArriveNear(road),
    7 =>
      road == null
          ? l10n.valhallaRouteClientContinue
          : l10n.valhallaRouteClientContinueOnto(road),
    8 =>
      road == null
          ? l10n.valhallaRouteClientGoStraight
          : l10n.valhallaRouteClientGoStraightAlong(road),
    9 =>
      road == null
          ? l10n.valhallaRouteClientBearRight
          : l10n.valhallaRouteClientBearRightOnto(road),
    10 =>
      road == null
          ? l10n.valhallaRouteClientTurnRight
          : l10n.valhallaRouteClientTurnRightOnto(road),
    11 =>
      road == null
          ? l10n.valhallaRouteClientSharpRight
          : l10n.valhallaRouteClientSharpRightOnto(road),
    12 || 13 => l10n.valhallaRouteClientUTurn,
    14 =>
      road == null
          ? l10n.valhallaRouteClientSharpLeft
          : l10n.valhallaRouteClientSharpLeftOnto(road),
    15 =>
      road == null
          ? l10n.valhallaRouteClientTurnLeft
          : l10n.valhallaRouteClientTurnLeftOnto(road),
    16 =>
      road == null
          ? l10n.valhallaRouteClientBearLeft
          : l10n.valhallaRouteClientBearLeftOnto(road),
    17 =>
      road == null
          ? l10n.valhallaRouteClientRampStraight
          : l10n.valhallaRouteClientRampStraightAlong(road),
    18 =>
      road == null
          ? l10n.valhallaRouteClientRampRight
          : l10n.valhallaRouteClientRampRightOnto(road),
    19 =>
      road == null
          ? l10n.valhallaRouteClientRampLeft
          : l10n.valhallaRouteClientRampLeftOnto(road),
    20 => l10n.valhallaRouteClientExitRight,
    21 => l10n.valhallaRouteClientExitLeft,
    22 =>
      road == null
          ? l10n.valhallaRouteClientStayStraight
          : l10n.valhallaRouteClientStayStraightAlong(road),
    23 =>
      road == null
          ? l10n.valhallaRouteClientKeepRight
          : l10n.valhallaRouteClientKeepRightAlong(road),
    24 =>
      road == null
          ? l10n.valhallaRouteClientKeepLeft
          : l10n.valhallaRouteClientKeepLeftAlong(road),
    25 =>
      road == null
          ? l10n.valhallaRouteClientMerge
          : l10n.valhallaRouteClientMergeOnto(road),
    26 => l10n.valhallaRouteClientEnterRoundabout,
    27 => l10n.valhallaRouteClientExitRoundabout,
    28 => l10n.valhallaRouteClientBoardFerry,
    29 => l10n.valhallaRouteClientLeaveFerry,
    30 => l10n.valhallaRouteClientTakeTransit,
    31 || 34 => l10n.valhallaRouteClientTransfer,
    32 => l10n.valhallaRouteClientStayOnLine,
    33 => l10n.valhallaRouteClientToTransitConnection,
    35 || 36 => l10n.valhallaRouteClientTransitArrive,
    37 =>
      road == null
          ? l10n.valhallaRouteClientMergeRight
          : l10n.valhallaRouteClientMergeRightOnto(road),
    38 =>
      road == null
          ? l10n.valhallaRouteClientMergeLeft
          : l10n.valhallaRouteClientMergeLeftOnto(road),
    39 => l10n.valhallaRouteClientElevator,
    40 => l10n.valhallaRouteClientStairs,
    41 => l10n.valhallaRouteClientEscalator,
    42 => l10n.valhallaRouteClientEnterBuilding,
    43 => l10n.valhallaRouteClientExitBuilding,
    44 => l10n.valhallaRouteClientOtherFloor,
    45 => l10n.valhallaRouteClientParkAndWalk,
    _ =>
      fallbackInstruction?.trim().isNotEmpty == true
          ? fallbackInstruction!.trim()
          : (road == null
                ? l10n.valhallaRouteClientContinue
                : l10n.valhallaRouteClientContinueAlong(road)),
  };
}

List<LatLng> decodePolyline6(String encoded) {
  final points = <LatLng>[];
  var index = 0;
  var latitude = 0;
  var longitude = 0;
  while (index < encoded.length) {
    final latitudeResult = _decodeCoordinate(encoded, index);
    index = latitudeResult.nextIndex;
    latitude += latitudeResult.delta;
    final longitudeResult = _decodeCoordinate(encoded, index);
    index = longitudeResult.nextIndex;
    longitude += longitudeResult.delta;
    points.add(LatLng(latitude / 1e6, longitude / 1e6));
  }
  return points;
}

_DecodedCoordinate _decodeCoordinate(String encoded, int startIndex) {
  var result = 0;
  var shift = 0;
  var index = startIndex;
  int byte;
  do {
    if (index >= encoded.length) {
      throw const FormatException('truncated polyline');
    }
    byte = encoded.codeUnitAt(index++) - 63;
    result |= (byte & 0x1f) << shift;
    shift += 5;
  } while (byte >= 0x20);
  final delta = (result & 1) == 1 ? ~(result >> 1) : result >> 1;
  return _DecodedCoordinate(delta, index);
}

String _cacheKey(String baseUrl, List<LatLng> points) => [
  baseUrl,
  for (final point in points)
    '${point.latitude.toStringAsFixed(5)},${point.longitude.toStringAsFixed(5)}',
].join('|');

class _CachedRoute {
  const _CachedRoute(this.route, this.createdAt);
  final NavigationRoute route;
  final DateTime createdAt;
}

class _DecodedCoordinate {
  const _DecodedCoordinate(this.delta, this.nextIndex);
  final int delta;
  final int nextIndex;
}
