import 'package:equatable/equatable.dart';

class RaceRoute extends Equatable {
  final String id;
  final String raceId;
  final String? gpxData;
  final List<RoutePoint> coordinates;
  final double totalDistance;
  final double elevationGain;
  final double elevationLoss;
  final double maxElevation;
  final double minElevation;
  final double? difficultyScore;
  final List<String> terrainTypes;
  final List<AidStation> aidStations;
  final DateTime createdAt;

  const RaceRoute({
    required this.id,
    required this.raceId,
    this.gpxData,
    required this.coordinates,
    required this.totalDistance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.maxElevation,
    required this.minElevation,
    this.difficultyScore,
    this.terrainTypes = const [],
    this.aidStations = const [],
    required this.createdAt,
  });

  factory RaceRoute.fromMap(Map<String, dynamic> map) {
    return RaceRoute(
      id: map['id'] ?? '',
      raceId: map['race_id'] ?? '',
      gpxData: map['gpx_data'],
      coordinates: _parseCoordinates(map['coordinates']),
      totalDistance: (map['total_distance'] as num?)?.toDouble() ?? 0.0,
      elevationGain: (map['elevation_gain'] as num?)?.toDouble() ?? 0.0,
      elevationLoss: (map['elevation_loss'] as num?)?.toDouble() ?? 0.0,
      maxElevation: (map['max_elevation'] as num?)?.toDouble() ?? 0.0,
      minElevation: (map['min_elevation'] as num?)?.toDouble() ?? 0.0,
      difficultyScore: (map['difficulty_score'] as num?)?.toDouble(),
      terrainTypes: _parseStringList(map['terrain_types']),
      aidStations: _parseAidStations(map['aid_stations']),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'race_id': raceId,
      'gpx_data': gpxData,
      'coordinates': coordinates.map((c) => c.toList()).toList(),
      'total_distance': totalDistance,
      'elevation_gain': elevationGain,
      'elevation_loss': elevationLoss,
      'max_elevation': maxElevation,
      'min_elevation': minElevation,
      'difficulty_score': difficultyScore,
      'terrain_types': terrainTypes,
      'aid_stations': aidStations.map((a) => a.toMap()).toList(),
    };
  }

  static List<RoutePoint> _parseCoordinates(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) {
        if (item is List && item.length >= 2) {
          return RoutePoint(
            latitude: (item[0] as num).toDouble(),
            longitude: (item[1] as num).toDouble(),
            elevation: item.length > 2 ? (item[2] as num).toDouble() : null,
          );
        }
        if (item is Map) {
          return RoutePoint(
            latitude: (item['lat'] as num?)?.toDouble() ?? 0,
            longitude: (item['lng'] as num?)?.toDouble() ?? 0,
            elevation: (item['elevation'] as num?)?.toDouble(),
          );
        }
        return const RoutePoint(latitude: 0, longitude: 0);
      }).toList();
    }
    return [];
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) return List<String>.from(data);
    return [];
  }

  static List<AidStation> _parseAidStations(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data
          .map((item) =>
              AidStation.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  String get difficultyLabel {
    final score = difficultyScore ?? 0;
    if (score < 3) return 'Facil';
    if (score < 5) return 'Moderado';
    if (score < 7) return 'Dificil';
    return 'Extremo';
  }

  @override
  List<Object?> get props => [
        id,
        raceId,
        totalDistance,
        elevationGain,
        elevationLoss,
        maxElevation,
        minElevation,
        difficultyScore,
        terrainTypes,
        createdAt,
      ];
}

class RoutePoint extends Equatable {
  final double latitude;
  final double longitude;
  final double? elevation;
  final double? cumulativeDistance;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.cumulativeDistance,
  });

  List<dynamic> toList() => [latitude, longitude, if (elevation != null) elevation];

  @override
  List<Object?> get props => [latitude, longitude, elevation, cumulativeDistance];
}

class AidStation extends Equatable {
  final double km;
  final String name;
  final List<String> services;
  final double? latitude;
  final double? longitude;

  const AidStation({
    required this.km,
    required this.name,
    this.services = const [],
    this.latitude,
    this.longitude,
  });

  factory AidStation.fromMap(Map<String, dynamic> map) {
    return AidStation(
      km: (map['km'] as num?)?.toDouble() ?? 0,
      name: map['name'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'km': km,
      'name': name,
      'services': services,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [km, name, services, latitude, longitude];
}
