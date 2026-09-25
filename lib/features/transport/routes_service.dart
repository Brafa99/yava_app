import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yava_delivery_driver/app/config/api_routes_config.dart';

class RouteResult {
  const RouteResult({
    required this.distanceMeters,
    required this.duration,
    required this.polylinePoints,
  });

  final double distanceMeters;
  final Duration duration;
  final List<LatLng> polylinePoints;

  double get distanceKilometers =>
      distanceMeters / 1000.0;

  double get durationMinutes =>
      duration.inSeconds / 60.0;
}

class RoutesService {
  RoutesService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _endpoint =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  Future<RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (RoutesApiConfig.apiKey.isEmpty) {
      throw StateError(
        'La API key de Routes API está vacía.',
      );
    }

    final uri = Uri.parse(_endpoint);

    final body = <String, dynamic>{
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
        },
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          },
        },
      },
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE',
      'computeAlternativeRoutes': false,
      'languageCode': 'es',
      'units': 'METRIC',
    };

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': RoutesApiConfig.apiKey,
        'X-Goog-FieldMask':
            'routes.duration,'
            'routes.distanceMeters,'
            'routes.polyline.encodedPolyline',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      debugPrint(
        'Routes API error '
        '${response.statusCode}: '
        '${response.body}',
      );

      throw Exception(
        'Google Routes API respondió '
        'con código ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Respuesta inválida de Google Routes API.',
      );
    }

    final routes = decoded['routes'];

    if (routes is! List || routes.isEmpty) {
      return null;
    }

    final route = routes.first;

    if (route is! Map) {
      throw Exception(
        'La ruta recibida no tiene un formato válido.',
      );
    }

    final distanceValue = route['distanceMeters'];

    final distanceMeters = distanceValue is num
        ? distanceValue.toDouble()
        : double.tryParse(
              distanceValue?.toString() ?? '',
            ) ??
            0.0;

    final durationString =
        route['duration']?.toString();

    final duration = _parseGoogleDuration(
      durationString,
    );

    final polyline = route['polyline'];

    String encodedPolyline = '';

    if (polyline is Map) {
      encodedPolyline =
          polyline['encodedPolyline']?.toString() ?? '';
    }

    final points = decodePolyline(
      encodedPolyline,
    );

    return RouteResult(
      distanceMeters: distanceMeters,
      duration: duration,
      polylinePoints: points,
    );
  }

  Duration _parseGoogleDuration(
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return Duration.zero;
    }

    final normalized = value.endsWith('s')
        ? value.substring(
            0,
            value.length - 1,
          )
        : value;

    final seconds = double.tryParse(
          normalized,
        ) ??
        0;

    return Duration(
      milliseconds: (seconds * 1000).round(),
    );
  }

  static List<LatLng> decodePolyline(
    String encoded,
  ) {
    if (encoded.isEmpty) {
      return const [];
    }

    final points = <LatLng>[];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;

      while (true) {
        if (index >= encoded.length) {
          return points;
        }

        final byte =
            encoded.codeUnitAt(index++) - 63;

        result |= (byte & 0x1f) << shift;
        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final deltaLatitude =
          (result & 1) != 0
              ? ~(result >> 1)
              : result >> 1;

      latitude += deltaLatitude;

      result = 0;
      shift = 0;

      while (true) {
        if (index >= encoded.length) {
          return points;
        }

        final byte =
            encoded.codeUnitAt(index++) - 63;

        result |= (byte & 0x1f) << shift;
        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final deltaLongitude =
          (result & 1) != 0
              ? ~(result >> 1)
              : result >> 1;

      longitude += deltaLongitude;

      points.add(
        LatLng(
          latitude / 100000.0,
          longitude / 100000.0,
        ),
      );
    }

    return points;
  }

  void dispose() {
    _client.close();
  }
}