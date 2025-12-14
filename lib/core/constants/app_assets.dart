/// Asset paths for images and icons
class AppAssets {
  AppAssets._();

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _assetsPath = 'assets';

  // Images
  static const String mainBackground = '$_assetsPath/main-bg-min.jpg';
  static const String dealerAvatar = '$_assetsPath/dealer-avatar.png';
  static const String appIcon = '$_assetsPath/icon.png';

  // Placeholder for game images (will be replaced with actual game assets)
  static const String gamePlaceholder = '$_imagesPath/game_placeholder.png';
  
  // Card suits for decorative elements
  static const String spade = '$_iconsPath/spade.svg';
  static const String heart = '$_iconsPath/heart.svg';
  static const String diamond = '$_iconsPath/diamond.svg';
  static const String club = '$_iconsPath/club.svg';
}
