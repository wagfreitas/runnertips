import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime lastActive;
  final UserLocation? location;
  final List<String> specializations;
  final bool isVerified;
  final bool isActive;
  final UserPreferences preferences;
  final UserStats stats;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.lastActive,
    this.location,
    this.specializations = const [],
    this.isVerified = false,
    this.isActive = true,
    required this.preferences,
    required this.stats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActive: DateTime.parse(json['last_active'] as String),
      location: json['location'] != null 
          ? UserLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      specializations: List<String>.from(json['specializations'] ?? []),
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'last_active': lastActive.toIso8601String(),
      'location': location?.toJson(),
      'specializations': specializations,
      'is_verified': isVerified,
      'is_active': isActive,
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? lastActive,
    UserLocation? location,
    List<String>? specializations,
    bool? isVerified,
    bool? isActive,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      location: location ?? this.location,
      specializations: specializations ?? this.specializations,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        profileImageUrl,
        bio,
        createdAt,
        lastActive,
        location,
        specializations,
        isVerified,
        isActive,
        preferences,
        stats,
      ];
}

class UserLocation extends Equatable {
  final String city;
  final String? state;
  final String country;
  final double? latitude;
  final double? longitude;

  const UserLocation({
    required this.city,
    this.state,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      city: json['city'] as String,
      state: json['state'] as String?,
      country: json['country'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  UserLocation copyWith({
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
  }) {
    return UserLocation(
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [city, state, country, latitude, longitude];
}

class UserPreferences extends Equatable {
  final bool notificationsEnabled;
  final bool locationSharingEnabled;
  final String preferredUnits;
  final List<String> interests;
  final Map<String, bool> privacySettings;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.locationSharingEnabled = false,
    this.preferredUnits = 'metric',
    this.interests = const [],
    this.privacySettings = const {},
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      locationSharingEnabled: json['location_sharing_enabled'] as bool? ?? false,
      preferredUnits: json['preferred_units'] as String? ?? 'metric',
      interests: List<String>.from(json['interests'] ?? []),
      privacySettings: Map<String, bool>.from(json['privacy_settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'location_sharing_enabled': locationSharingEnabled,
      'preferred_units': preferredUnits,
      'interests': interests,
      'privacy_settings': privacySettings,
    };
  }

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? locationSharingEnabled,
    String? preferredUnits,
    List<String>? interests,
    Map<String, bool>? privacySettings,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      preferredUnits: preferredUnits ?? this.preferredUnits,
      interests: interests ?? this.interests,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        locationSharingEnabled,
        preferredUnits,
        interests,
        privacySettings,
      ];
}

class UserStats extends Equatable {
  final int totalTips;
  final int helpfulTips;
  final int racesParticipated;
  final int countriesVisited;
  final double averageRating;
  final int reputationPoints;
  final String level;

  const UserStats({
    this.totalTips = 0,
    this.helpfulTips = 0,
    this.racesParticipated = 0,
    this.countriesVisited = 0,
    this.averageRating = 0.0,
    this.reputationPoints = 0,
    this.level = 'beginner',
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalTips: json['total_tips'] as int? ?? 0,
      helpfulTips: json['helpful_tips'] as int? ?? 0,
      racesParticipated: json['races_participated'] as int? ?? 0,
      countriesVisited: json['countries_visited'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reputationPoints: json['reputation_points'] as int? ?? 0,
      level: json['level'] as String? ?? 'beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tips': totalTips,
      'helpful_tips': helpfulTips,
      'races_participated': racesParticipated,
      'countries_visited': countriesVisited,
      'average_rating': averageRating,
      'reputation_points': reputationPoints,
      'level': level,
    };
  }

  UserStats copyWith({
    int? totalTips,
    int? helpfulTips,
    int? racesParticipated,
    int? countriesVisited,
    double? averageRating,
    int? reputationPoints,
    String? level,
  }) {
    return UserStats(
      totalTips: totalTips ?? this.totalTips,
      helpfulTips: helpfulTips ?? this.helpfulTips,
      racesParticipated: racesParticipated ?? this.racesParticipated,
      countriesVisited: countriesVisited ?? this.countriesVisited,
      averageRating: averageRating ?? this.averageRating,
      reputationPoints: reputationPoints ?? this.reputationPoints,
      level: level ?? this.level,
    );
  }

  @override
  List<Object?> get props => [
        totalTips,
        helpfulTips,
        racesParticipated,
        countriesVisited,
        averageRating,
        reputationPoints,
        level,
      ];
}
