import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RaceModel extends Equatable {
  final String id;
  final String name;
  final String location;
  final String distance;
  final String month;
  final String year;
  final String imageUrl;
  final String description;
  final String status; // 'Open', 'Closed', 'Upcoming'
  final DateTime eventDate;
  final DateTime registrationDeadline;
  final double? price;
  final String? website;
  final String? organizer;
  final List<String> categories; // ['Marathon', 'Half Marathon', '10K', etc.]
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isExternal; // Se foi adicionada via agente externo

  // Campos de rota e mapa (v2)
  final String? gpxUrl;
  final double? elevationGain;
  final double? elevationLoss;
  final double? maxElevation;
  final double? minElevation;
  final double? difficultyScore;
  final List<String> terrainTypes;
  final String? type; // 'road', 'trail', 'ultra', 'mixed'

  // Campos RAG (v2)
  final int totalTips;
  final double? avgRating;

  const RaceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.month,
    required this.year,
    required this.imageUrl,
    required this.description,
    required this.status,
    required this.eventDate,
    required this.registrationDeadline,
    this.price,
    this.website,
    this.organizer,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
    this.isExternal = false,
    this.gpxUrl,
    this.elevationGain,
    this.elevationLoss,
    this.maxElevation,
    this.minElevation,
    this.difficultyScore,
    this.terrainTypes = const [],
    this.type,
    this.totalTips = 0,
    this.avgRating,
  });

  factory RaceModel.fromMap(Map<String, dynamic> map) {
    return RaceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      distance: map['distance'] ?? '',
      month: map['month'] ?? '',
      year: map['year'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Open',
      eventDate: (map['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registrationDeadline: (map['registrationDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: map['price']?.toDouble(),
      website: map['website'],
      organizer: map['organizer'],
      categories: List<String>.from(map['categories'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isExternal: map['isExternal'] ?? false,
      gpxUrl: map['gpxUrl'],
      elevationGain: map['elevationGain']?.toDouble(),
      elevationLoss: map['elevationLoss']?.toDouble(),
      maxElevation: map['maxElevation']?.toDouble(),
      minElevation: map['minElevation']?.toDouble(),
      difficultyScore: map['difficultyScore']?.toDouble(),
      terrainTypes: List<String>.from(map['terrainTypes'] ?? []),
      type: map['type'],
      totalTips: map['totalTips'] ?? 0,
      avgRating: map['avgRating']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'distance': distance,
      'month': month,
      'year': year,
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
      'eventDate': Timestamp.fromDate(eventDate),
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'price': price,
      'website': website,
      'organizer': organizer,
      'categories': categories,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isExternal': isExternal,
      'gpxUrl': gpxUrl,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'maxElevation': maxElevation,
      'minElevation': minElevation,
      'difficultyScore': difficultyScore,
      'terrainTypes': terrainTypes,
      'type': type,
      'totalTips': totalTips,
      'avgRating': avgRating,
    };
  }

  RaceModel copyWith({
    String? id,
    String? name,
    String? location,
    String? distance,
    String? month,
    String? year,
    String? imageUrl,
    String? description,
    String? status,
    DateTime? eventDate,
    DateTime? registrationDeadline,
    double? price,
    String? website,
    String? organizer,
    List<String>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExternal,
    String? gpxUrl,
    double? elevationGain,
    double? elevationLoss,
    double? maxElevation,
    double? minElevation,
    double? difficultyScore,
    List<String>? terrainTypes,
    String? type,
    int? totalTips,
    double? avgRating,
  }) {
    return RaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      month: month ?? this.month,
      year: year ?? this.year,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      status: status ?? this.status,
      eventDate: eventDate ?? this.eventDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      price: price ?? this.price,
      website: website ?? this.website,
      organizer: organizer ?? this.organizer,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExternal: isExternal ?? this.isExternal,
      gpxUrl: gpxUrl ?? this.gpxUrl,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      maxElevation: maxElevation ?? this.maxElevation,
      minElevation: minElevation ?? this.minElevation,
      difficultyScore: difficultyScore ?? this.difficultyScore,
      terrainTypes: terrainTypes ?? this.terrainTypes,
      type: type ?? this.type,
      totalTips: totalTips ?? this.totalTips,
      avgRating: avgRating ?? this.avgRating,
    );
  }

  /// Verifica se a corrida está aberta para inscrições
  bool get isRegistrationOpen {
    final now = DateTime.now();
    return status == 'Open' && now.isBefore(registrationDeadline);
  }

  /// Retorna a data formatada para exibição
  String get formattedDate {
    return '${month} ${eventDate.day}, ${year}';
  }

  /// Retorna o status formatado em português
  String get statusInPortuguese {
    switch (status) {
      case 'Open':
        return 'Inscrições Abertas';
      case 'Closed':
        return 'Inscrições Encerradas';
      case 'Upcoming':
        return 'Em Breve';
      default:
        return status;
    }
  }

  /// Verifica se a corrida tem dados de rota/mapa
  bool get hasRouteData => gpxUrl != null || elevationGain != null;

  /// Retorna label de dificuldade
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
        name,
        location,
        distance,
        month,
        year,
        imageUrl,
        description,
        status,
        eventDate,
        registrationDeadline,
        price,
        website,
        organizer,
        categories,
        createdAt,
        updatedAt,
        isExternal,
        gpxUrl,
        elevationGain,
        elevationLoss,
        maxElevation,
        minElevation,
        difficultyScore,
        terrainTypes,
        type,
        totalTips,
        avgRating,
      ];
}

/// Modelo para sugestões de corridas vindas do agente externo
class RaceSuggestion extends Equatable {
  final String name;
  final String location;
  final String distance;
  final String month;
  final String year;
  final String imageUrl;
  final String description;
  final String? website;
  final String? organizer;
  final double confidence; // Confiança da sugestão (0.0 - 1.0)

  const RaceSuggestion({
    required this.name,
    required this.location,
    required this.distance,
    required this.month,
    required this.year,
    required this.imageUrl,
    required this.description,
    this.website,
    this.organizer,
    required this.confidence,
  });

  factory RaceSuggestion.fromMap(Map<String, dynamic> map) {
    return RaceSuggestion(
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      distance: map['distance'] ?? '',
      month: map['month'] ?? '',
      year: map['year'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      website: map['website'],
      organizer: map['organizer'],
      confidence: (map['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'distance': distance,
      'month': month,
      'year': year,
      'imageUrl': imageUrl,
      'description': description,
      'website': website,
      'organizer': organizer,
      'confidence': confidence,
    };
  }

  @override
  List<Object?> get props => [
        name,
        location,
        distance,
        month,
        year,
        imageUrl,
        description,
        website,
        organizer,
        confidence,
      ];
}
