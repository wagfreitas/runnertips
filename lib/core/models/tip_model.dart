import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TipType {
  hotel,
  restaurant,
  transport,
  tourism,
  raceTip,
  general
}

enum TipCategory {
  accommodation,
  food,
  transportation,
  tourism,
  climate,
  elevation,
  organization,
  logistics,
  nutrition,
  general
}

class TipModel extends Equatable {
  final String id;
  final String userId;
  final String? raceId;
  final String? cityId;
  final TipType type;
  final TipCategory category;
  final String title;
  final String content;
  final List<String> images;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;
  final TipStats stats;

  const TipModel({
    required this.id,
    required this.userId,
    this.raceId,
    this.cityId,
    required this.type,
    required this.category,
    required this.title,
    required this.content,
    this.images = const [],
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
    required this.stats,
  });

  factory TipModel.fromMap(Map<String, dynamic> map) {
    return TipModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      raceId: map['raceId'],
      cityId: map['cityId'],
      type: TipType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TipType.general,
      ),
      category: TipCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TipCategory.general,
      ),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      metadata: map['metadata'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
      stats: TipStats.fromMap(map['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'raceId': raceId,
      'cityId': cityId,
      'type': type.name,
      'category': category.name,
      'title': title,
      'content': content,
      'images': images,
      'tags': tags,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'isVerified': isVerified,
      'stats': stats.toMap(),
    };
  }

  TipModel copyWith({
    String? id,
    String? userId,
    String? raceId,
    String? cityId,
    TipType? type,
    TipCategory? category,
    String? title,
    String? content,
    List<String>? images,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isVerified,
    TipStats? stats,
  }) {
    return TipModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      raceId: raceId ?? this.raceId,
      cityId: cityId ?? this.cityId,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        raceId,
        cityId,
        type,
        category,
        title,
        content,
        images,
        tags,
        metadata,
        createdAt,
        updatedAt,
        isActive,
        isVerified,
        stats,
      ];
}

class TipStats extends Equatable {
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final double helpfulness;
  final int views;

  const TipStats({
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.helpfulness = 0.0,
    this.views = 0,
  });

  factory TipStats.fromMap(Map<String, dynamic> map) {
    return TipStats(
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      shares: map['shares'] ?? 0,
      saves: map['saves'] ?? 0,
      helpfulness: (map['helpfulness'] ?? 0.0).toDouble(),
      views: map['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'helpfulness': helpfulness,
      'views': views,
    };
  }

  TipStats copyWith({
    int? likes,
    int? comments,
    int? shares,
    int? saves,
    double? helpfulness,
    int? views,
  }) {
    return TipStats(
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      saves: saves ?? this.saves,
      helpfulness: helpfulness ?? this.helpfulness,
      views: views ?? this.views,
    );
  }

  @override
  List<Object?> get props => [likes, comments, shares, saves, helpfulness, views];
}

