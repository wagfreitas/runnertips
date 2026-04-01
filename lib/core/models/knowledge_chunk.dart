import 'package:equatable/equatable.dart';

enum KnowledgeCategory {
  altimetry,
  route,
  problems,
  accommodation,
  food,
  tourism,
  safety,
  shopping,
  travelPackage,
  raceKit,
  training,
  general;

  String get label {
    switch (this) {
      case KnowledgeCategory.altimetry:
        return 'Altimetria';
      case KnowledgeCategory.route:
        return 'Percurso';
      case KnowledgeCategory.problems:
        return 'Problemas';
      case KnowledgeCategory.accommodation:
        return 'Hospedagem';
      case KnowledgeCategory.food:
        return 'Alimentacao';
      case KnowledgeCategory.tourism:
        return 'Turismo';
      case KnowledgeCategory.safety:
        return 'Seguranca';
      case KnowledgeCategory.shopping:
        return 'Compras';
      case KnowledgeCategory.travelPackage:
        return 'Pacotes de Viagem';
      case KnowledgeCategory.raceKit:
        return 'Kit da Prova';
      case KnowledgeCategory.training:
        return 'Treinamento';
      case KnowledgeCategory.general:
        return 'Geral';
    }
  }

  String get icon {
    switch (this) {
      case KnowledgeCategory.altimetry:
        return '⛰️';
      case KnowledgeCategory.route:
        return '🗺️';
      case KnowledgeCategory.problems:
        return '⚠️';
      case KnowledgeCategory.accommodation:
        return '🏨';
      case KnowledgeCategory.food:
        return '🍽️';
      case KnowledgeCategory.tourism:
        return '📸';
      case KnowledgeCategory.safety:
        return '🛡️';
      case KnowledgeCategory.shopping:
        return '🛍️';
      case KnowledgeCategory.travelPackage:
        return '✈️';
      case KnowledgeCategory.raceKit:
        return '🎽';
      case KnowledgeCategory.training:
        return '🏋️';
      case KnowledgeCategory.general:
        return '💡';
    }
  }

  String get dbValue {
    switch (this) {
      case KnowledgeCategory.travelPackage:
        return 'travel_package';
      case KnowledgeCategory.raceKit:
        return 'race_kit';
      default:
        return name;
    }
  }

  static KnowledgeCategory fromDbValue(String value) {
    switch (value) {
      case 'travel_package':
        return KnowledgeCategory.travelPackage;
      case 'race_kit':
        return KnowledgeCategory.raceKit;
      default:
        return KnowledgeCategory.values.firstWhere(
          (e) => e.name == value,
          orElse: () => KnowledgeCategory.general,
        );
    }
  }
}

enum SourceType {
  tip,
  raceInfo,
  curated,
  scraped;

  String get dbValue {
    switch (this) {
      case SourceType.raceInfo:
        return 'race_info';
      default:
        return name;
    }
  }

  static SourceType fromDbValue(String value) {
    switch (value) {
      case 'race_info':
        return SourceType.raceInfo;
      default:
        return SourceType.values.firstWhere(
          (e) => e.name == value,
          orElse: () => SourceType.curated,
        );
    }
  }
}

class KnowledgeChunk extends Equatable {
  final String id;
  final SourceType sourceType;
  final String sourceId;
  final String? raceId;
  final KnowledgeCategory category;
  final String? title;
  final String content;
  final Map<String, dynamic>? metadata;
  final String language;
  final bool isVerified;
  final double? similarity;
  final double? textRank;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeChunk({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    this.raceId,
    required this.category,
    this.title,
    required this.content,
    this.metadata,
    this.language = 'pt',
    this.isVerified = false,
    this.similarity,
    this.textRank,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeChunk.fromMap(Map<String, dynamic> map) {
    return KnowledgeChunk(
      id: map['id'] ?? '',
      sourceType: SourceType.fromDbValue(map['source_type'] ?? 'curated'),
      sourceId: map['source_id'] ?? '',
      raceId: map['race_id'],
      category:
          KnowledgeCategory.fromDbValue(map['category'] ?? 'general'),
      title: map['title'],
      content: map['content'] ?? '',
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      language: map['language'] ?? 'pt',
      isVerified: map['is_verified'] ?? false,
      similarity: (map['similarity'] as num?)?.toDouble(),
      textRank: (map['text_rank'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source_type': sourceType.dbValue,
      'source_id': sourceId,
      'race_id': raceId,
      'category': category.dbValue,
      'title': title,
      'content': content,
      'metadata': metadata,
      'language': language,
      'is_verified': isVerified,
    };
  }

  double get combinedScore {
    final sim = similarity ?? 0.0;
    final rank = textRank ?? 0.0;
    return (0.7 * sim) + (0.3 * rank);
  }

  @override
  List<Object?> get props => [
        id,
        sourceType,
        sourceId,
        raceId,
        category,
        title,
        content,
        metadata,
        language,
        isVerified,
        similarity,
        textRank,
        createdAt,
        updatedAt,
      ];
}
