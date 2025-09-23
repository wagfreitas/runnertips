class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.runner-tips.com/v1';
  static const String firebaseUrl = 'https://runner-tips-default-rtdb.firebaseio.com';
  
  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  
  // User Management
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String uploadAvatar = '/users/avatar';
  static const String userStats = '/users/stats';
  static const String userReputation = '/users/reputation';
  
  // Tips
  static const String tips = '/tips';
  static const String tipById = '/tips/{id}';
  static const String tipsByRace = '/tips/race/{raceId}';
  static const String tipsByCity = '/tips/city/{cityId}';
  static const String tipsByUser = '/tips/user/{userId}';
  static const String tipsByCategory = '/tips/category/{category}';
  static const String searchTips = '/tips/search';
  static const String trendingTips = '/tips/trending';
  static const String recentTips = '/tips/recent';
  
  // Races
  static const String races = '/races';
  static const String raceById = '/races/{id}';
  static const String searchRaces = '/races/search';
  static const String racesByLocation = '/races/location';
  static const String racesByDate = '/races/date';
  static const String upcomingRaces = '/races/upcoming';
  static const String raceStats = '/races/{id}/stats';
  
  // Cities
  static const String cities = '/cities';
  static const String cityById = '/cities/{id}';
  static const String searchCities = '/cities/search';
  static const String citiesByCountry = '/cities/country/{country}';
  static const String cityStats = '/cities/{id}/stats';
  
  // Reviews
  static const String reviews = '/reviews';
  static const String reviewById = '/reviews/{id}';
  static const String reviewsByRace = '/reviews/race/{raceId}';
  static const String reviewsByUser = '/reviews/user/{userId}';
  static const String reviewStats = '/reviews/{id}/stats';
  
  // Comments
  static const String comments = '/comments';
  static const String commentById = '/comments/{id}';
  static const String commentsByTip = '/comments/tip/{tipId}';
  static const String commentsByUser = '/comments/user/{userId}';
  
  // Interactions
  static const String interactions = '/interactions';
  static const String like = '/interactions/like';
  static const String helpful = '/interactions/helpful';
  static const String save = '/interactions/save';
  static const String share = '/interactions/share';
  static const String report = '/interactions/report';
  
  // Search
  static const String search = '/search';
  static const String searchSuggestions = '/search/suggestions';
  static const String searchHistory = '/search/history';
  
  // Community
  static const String feed = '/community/feed';
  static const String trending = '/community/trending';
  static const String following = '/community/following';
  static const String followers = '/community/followers';
  static const String follow = '/community/follow';
  static const String unfollow = '/community/unfollow';
  
  // Analytics
  static const String analytics = '/analytics';
  static const String trackEvent = '/analytics/event';
  static const String userMetrics = '/analytics/user';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/read';
  static const String notificationSettings = '/notifications/settings';
  
  // File Upload
  static const String uploadImage = '/upload/image';
  static const String uploadMultiple = '/upload/multiple';
  
  // Health Check
  static const String health = '/health';
  static const String version = '/version';
}
