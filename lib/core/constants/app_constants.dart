class AppConstants {
  // App Information
  static const String appName = 'Runner Tips';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Comunidade de dicas de corrida e viagem';
  
  // API Configuration
  static const String baseUrl = 'https://api.runner-tips.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImagesPerTip = 5;
  
  // Text Limits
  static const int maxTipTitleLength = 255;
  static const int maxTipContentLength = 2000;
  static const int maxCommentLength = 500;
  static const int maxBioLength = 500;
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB
  
  // Reputation System
  static const int pointsPerHelpfulTip = 10;
  static const int pointsPerVerifiedTip = 5;
  static const int pointsPerReview = 5;
  static const int pointsPerComment = 1;
  
  // Reputation Levels
  static const Map<String, int> reputationLevels = {
    'beginner': 0,
    'intermediate': 100,
    'expert': 500,
    'guru': 1000,
  };
  
  // Search Configuration
  static const int minSearchLength = 2;
  static const int maxSearchResults = 50;
  
  // Social Features
  static const int maxTagsPerTip = 10;
  static const int maxFollowersPerUser = 1000;
  
  // Privacy
  static const bool defaultLocationSharing = false;
  static const bool defaultPublicProfile = true;
  
  // Notifications
  static const Duration notificationDelay = Duration(seconds: 2);
  static const int maxNotificationsPerDay = 50;
}
