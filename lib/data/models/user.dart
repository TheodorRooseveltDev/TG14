/// User model representing the player
class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final int coinBalance;
  final int level;
  final int experience;
  final int totalWinnings;
  final int gamesPlayed;
  final int currentStreak;
  final DateTime? lastLogin;
  final bool hasCompletedOnboarding;
  final bool notificationsEnabled;
  final bool soundEnabled;

  const User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.coinBalance = 1000000,
    this.level = 1,
    this.experience = 0,
    this.totalWinnings = 0,
    this.gamesPlayed = 0,
    this.currentStreak = 0,
    this.lastLogin,
    this.hasCompletedOnboarding = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });

  /// Create a default guest user
  factory User.guest() {
    return User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest Player',
      coinBalance: 1000000,
    );
  }

  /// Get user initials for avatar placeholder
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'G';
  }

  /// Calculate progress to next level (0.0 to 1.0)
  double get levelProgress {
    const xpPerLevel = 1000;
    return (experience % xpPerLevel) / xpPerLevel;
  }

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? coinBalance,
    int? level,
    int? experience,
    int? totalWinnings,
    int? gamesPlayed,
    int? currentStreak,
    DateTime? lastLogin,
    bool? hasCompletedOnboarding,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coinBalance: coinBalance ?? this.coinBalance,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      totalWinnings: totalWinnings ?? this.totalWinnings,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLogin: lastLogin ?? this.lastLogin,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
