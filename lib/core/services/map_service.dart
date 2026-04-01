import 'dart:math';
import '../models/race_route.dart';
import 'supabase_service.dart';

class MapService {
  final SupabaseService _supabaseService;

  MapService({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  /// Busca a rota de uma corrida pelo raceId
  Future<RaceRoute?> getRoute(String raceId) async {
    return _supabaseService.getRouteByRaceId(raceId);
  }

  /// Salva ou atualiza uma rota
  Future<RaceRoute> saveRoute(RaceRoute route) async {
    return _supabaseService.upsertRoute(route);
  }

  /// Parseia uma string GPX e retorna uma RaceRoute
  RaceRoute parseGpx(String gpxXml, String raceId) {
    // Parse manual simplificado do GPX
    // O pacote `gpx` faz isso de forma mais robusta,
    // mas aqui temos um fallback basico
    final points = <RoutePoint>[];
    final trkptRegex = RegExp(
      r'<trkpt\s+lat="([^"]+)"\s+lon="([^"]+)"[^>]*>.*?(?:<ele>([^<]*)</ele>)?.*?</trkpt>',
      dotAll: true,
    );

    for (final match in trkptRegex.allMatches(gpxXml)) {
      final lat = double.tryParse(match.group(1) ?? '') ?? 0;
      final lon = double.tryParse(match.group(2) ?? '') ?? 0;
      final ele = double.tryParse(match.group(3) ?? '');
      points.add(RoutePoint(latitude: lat, longitude: lon, elevation: ele));
    }

    // Calcular metricas
    double totalDistance = 0;
    double elevationGain = 0;
    double elevationLoss = 0;
    double maxElevation = double.negativeInfinity;
    double minElevation = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      if (point.elevation != null) {
        if (point.elevation! > maxElevation) maxElevation = point.elevation!;
        if (point.elevation! < minElevation) minElevation = point.elevation!;
      }

      if (i > 0) {
        totalDistance += _haversineDistance(
          points[i - 1].latitude,
          points[i - 1].longitude,
          point.latitude,
          point.longitude,
        );

        final prevEle = points[i - 1].elevation;
        final currEle = point.elevation;
        if (prevEle != null && currEle != null) {
          final diff = currEle - prevEle;
          if (diff > 0) {
            elevationGain += diff;
          } else {
            elevationLoss += diff.abs();
          }
        }
      }
    }

    // Adicionar distancia acumulada a cada ponto
    final pointsWithDistance = <RoutePoint>[];
    double cumDist = 0;
    for (int i = 0; i < points.length; i++) {
      if (i > 0) {
        cumDist += _haversineDistance(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude,
        );
      }
      pointsWithDistance.add(RoutePoint(
        latitude: points[i].latitude,
        longitude: points[i].longitude,
        elevation: points[i].elevation,
        cumulativeDistance: cumDist,
      ));
    }

    if (maxElevation == double.negativeInfinity) maxElevation = 0;
    if (minElevation == double.infinity) minElevation = 0;

    return RaceRoute(
      id: '',
      raceId: raceId,
      gpxData: gpxXml,
      coordinates: pointsWithDistance,
      totalDistance: totalDistance,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
      maxElevation: maxElevation,
      minElevation: minElevation,
      difficultyScore: _calculateDifficulty(
        totalDistance,
        elevationGain,
        maxElevation,
      ),
      createdAt: DateTime.now(),
    );
  }

  /// Formula de Haversine para calcular distancia entre dois pontos (em km)
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  /// Calcula score de dificuldade (0-10) baseado em distancia e elevacao
  double _calculateDifficulty(
    double distanceKm,
    double elevationGain,
    double maxElevation,
  ) {
    // Formula simplificada:
    // - Distancia contribui com 40%
    // - Ganho de elevacao com 40%
    // - Altitude maxima com 20% (efeito altitude)
    final distScore = (distanceKm / 100).clamp(0, 10).toDouble();
    final eleScore = (elevationGain / 3000 * 10).clamp(0, 10).toDouble();
    final altScore = (maxElevation / 4000 * 10).clamp(0, 10).toDouble();

    return (distScore * 0.4 + eleScore * 0.4 + altScore * 0.2);
  }

  /// Simplifica uma lista de pontos para exibicao no mapa
  /// usando o algoritmo de Douglas-Peucker
  List<RoutePoint> simplifyRoute(List<RoutePoint> points, {double tolerance = 0.0001}) {
    if (points.length <= 2) return points;

    double maxDist = 0;
    int maxIndex = 0;

    final start = points.first;
    final end = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final dist = _perpendicularDistance(points[i], start, end);
      if (dist > maxDist) {
        maxDist = dist;
        maxIndex = i;
      }
    }

    if (maxDist > tolerance) {
      final left = simplifyRoute(points.sublist(0, maxIndex + 1), tolerance: tolerance);
      final right = simplifyRoute(points.sublist(maxIndex), tolerance: tolerance);
      return [...left.sublist(0, left.length - 1), ...right];
    }

    return [start, end];
  }

  double _perpendicularDistance(RoutePoint point, RoutePoint start, RoutePoint end) {
    final dx = end.latitude - start.latitude;
    final dy = end.longitude - start.longitude;

    if (dx == 0 && dy == 0) {
      return sqrt(
        pow(point.latitude - start.latitude, 2) +
            pow(point.longitude - start.longitude, 2),
      );
    }

    final t = ((point.latitude - start.latitude) * dx +
            (point.longitude - start.longitude) * dy) /
        (dx * dx + dy * dy);

    final projLat = start.latitude + t * dx;
    final projLon = start.longitude + t * dy;

    return sqrt(
      pow(point.latitude - projLat, 2) + pow(point.longitude - projLon, 2),
    );
  }
}
