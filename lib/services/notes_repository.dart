import '../models/table_note.dart';
import 'database_service.dart';

/// Repository for Table Notes CRUD operations
class NotesRepository {
  /// Add a new table note
  static Future<int> addNote(TableNote note) async {
    final db = await DatabaseService.database;
    
    try {
      final id = await db.insert('table_notes', note.toMap());
      
      // Award XP for creating note
      await _awardXP(20, 'note_created');
      
      // Update stats
      await _updateStats();
      
      return id;
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }
  
  /// Get all notes
  static Future<List<TableNote>> getAllNotes({
    String? gameType,
    bool? favoritesOnly,
    int? limit,
    int? offset,
  }) async {
    final db = await DatabaseService.database;
    
    try {
      String? whereClause;
      List<dynamic>? whereArgs;
      
      if (gameType != null && gameType != 'all') {
        whereClause = 'game_type = ?';
        whereArgs = [gameType];
      }
      
      if (favoritesOnly == true) {
        whereClause = whereClause != null
            ? '$whereClause AND is_favorite = 1'
            : 'is_favorite = 1';
      }
      
      final maps = await db.query(
        'table_notes',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'updated_at DESC',
        limit: limit,
        offset: offset,
      );
      
      return maps.map((map) => TableNote.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get notes: $e');
    }
  }
  
  /// Search notes by keyword
  static Future<List<TableNote>> searchNotes(String query) async {
    final db = await DatabaseService.database;
    
    try {
      final searchPattern = '%$query%';
      final maps = await db.rawQuery('''
        SELECT * FROM table_notes 
        WHERE game_type LIKE ? 
        OR table_id LIKE ?
        OR sequence_reminders LIKE ?
        OR common_mistakes LIKE ?
        OR player_tendencies LIKE ?
        OR tags LIKE ?
        ORDER BY updated_at DESC
      ''', [
        searchPattern,
        searchPattern,
        searchPattern,
        searchPattern,
        searchPattern,
        searchPattern,
      ]);
      
      return maps.map((map) => TableNote.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }
  
  /// Get note by ID
  static Future<TableNote?> getNoteById(int id) async {
    final db = await DatabaseService.database;
    
    try {
      final maps = await db.query(
        'table_notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) return null;
      return TableNote.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get note: $e');
    }
  }
  
  /// Update note
  static Future<void> updateNote(TableNote note) async {
    final db = await DatabaseService.database;
    
    try {
      await db.update(
        'table_notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }
  
  /// Delete note
  static Future<void> deleteNote(int id) async {
    final db = await DatabaseService.database;
    
    try {
      await db.delete(
        'table_notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Update stats
      await _updateStats();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
  
  /// Toggle favorite status
  static Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await DatabaseService.database;
    
    try {
      await db.update(
        'table_notes',
        {'is_favorite': isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }
  
  /// Get total notes count
  static Future<int> getTotalNotesCount() async {
    final db = await DatabaseService.database;
    
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM table_notes');
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }
  
  /// Get notes count by game type
  static Future<Map<String, int>> getNotesCountByGame() async {
    final db = await DatabaseService.database;
    
    try {
      final result = await db.rawQuery('''
        SELECT game_type, COUNT(*) as count 
        FROM table_notes 
        GROUP BY game_type
      ''');
      
      final counts = <String, int>{};
      for (final row in result) {
        counts[row['game_type'] as String] = row['count'] as int;
      }
      
      return counts;
    } catch (e) {
      return {};
    }
  }
  
  /// Get all unique tags
  static Future<List<String>> getAllTags() async {
    try {
      final notes = await getAllNotes();
      final allTags = <String>{};
      
      for (final note in notes) {
        allTags.addAll(note.tags);
      }
      
      return allTags.toList()..sort();
    } catch (e) {
      return [];
    }
  }
  
  /// Award XP for action
  static Future<void> _awardXP(int xp, String reason) async {
    final db = await DatabaseService.database;
    
    try {
      final statsResult = await db.query('user_stats', where: 'id = 1');
      if (statsResult.isEmpty) return;
      
      final currentXP = statsResult.first['total_xp'] as int;
      final newXP = currentXP + xp;
      final newRank = _calculateRank(newXP);
      
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
      // Silent fail
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
      final notesCount = await getTotalNotesCount();
      
      await db.update(
        'user_stats',
        {
          'notes_created': notesCount,
          'last_active': DateTime.now().toIso8601String(),
        },
        where: 'id = 1',
      );
    } catch (e) {
      // Silent fail
    }
  }
}
