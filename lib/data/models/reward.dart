/// Reward type enum
enum RewardType {
  dailyBonus,
  streakBonus,
  wheelSpin,
  achievement,
  levelUp,
  special;

  String get displayName {
    switch (this) {
      case RewardType.dailyBonus:
        return 'Daily Bonus';
      case RewardType.streakBonus:
        return 'Streak Bonus';
      case RewardType.wheelSpin:
        return 'Lucky Wheel';
      case RewardType.achievement:
        return 'Achievement';
      case RewardType.levelUp:
        return 'Level Up';
      case RewardType.special:
        return 'Special Reward';
    }
  }
}

/// Reward model
class Reward {
  final String id;
  final RewardType type;
  final int coinAmount;
  final String? description;
  final bool isClaimed;
  final DateTime? claimedAt;
  final DateTime? expiresAt;

  const Reward({
    required this.id,
    required this.type,
    required this.coinAmount,
    this.description,
    this.isClaimed = false,
    this.claimedAt,
    this.expiresAt,
  });

  /// Check if reward is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if reward is available to claim
  bool get isAvailable => !isClaimed && !isExpired;

  /// Create a copy with modified fields
  Reward copyWith({
    String? id,
    RewardType? type,
    int? coinAmount,
    String? description,
    bool? isClaimed,
    DateTime? claimedAt,
    DateTime? expiresAt,
  }) {
    return Reward(
      id: id ?? this.id,
      type: type ?? this.type,
      coinAmount: coinAmount ?? this.coinAmount,
      description: description ?? this.description,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Daily reward for 7-day calendar
class DailyReward {
  final int day;
  final int coinAmount;
  final bool isClaimed;
  final bool isToday;
  final bool isMega; // Day 7 is mega reward

  const DailyReward({
    required this.day,
    required this.coinAmount,
    this.isClaimed = false,
    this.isToday = false,
    this.isMega = false,
  });

  /// Create standard daily rewards for 7 days
  static List<DailyReward> createWeek({int currentDay = 1, int claimedDays = 0}) {
    final rewards = <DailyReward>[];
    final amounts = [1000, 2500, 5000, 7500, 10000, 15000, 50000];
    
    for (int i = 1; i <= 7; i++) {
      rewards.add(DailyReward(
        day: i,
        coinAmount: amounts[i - 1],
        isClaimed: i <= claimedDays,
        isToday: i == currentDay,
        isMega: i == 7,
      ));
    }
    
    return rewards;
  }
}
