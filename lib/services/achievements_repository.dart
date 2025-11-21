import '../services/database_service.dart';
import '../models/achievement.dart';
import 'package:sqflite/sqflite.dart';

/// Repository for managing achievements
class AchievementsRepository {
  /// Get all achievements
  static Future<List<Achievement>> getAllAchievements() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      orderBy: 'category ASC, target_value ASC',
    );

    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  /// Get achievements by category
  static Future<List<Achievement>> getAchievementsByCategory(String category) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'target_value ASC',
    );

    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  /// Get unlocked achievements
  static Future<List<Achievement>> getUnlockedAchievements() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'is_unlocked = ?',
      whereArgs: [1],
      orderBy: 'unlocked_at DESC',
    );

    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  /// Get achievement by key
  static Future<Achievement?> getAchievementByKey(String key) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Achievement.fromMap(maps.first);
  }

  /// Update achievement progress
  static Future<void> updateProgress(String key, int newValue) async {
    final db = await DatabaseService.database;
    
    // Get current achievement
    final achievement = await getAchievementByKey(key);
    if (achievement == null) return;
    
    // Check if this update unlocks the achievement
    final isNowUnlocked = !achievement.isUnlocked && newValue >= achievement.targetValue;
    
    await db.update(
      'achievements',
      {
        'current_value': newValue,
        'is_unlocked': isNowUnlocked ? 1 : achievement.isUnlocked ? 1 : 0,
        'unlocked_at': isNowUnlocked ? DateTime.now().toIso8601String() : achievement.unlockedAt?.toIso8601String(),
      },
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// Get achievement stats
  static Future<Map<String, dynamic>> getAchievementStats() async {
    final db = await DatabaseService.database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM achievements',
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    
    final unlockedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM achievements WHERE is_unlocked = 1',
    );
    final unlocked = Sqflite.firstIntValue(unlockedResult) ?? 0;
    
    final totalXPResult = await db.rawQuery(
      'SELECT SUM(xp_reward) as total FROM achievements WHERE is_unlocked = 1',
    );
    final totalXP = Sqflite.firstIntValue(totalXPResult) ?? 0;
    
    return {
      'total': total,
      'unlocked': unlocked,
      'locked': total - unlocked,
      'percentage': total > 0 ? (unlocked / total * 100).round() : 0,
      'totalXP': totalXP,
    };
  }

  /// Initialize default achievements
  static Future<void> initializeDefaultAchievements() async {
    final db = await DatabaseService.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM achievements'),
    );

    if (count == null || count == 0) {
      final defaultAchievements = _getDefaultAchievements();
      final batch = db.batch();
      
      for (final achievement in defaultAchievements) {
        batch.insert('achievements', achievement.toMap());
      }
      
      await batch.commit(noResult: true);
    }
  }

  /// Get default achievements (24 total)
  static List<Achievement> _getDefaultAchievements() {
    return [
      // ========== SHIFTS CATEGORY (6 achievements) ==========
      Achievement(
        key: 'first_shift',
        title: 'First Day on the Floor',
        description: 'Complete your very first shift',
        category: 'shifts',
        targetValue: 1,
        xpReward: 50,
        iconName: 'emoji_events',
      ),
      Achievement(
        key: 'shift_week',
        title: 'Week Warrior',
        description: 'Complete 7 shifts',
        category: 'shifts',
        targetValue: 7,
        xpReward: 100,
        iconName: 'calendar_view_week',
      ),
      Achievement(
        key: 'shift_month',
        title: 'Monthly Regular',
        description: 'Complete 30 shifts',
        category: 'shifts',
        targetValue: 30,
        xpReward: 250,
        iconName: 'calendar_month',
      ),
      Achievement(
        key: 'shift_veteran',
        title: 'Veteran Dealer',
        description: 'Complete 100 shifts',
        category: 'shifts',
        targetValue: 100,
        xpReward: 500,
        iconName: 'military_tech',
      ),
      Achievement(
        key: 'shift_master',
        title: 'Shift Master',
        description: 'Complete 500 shifts',
        category: 'shifts',
        targetValue: 500,
        xpReward: 1000,
        iconName: 'workspace_premium',
      ),
      Achievement(
        key: 'shift_legend',
        title: 'Floor Legend',
        description: 'Complete 1000 shifts',
        category: 'shifts',
        targetValue: 1000,
        xpReward: 2500,
        iconName: 'star',
      ),

      // ========== TIPS CATEGORY (5 achievements) ==========
      Achievement(
        key: 'first_tip',
        title: 'First Toke',
        description: 'Record your first tip earning',
        category: 'tips',
        targetValue: 1,
        xpReward: 25,
        iconName: 'attach_money',
      ),
      Achievement(
        key: 'tip_hundred',
        title: 'Century Club',
        description: 'Earn \$100+ in tips in a single shift',
        category: 'tips',
        targetValue: 100,
        xpReward: 100,
        iconName: 'payments',
      ),
      Achievement(
        key: 'tip_thousand',
        title: 'Grand Club',
        description: 'Earn \$1,000+ total in tips',
        category: 'tips',
        targetValue: 1000,
        xpReward: 300,
        iconName: 'account_balance_wallet',
      ),
      Achievement(
        key: 'tip_streak',
        title: 'Hot Streak',
        description: 'Earn tips in 5 consecutive shifts',
        category: 'tips',
        targetValue: 5,
        xpReward: 150,
        iconName: 'local_fire_department',
      ),
      Achievement(
        key: 'tip_generous',
        title: 'Player Favorite',
        description: 'Earn \$500+ in tips in a single shift',
        category: 'tips',
        targetValue: 500,
        xpReward: 500,
        iconName: 'favorite',
      ),

      // ========== LEARNING CATEGORY (6 achievements) ==========
      Achievement(
        key: 'first_note',
        title: 'Note Taker',
        description: 'Create your first table note',
        category: 'learning',
        targetValue: 1,
        xpReward: 25,
        iconName: 'note_add',
      ),
      Achievement(
        key: 'game_rules_reader',
        title: 'Rule Book Scholar',
        description: 'Read all 8 game rule guides',
        category: 'learning',
        targetValue: 8,
        xpReward: 200,
        iconName: 'menu_book',
      ),
      Achievement(
        key: 'scenario_novice',
        title: 'Scenario Student',
        description: 'Review 5 practice scenarios',
        category: 'learning',
        targetValue: 5,
        xpReward: 100,
        iconName: 'school',
      ),
      Achievement(
        key: 'scenario_expert',
        title: 'Scenario Expert',
        description: 'Review all 12 practice scenarios',
        category: 'learning',
        targetValue: 12,
        xpReward: 250,
        iconName: 'psychology',
      ),
      Achievement(
        key: 'routine_master',
        title: 'Routine Master',
        description: 'Complete all daily routine checklists in one day',
        category: 'learning',
        targetValue: 25,
        xpReward: 150,
        iconName: 'checklist',
      ),
      Achievement(
        key: 'organized_dealer',
        title: 'Organized Dealer',
        description: 'Create 50 table notes',
        category: 'learning',
        targetValue: 50,
        xpReward: 300,
        iconName: 'folder_special',
      ),

      // ========== SOCIAL CATEGORY (4 achievements) ==========
      Achievement(
        key: 'player_interaction',
        title: 'People Person',
        description: 'Log 10 positive player interactions in notes',
        category: 'social',
        targetValue: 10,
        xpReward: 100,
        iconName: 'groups',
      ),
      Achievement(
        key: 'big_winner',
        title: 'Big Winner Handler',
        description: 'Note 5 big winner payouts (\$500+)',
        category: 'social',
        targetValue: 5,
        xpReward: 150,
        iconName: 'celebration',
      ),
      Achievement(
        key: 'problem_solver',
        title: 'Problem Solver',
        description: 'Successfully handle 10 player disputes',
        category: 'social',
        targetValue: 10,
        xpReward: 200,
        iconName: 'handshake',
      ),
      Achievement(
        key: 'regular_host',
        title: 'Regular\'s Choice',
        description: 'Note 20 interactions with regular players',
        category: 'social',
        targetValue: 20,
        xpReward: 250,
        iconName: 'person_pin',
      ),

      // ========== MASTERY CATEGORY (3 achievements) ==========
      Achievement(
        key: 'all_games',
        title: 'Multi-Game Dealer',
        description: 'Deal 5 different casino games',
        category: 'mastery',
        targetValue: 5,
        xpReward: 300,
        iconName: 'casino',
      ),
      Achievement(
        key: 'perfect_week',
        title: 'Perfect Week',
        description: 'Complete all routines every day for 7 days',
        category: 'mastery',
        targetValue: 7,
        xpReward: 500,
        iconName: 'grade',
      ),
      Achievement(
        key: 'ultimate_dealer',
        title: 'Ultimate Dealer',
        description: 'Unlock all other achievements',
        category: 'mastery',
        targetValue: 23, // Total of all other achievements
        xpReward: 5000,
        iconName: 'emoji_events',
      ),
    ];
  }
}
