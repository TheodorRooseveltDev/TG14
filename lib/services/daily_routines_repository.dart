import '../services/database_service.dart';
import '../models/daily_routine.dart';
import 'package:sqflite/sqflite.dart';

/// Repository for managing daily routine checklists
class DailyRoutinesRepository {
  /// Get all routines
  static Future<List<DailyRoutine>> getAllRoutines() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_routines',
      orderBy: 'order_index ASC',
    );

    return List.generate(maps.length, (i) => DailyRoutine.fromMap(maps[i]));
  }

  /// Get routines by category
  static Future<List<DailyRoutine>> getRoutinesByCategory(String category) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_routines',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'order_index ASC',
    );

    return List.generate(maps.length, (i) => DailyRoutine.fromMap(maps[i]));
  }

  /// Get routine by ID
  static Future<DailyRoutine?> getRoutineById(int id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_routines',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DailyRoutine.fromMap(maps.first);
  }

  /// Insert new routine
  static Future<int> insertRoutine(DailyRoutine routine) async {
    final db = await DatabaseService.database;
    return await db.insert('daily_routines', routine.toMap());
  }

  /// Update existing routine
  static Future<int> updateRoutine(DailyRoutine routine) async {
    final db = await DatabaseService.database;
    return await db.update(
      'daily_routines',
      routine.toMap(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  /// Toggle completion status
  static Future<void> toggleCompletion(int id, bool isCompleted) async {
    final db = await DatabaseService.database;
    await db.update(
      'daily_routines',
      {
        'is_completed': isCompleted ? 1 : 0,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete routine
  static Future<int> deleteRoutine(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'daily_routines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Reset all completions (for new day)
  static Future<void> resetAllCompletions() async {
    final db = await DatabaseService.database;
    await db.update(
      'daily_routines',
      {
        'is_completed': 0,
        'completed_at': null,
      },
    );
  }

  /// Get completion stats for today
  static Future<Map<String, dynamic>> getCompletionStats() async {
    final db = await DatabaseService.database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_routines',
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_routines WHERE is_completed = 1',
    );
    final completed = Sqflite.firstIntValue(completedResult) ?? 0;
    
    final preShiftResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_routines WHERE category = ? AND is_completed = 1',
      ['pre-shift'],
    );
    final preShiftCompleted = Sqflite.firstIntValue(preShiftResult) ?? 0;
    
    final preShiftTotalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_routines WHERE category = ?',
      ['pre-shift'],
    );
    final preShiftTotal = Sqflite.firstIntValue(preShiftTotalResult) ?? 0;
    
    final duringShiftResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_routines WHERE category = ? AND is_completed = 1',
      ['during-shift'],
    );
    final duringShiftCompleted = Sqflite.firstIntValue(duringShiftResult) ?? 0;
    
    final duringShiftTotalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_routines WHERE category = ?',
      ['during-shift'],
    );
    final duringShiftTotal = Sqflite.firstIntValue(duringShiftTotalResult) ?? 0;
    
    final postShiftResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_routines WHERE category = ? AND is_completed = 1',
      ['post-shift'],
    );
    final postShiftCompleted = Sqflite.firstIntValue(postShiftResult) ?? 0;
    
    final postShiftTotalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_routines WHERE category = ?',
      ['post-shift'],
    );
    final postShiftTotal = Sqflite.firstIntValue(postShiftTotalResult) ?? 0;
    
    return {
      'total': total,
      'completed': completed,
      'percentage': total > 0 ? (completed / total * 100).round() : 0,
      'preShift': {
        'completed': preShiftCompleted,
        'total': preShiftTotal,
        'percentage': preShiftTotal > 0 ? (preShiftCompleted / preShiftTotal * 100).round() : 0,
      },
      'duringShift': {
        'completed': duringShiftCompleted,
        'total': duringShiftTotal,
        'percentage': duringShiftTotal > 0 ? (duringShiftCompleted / duringShiftTotal * 100).round() : 0,
      },
      'postShift': {
        'completed': postShiftCompleted,
        'total': postShiftTotal,
        'percentage': postShiftTotal > 0 ? (postShiftCompleted / postShiftTotal * 100).round() : 0,
      },
    };
  }

  /// Initialize default routines if none exist
  static Future<void> initializeDefaultRoutines() async {
    final db = await DatabaseService.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM daily_routines'),
    );

    if (count == null || count == 0) {
      final defaultRoutines = _getDefaultRoutines();
      final batch = db.batch();
      
      for (final routine in defaultRoutines) {
        batch.insert('daily_routines', routine.toMap());
      }
      
      await batch.commit(noResult: true);
    }
  }

  /// Get default routine checklists
  static List<DailyRoutine> _getDefaultRoutines() {
    return [
      // ========== PRE-SHIFT ROUTINES (10 items) ==========
      DailyRoutine(
        category: 'pre-shift',
        title: 'Arrive 15 Minutes Early',
        description: 'Give yourself time to mentally prepare and avoid rushing. Check schedule for any changes.',
        orderIndex: 1,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Personal Grooming Check',
        description: 'Clean uniform, name tag visible, hair neat, nails trimmed, no strong cologne/perfume.',
        orderIndex: 2,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Review House Rules',
        description: 'Quick mental review of any recent rule changes, special promotions, or new procedures.',
        orderIndex: 3,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Check Your Table Assignment',
        description: 'Know your table number, game type, and limits. Note any VIP players expected.',
        orderIndex: 4,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Inspect Your Table',
        description: 'Check felt condition, card decks, chip racks, discard holder, and all equipment.',
        orderIndex: 5,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Count Your Bank',
        description: 'Verify chip inventory matches your bank slip. Report any discrepancies immediately.',
        orderIndex: 6,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Test Equipment',
        description: 'Card shuffler (if applicable), drop slot, table limit sign, chair height.',
        orderIndex: 7,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Mental Preparation',
        description: 'Take 3 deep breaths. Visualize smooth, confident dealing. Set intention for excellent service.',
        orderIndex: 8,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Hydration & Nutrition',
        description: 'Drink water, use restroom, have a small snack if needed. Won\'t get another chance soon.',
        orderIndex: 9,
      ),
      DailyRoutine(
        category: 'pre-shift',
        title: 'Check-In with Pit Boss',
        description: 'Report to your supervisor, confirm any special instructions or announcements.',
        orderIndex: 10,
      ),

      // ========== DURING-SHIFT ROUTINES (8 items) ==========
      DailyRoutine(
        category: 'during-shift',
        title: 'Maintain Professional Posture',
        description: 'Stand straight, shoulders back, hands visible. Good posture prevents fatigue and looks professional.',
        orderIndex: 1,
      ),
      DailyRoutine(
        category: 'during-shift',
        title: 'Clear Communication',
        description: 'Announce game actions clearly ("Card to player one", "Dealer pays 21"). Use hand signals.',
        orderIndex: 2,
      ),
      DailyRoutine(
        category: 'during-shift',
        title: 'Pace Control',
        description: 'Keep steady game pace. Not too fast (players feel rushed) or slow (boring). Read the table.',
        orderIndex: 3,
      ),
      DailyRoutine(
        category: 'during-shift',
        title: 'Monitor For Mistakes',
        description: 'Count chips twice, verify payouts, watch for mis-dealt cards. Catch errors before they escalate.',
        orderIndex: 4,
      ),
      DailyRoutine(
        category: 'during-shift',
        title: 'Engage with Players',
        description: 'Friendly greetings, remember names, light conversation (when appropriate). Create welcoming atmosphere.',
        orderIndex: 5,
      ),
      DailyRoutine(
        category: 'during-shift',
        title: 'Security Awareness',
        description: 'Watch for late bets, collusion, card marking, chip thefts. Report suspicious behavior.',
        orderIndex: 6,
      ),
      DailyRoutine(
        category: 'during-shift',
        title: 'Keep Table Organized',
        description: 'Discard pile neat, chip rack organized, cards aligned. Messy table = mistakes.',
        orderIndex: 7,
      ),
      DailyRoutine(
        category: 'during-shift',
        title: 'Stay Hydrated on Breaks',
        description: 'Use every break: water, bathroom, quick stretch. Don\'t skip breaks even if table is hot.',
        orderIndex: 8,
      ),

      // ========== POST-SHIFT ROUTINES (7 items) ==========
      DailyRoutine(
        category: 'post-shift',
        title: 'Count Your Bank Out',
        description: 'Count chip inventory carefully. Fill out paperwork accurately. Double-check math.',
        orderIndex: 1,
      ),
      DailyRoutine(
        category: 'post-shift',
        title: 'Clear & Reset Table',
        description: 'Remove used cards, tidy chip rack, wipe down felt if needed, reset table limit sign.',
        orderIndex: 2,
      ),
      DailyRoutine(
        category: 'post-shift',
        title: 'Report Any Issues',
        description: 'Tell pit boss about: equipment problems, player disputes, unusual occurrences, outstanding fills/credits.',
        orderIndex: 3,
      ),
      DailyRoutine(
        category: 'post-shift',
        title: 'Log Important Notes',
        description: 'Use Casino Dealer\'s Flow app to record: big hands, mistakes made, lessons learned, player behaviors.',
        orderIndex: 4,
      ),
      DailyRoutine(
        category: 'post-shift',
        title: 'Handoff Communication',
        description: 'Brief next dealer on: table conditions, player personalities, any ongoing situations.',
        orderIndex: 5,
      ),
      DailyRoutine(
        category: 'post-shift',
        title: 'Mental Review',
        description: 'Reflect on shift: What went well? What to improve? Any procedures to study?',
        orderIndex: 6,
      ),
      DailyRoutine(
        category: 'post-shift',
        title: 'Self-Care',
        description: 'Decompress before driving home. Stretch sore muscles. Leave work stress at work.',
        orderIndex: 7,
      ),
    ];
  }
}
