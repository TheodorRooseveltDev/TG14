/// User Statistics Model
class UserStats {
  final int id;
  final int totalXP;
  final String currentRank;
  final int shiftsLogged;
  final int notesCreated;
  final int scenariosAnalyzed;
  final int routinesCompleted;
  final int longestStreak;
  final int currentStreak;
  final double totalHoursWorked;
  final String? favoriteGame;
  final DateTime lastActive;
  
  UserStats({
    this.id = 1,
    this.totalXP = 0,
    this.currentRank = 'Rookie Dealer',
    this.shiftsLogged = 0,
    this.notesCreated = 0,
    this.scenariosAnalyzed = 0,
    this.routinesCompleted = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.totalHoursWorked = 0.0,
    this.favoriteGame,
    DateTime? lastActive,
  }) : lastActive = lastActive ?? DateTime.now();
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_xp': totalXP,
      'current_rank': currentRank,
      'shifts_logged': shiftsLogged,
      'notes_created': notesCreated,
      'scenarios_analyzed': scenariosAnalyzed,
      'routines_completed': routinesCompleted,
      'longest_streak': longestStreak,
      'current_streak': currentStreak,
      'total_hours_worked': totalHoursWorked,
      'favorite_game': favoriteGame,
      'last_active': lastActive.toIso8601String(),
    };
  }
  
  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      id: map['id'] as int,
      totalXP: map['total_xp'] as int,
      currentRank: map['current_rank'] as String,
      shiftsLogged: map['shifts_logged'] as int,
      notesCreated: map['notes_created'] as int,
      scenariosAnalyzed: map['scenarios_analyzed'] as int,
      routinesCompleted: map['routines_completed'] as int,
      longestStreak: map['longest_streak'] as int,
      currentStreak: map['current_streak'] as int,
      totalHoursWorked: map['total_hours_worked'] as double,
      favoriteGame: map['favorite_game'] as String?,
      lastActive: DateTime.parse(map['last_active'] as String),
    );
  }
  
  UserStats copyWith({
    int? totalXP,
    String? currentRank,
    int? shiftsLogged,
    int? notesCreated,
    int? scenariosAnalyzed,
    int? routinesCompleted,
    int? longestStreak,
    int? currentStreak,
    double? totalHoursWorked,
    String? favoriteGame,
  }) {
    return UserStats(
      id: id,
      totalXP: totalXP ?? this.totalXP,
      currentRank: currentRank ?? this.currentRank,
      shiftsLogged: shiftsLogged ?? this.shiftsLogged,
      notesCreated: notesCreated ?? this.notesCreated,
      scenariosAnalyzed: scenariosAnalyzed ?? this.scenariosAnalyzed,
      routinesCompleted: routinesCompleted ?? this.routinesCompleted,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalHoursWorked: totalHoursWorked ?? this.totalHoursWorked,
      favoriteGame: favoriteGame ?? this.favoriteGame,
      lastActive: DateTime.now(),
    );
  }
  
  // XP System - Rank thresholds
  static const Map<String, int> rankThresholds = {
    'Rookie Dealer': 0,
    'Table Operator': 500,
    'Pit Ready': 1500,
    'Flow Specialist': 3000,
    'Elite Dealer': 5000,
    'Master Dealer': 10000,
  };
  
  // Calculate current rank based on XP
  static String getRankForXP(int xp) {
    String rank = 'Rookie Dealer';
    for (final entry in rankThresholds.entries) {
      if (xp >= entry.value) {
        rank = entry.key;
      }
    }
    return rank;
  }
  
  // Calculate progress to next rank (0.0 to 1.0)
  double get progressToNextRank {
    final ranks = rankThresholds.keys.toList();
    final currentIndex = ranks.indexOf(currentRank);
    
    if (currentIndex == -1 || currentIndex >= ranks.length - 1) {
      return 1.0; // Max rank
    }
    
    final currentThreshold = rankThresholds[currentRank]!;
    final nextThreshold = rankThresholds[ranks[currentIndex + 1]]!;
    
    final progress = (totalXP - currentThreshold) / (nextThreshold - currentThreshold);
    return progress.clamp(0.0, 1.0);
  }
  
  String? get nextRank {
    final ranks = rankThresholds.keys.toList();
    final currentIndex = ranks.indexOf(currentRank);
    
    if (currentIndex == -1 || currentIndex >= ranks.length - 1) {
      return null;
    }
    
    return ranks[currentIndex + 1];
  }
  
  int? get xpToNextRank {
    final next = nextRank;
    if (next == null) return null;
    
    return rankThresholds[next]! - totalXP;
  }
}
