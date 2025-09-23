class AppAssets {
  // Private constructor to prevent instantiation
  AppAssets._();

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _animationsPath = 'assets/animations';

  // Logos
  static const String logoApp = '$_imagesPath/logos/logo.svg';
  static const String logoAppWhite = '$_imagesPath/logos/logo_app_white.png';
  static const String logoAppDark = '$_imagesPath/logos/logo_app_dark.png';

  // Backgrounds
  static const String bgLogin = '$_imagesPath/backgrounds/bg_login.png';
  static const String bgOnboarding = '$_imagesPath/backgrounds/bg_onboarding.png';
  static const String bgPattern = '$_imagesPath/backgrounds/bg_pattern.png';

  // Illustrations
  static const String illustrationOnboarding1 = '$_imagesPath/illustrations/onboarding_1.png';
  static const String illustrationOnboarding2 = '$_imagesPath/illustrations/onboarding_2.png';
  static const String illustrationOnboarding3 = '$_imagesPath/illustrations/onboarding_3.png';
  static const String illustrationEmptyState = '$_imagesPath/illustrations/empty_state.png';
  static const String illustrationError = '$_imagesPath/illustrations/error.png';
  static const String illustrationSuccess = '$_imagesPath/illustrations/success.png';

  // Avatars
  static const String avatarDefault = '$_imagesPath/avatars/avatar_default.png';
  static const String avatarMale = '$_imagesPath/avatars/avatar_male.png';
  static const String avatarFemale = '$_imagesPath/avatars/avatar_female.png';

  // App Icons
  static const String icRunning = '$_iconsPath/app_icons/ic_running.png';
  static const String icCommunity = '$_iconsPath/app_icons/ic_community.png';
  static const String icTips = '$_iconsPath/app_icons/ic_tips.png';
  static const String icProfile = '$_iconsPath/app_icons/ic_profile.png';
  static const String icSettings = '$_iconsPath/app_icons/ic_settings.png';
  static const String icNotifications = '$_iconsPath/app_icons/ic_notifications.png';

  // Category Icons
  static const String icCategoryClimate = '$_iconsPath/category/ic_climate.png';
  static const String icCategoryElevation = '$_iconsPath/category/ic_elevation.png';
  static const String icCategoryOrganization = '$_iconsPath/category/ic_organization.png';
  static const String icCategoryLogistics = '$_iconsPath/category/ic_logistics.png';
  static const String icCategoryNutrition = '$_iconsPath/category/ic_nutrition.png';
  static const String icCategoryTiming = '$_iconsPath/category/ic_timing.png';
  static const String icCategoryAwards = '$_iconsPath/category/ic_awards.png';
  static const String icCategoryAccommodation = '$_iconsPath/category/ic_accommodation.png';
  static const String icCategoryTransportation = '$_iconsPath/category/ic_transportation.png';
  static const String icCategoryFood = '$_iconsPath/category/ic_food.png';
  static const String icCategoryTourism = '$_iconsPath/category/ic_tourism.png';
  static const String icCategoryShopping = '$_iconsPath/category/ic_shopping.png';
  static const String icCategoryGeneral = '$_iconsPath/category/ic_general.png';

  // Social Icons
  static const String icFacebook = '$_iconsPath/social/ic_facebook.png';
  static const String icInstagram = '$_iconsPath/social/ic_instagram.png';
  static const String icTwitter = '$_iconsPath/social/ic_twitter.png';
  static const String icWhatsapp = '$_iconsPath/social/ic_whatsapp.png';
  static const String icTelegram = '$_iconsPath/social/ic_telegram.png';
  static const String icShare = '$_iconsPath/social/ic_share.png';

  // Lottie Animations
  static const String lottieLoading = '$_animationsPath/lottie/loading.json';
  static const String lottieSuccess = '$_animationsPath/lottie/success.json';
  static const String lottieError = '$_animationsPath/lottie/error.json';
  static const String lottieEmpty = '$_animationsPath/lottie/empty.json';
  static const String lottieRunning = '$_animationsPath/lottie/running.json';
  static const String lottieWelcome = '$_animationsPath/lottie/welcome.json';

  // GIF Animations
  static const String gifLoading = '$_animationsPath/gif/loading.gif';
  static const String gifCelebration = '$_animationsPath/gif/celebration.gif';

  // Helper methods
  static List<String> getAllCategoryIcons() {
    return [
      icCategoryClimate,
      icCategoryElevation,
      icCategoryOrganization,
      icCategoryLogistics,
      icCategoryNutrition,
      icCategoryTiming,
      icCategoryAwards,
      icCategoryAccommodation,
      icCategoryTransportation,
      icCategoryFood,
      icCategoryTourism,
      icCategoryShopping,
      icCategoryGeneral,
    ];
  }

  static List<String> getAllSocialIcons() {
    return [
      icFacebook,
      icInstagram,
      icTwitter,
      icWhatsapp,
      icTelegram,
      icShare,
    ];
  }

  static List<String> getAllLottieAnimations() {
    return [
      lottieLoading,
      lottieSuccess,
      lottieError,
      lottieEmpty,
      lottieRunning,
      lottieWelcome,
    ];
  }
}
