import '../models/shift.dart';
import 'database_service.dart';

/// Repository for Shift CRUD operations
class ShiftRepository {
  /// Add a new shift to the database
  static Future<int> addShift(Shift shift) async {
    final db = await DatabaseService.database;
    
    try {
      final id = await db.insert('shifts', shift.toMap());
      
      // Award XP for logging shift
      await _awardXP(50, 'shift_logged');
      
      // Update stats
      await _updateStats();
      
      return id;
    } catch (e) {
      throw Exception('Failed to add shift: $e');
    }
  }
  
  /// Get all shifts
  static Future<List<Shift>> getAllShifts({
    int? limit,
    int? offset,
  }) async {
    final db = await DatabaseService.database;
    
    try {
      final maps = await db.query(
        'shifts',
        orderBy: 'date DESC, created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      return maps.map((map) => Shift.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get shifts: $e');
    }
  }
  
  /// Get shifts by date range
  static Future<List<Shift>> getShiftsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DatabaseService.database;
    
    try {
      final maps = await db.query(
        'shifts',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'date DESC',
      );
      
      return maps.map((map) => Shift.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get shifts by date range: $e');
    }
  }
  
  /// Get shift by ID
  static Future<Shift?> getShiftById(int id) async {
    final db = await DatabaseService.database;
    
    try {
      final maps = await db.query(
        'shifts',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) return null;
      return Shift.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get shift: $e');
    }
  }
  
  /// Update shift
  static Future<void> updateShift(Shift shift) async {
    final db = await DatabaseService.database;
    
    try {
      await db.update(
        'shifts',
        shift.toMap(),
        where: 'id = ?',
        whereArgs: [shift.id],
      );
    } catch (e) {
      throw Exception('Failed to update shift: $e');
    }
  }
  
  /// Delete shift
  static Future<void> deleteShift(int id) async {
    final db = await DatabaseService.database;
    
    try {
      await db.delete(
        'shifts',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Update stats
      await _updateStats();
    } catch (e) {
      throw Exception('Failed to delete shift: $e');
    }
  }
  
  /// Get total shifts count
  static Future<int> getTotalShiftsCount() async {
    final db = await DatabaseService.database;
    
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM shifts');
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }
  
  /// Get total hours worked
  static Future<double> getTotalHoursWorked() async {
    try {
      final shifts = await getAllShifts();
      double totalHours = 0;
      
      for (final shift in shifts) {
        if (shift.startTime != null && shift.endTime != null) {
          // Parse time strings and calculate duration
          final start = _parseTimeOfDay(shift.startTime!);
          final end = _parseTimeOfDay(shift.endTime!);
          
          if (start != null && end != null) {
            double hours = end['hour']! - start['hour']! + (end['minute']! - start['minute']!) / 60;
            if (hours < 0) hours += 24; // Handle overnight shifts
            totalHours += hours;
          }
        }
      }
      
      return totalHours;
    } catch (e) {
      return 0;
    }
  }
  
  /// Get current streak (consecutive days with shifts)
  static Future<int> getCurrentStreak() async {
    try {
      final shifts = await getAllShifts();
      if (shifts.isEmpty) return 0;
      
      int streak = 1;
      DateTime lastDate = shifts.first.date;
      
      for (int i = 1; i < shifts.length; i++) {
        final daysDiff = lastDate.difference(shifts[i].date).inDays;
        
        if (daysDiff == 1) {
          streak++;
          lastDate = shifts[i].date;
        } else if (daysDiff > 1) {
          break;
        }
      }
      
      return streak;
    } catch (e) {
      return 0;
    }
  }
  
  /// Award XP for action
  static Future<void> _awardXP(int xp, String reason) async {
    final db = await DatabaseService.database;
    
    try {
      // Get current stats
      final statsResult = await db.query('user_stats', where: 'id = 1');
      if (statsResult.isEmpty) return;
      
      final currentXP = statsResult.first['total_xp'] as int;
      final newXP = currentXP + xp;
      
      // Calculate new rank
      final newRank = _calculateRank(newXP);
      
      // Update stats
      await db.update(
        'user_stats',
        {
          'total_xp': newXP,
          'current_rank': newRank,
          'last_active': DateTime.now().toIso8601String(),
        },
        where: 'id = 1',
      );
    } catch (e) {
      // Silent fail - don't break the flow
    }
  }
  
  /// Calculate rank based on XP
  static String _calculateRank(int xp) {
    if (xp >= 10000) return 'Master Dealer';
    if (xp >= 5000) return 'Elite Dealer';
    if (xp >= 3000) return 'Flow Specialist';
    if (xp >= 1500) return 'Pit Ready';
    if (xp >= 500) return 'Table Operator';
    return 'Rookie Dealer';
  }
  
  /// Update user statistics
  static Future<void> _updateStats() async {
    final db = await DatabaseService.database;
    
    try {
      final shiftsCount = await getTotalShiftsCount();
      final hoursWorked = await getTotalHoursWorked();
      final currentStreak = await getCurrentStreak();
      
      await db.update(
        'user_stats',
        {
          'shifts_logged': shiftsCount,
          'total_hours_worked': hoursWorked,
          'current_streak': currentStreak,
          'last_active': DateTime.now().toIso8601String(),
        },
        where: 'id = 1',
      );
    } catch (e) {
      // Silent fail
    }
  }
  
  /// Parse time string to TimeOfDay-like values
  static Map<String, int>? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      return {'hour': hour, 'minute': minute};
    } catch (e) {
      return null;
    }
  }
}
