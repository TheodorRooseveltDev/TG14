import '../models/user_stats.dart';
import 'database_service.dart';

/// Repository for User Statistics operations
class UserStatsRepository {
  /// Get current user stats
  static Future<UserStats> getUserStats() async {
    final db = await DatabaseService.database;
    
    try {
      final maps = await db.query('user_stats', where: 'id = 1');
      
      if (maps.isEmpty) {
        // Return default stats if not found
        return UserStats();
      }
      
      return UserStats.fromMap(maps.first);
    } catch (e) {
      return UserStats();
    }
  }
  
  /// Update user stats
  static Future<void> updateUserStats(UserStats stats) async {
    final db = await DatabaseService.database;
    
    try {
      await db.update(
        'user_stats',
        stats.toMap(),
        where: 'id = 1',
      );
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }
  
  /// Award XP and update rank
  static Future<void> awardXP(int xp, {String? reason}) async {
    try {
      final stats = await getUserStats();
      final newTotalXP = stats.totalXP + xp;
      final newRank = UserStats.getRankForXP(newTotalXP);
      
      final updatedStats = stats.copyWith(
        totalXP: newTotalXP,
        currentRank: newRank,
      );
      
      await updateUserStats(updatedStats);
    } catch (e) {
      // Silent fail - don't break user flow
    }
  }
  
  /// Update last active timestamp
  static Future<void> updateLastActive() async {
    final db = await DatabaseService.database;
    
    try {
      await db.update(
        'user_stats',
        {'last_active': DateTime.now().toIso8601String()},
        where: 'id = 1',
      );
    } catch (e) {
      // Silent fail
    }
  }
}
