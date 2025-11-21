/// Model for tracking dealer achievements and milestones
class Achievement {
  final int? id;
  final String key; // Unique identifier (e.g., 'first_shift', 'master_dealer')
  final String title;
  final String description;
  final String category; // 'shifts', 'tips', 'learning', 'social', 'mastery'
  final int targetValue; // Target to unlock (e.g., 10 shifts)
  final int currentValue; // Current progress
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward; // XP gained when unlocked
  final String iconName; // Icon identifier
  final DateTime createdAt;

  Achievement({
    this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.xpReward,
    required this.iconName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create Achievement from database map
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int?,
      key: map['key'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      targetValue: map['target_value'] as int,
      currentValue: map['current_value'] as int,
      isUnlocked: (map['is_unlocked'] as int) == 1,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
      xpReward: map['xp_reward'] as int,
      iconName: map['icon_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert Achievement to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'description': description,
      'category': category,
      'target_value': targetValue,
      'current_value': currentValue,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'xp_reward': xpReward,
      'icon_name': iconName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Achievement copyWith({
    int? id,
    String? key,
    String? title,
    String? description,
    String? category,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? xpReward,
    String? iconName,
    DateTime? createdAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      xpReward: xpReward ?? this.xpReward,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate progress percentage (0-100)
  int get progressPercentage {
    if (targetValue == 0) return 0;
    final percentage = (currentValue / targetValue * 100).round();
    return percentage > 100 ? 100 : percentage;
  }

  /// Check if achievement is in progress (not unlocked, but has progress)
  bool get isInProgress {
    return !isUnlocked && currentValue > 0;
  }

  /// Get category display name
  static String getCategoryName(String category) {
    switch (category) {
      case 'shifts':
        return 'Shift Milestones';
      case 'tips':
        return 'Earning Achievements';
      case 'learning':
        return 'Knowledge & Growth';
      case 'social':
        return 'Player Engagement';
      case 'mastery':
        return 'Master Dealer';
      default:
        return category;
    }
  }

  /// Get category emoji
  static String getCategoryEmoji(String category) {
    switch (category) {
      case 'shifts':
        return '📅';
      case 'tips':
        return '💰';
      case 'learning':
        return '📚';
      case 'social':
        return '🤝';
      case 'mastery':
        return '🏆';
      default:
        return '⭐';
    }
  }
}
