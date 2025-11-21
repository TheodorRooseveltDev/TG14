import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'database_service.dart';
import 'shift_repository.dart';
import 'notes_repository.dart';
import 'user_stats_repository.dart';

/// Service for exporting app data to various formats
class ExportService {
  /// Export complete database to JSON format
  static Future<String> exportToJSON() async {
    try {
      final db = await DatabaseService.database;
      
      // Export all tables
      final shifts = await db.query('shifts');
      final tableNotes = await db.query('table_notes');
      final userStats = await db.query('user_stats');
      final gameRules = await db.query('game_rules');
      final scenarios = await db.query('scenarios');
      final routines = await db.query('routines');
      final achievements = await db.query('achievements');
      final appSettings = await db.query('app_settings');
      
      // Create export object
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'data': {
          'shifts': shifts,
          'table_notes': tableNotes,
          'user_stats': userStats,
          'game_rules': gameRules,
          'scenarios': scenarios,
          'routines': routines,
          'achievements': achievements,
          'app_settings': appSettings,
        },
        'metadata': {
          'totalShifts': shifts.length,
          'totalNotes': tableNotes.length,
          'totalXP': userStats.isNotEmpty ? userStats.first['total_xp'] : 0,
        },
      };
      
      // Convert to JSON string
      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);
      
      return jsonString;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
  
  /// Export shifts to CSV format
  static Future<String> exportShiftsToCSV() async {
    try {
      final shifts = await ShiftRepository.getAllShifts();
      
      // Create CSV rows
      final List<List<dynamic>> rows = [];
      
      // Add header
      rows.add([
        'Date',
        'Start Time',
        'End Time',
        'Games Dealt',
        'Mood Before',
        'Mood After',
        'Wins',
        'Challenges',
        'Crew Notes',
        'Notes',
        'Created At',
      ]);
      
      // Add data rows
      for (final shift in shifts) {
        rows.add([
          shift.date.toIso8601String().split('T')[0],
          shift.startTime ?? '',
          shift.endTime ?? '',
          shift.gamesDealt.join(', '),
          shift.moodBefore?.toString() ?? '',
          shift.moodAfter?.toString() ?? '',
          shift.wins.join('; '),
          shift.challenges.join('; '),
          shift.crewNotes ?? '',
          shift.notes ?? '',
          shift.createdAt.toIso8601String(),
        ]);
      }
      
      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);
      
      return csvString;
    } catch (e) {
      throw Exception('Failed to export shifts: $e');
    }
  }
  
  /// Export notes to Markdown format
  static Future<String> exportNotesToMarkdown() async {
    try {
      final notes = await NotesRepository.getAllNotes();
      
      final buffer = StringBuffer();
      
      // Add header
      buffer.writeln('# Table Notes Export');
      buffer.writeln();
      buffer.writeln('**Exported:** ${DateTime.now().toString()}');
      buffer.writeln('**Total Notes:** ${notes.length}');
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
      
      // Add each note
      for (final note in notes) {
        buffer.writeln('## ${note.gameType}${note.tableId != null ? ' - Table ${note.tableId}' : ''}');
        buffer.writeln();
        
        if (note.isFavorite) {
          buffer.writeln('⭐ **Favorite**');
          buffer.writeln();
        }
        
        if (note.tags.isNotEmpty) {
          buffer.writeln('**Tags:** ${note.tags.join(', ')}');
          buffer.writeln();
        }
        
        if (note.sequenceReminders?.isNotEmpty ?? false) {
          buffer.writeln('### Sequence Reminders');
          buffer.writeln(note.sequenceReminders);
          buffer.writeln();
        }
        
        if (note.commonMistakes?.isNotEmpty ?? false) {
          buffer.writeln('### Common Mistakes');
          buffer.writeln(note.commonMistakes);
          buffer.writeln();
        }
        
        if (note.playerTendencies?.isNotEmpty ?? false) {
          buffer.writeln('### Player Tendencies');
          buffer.writeln(note.playerTendencies);
          buffer.writeln();
        }
        
        if (note.communicationPoints?.isNotEmpty ?? false) {
          buffer.writeln('### Communication Points');
          buffer.writeln(note.communicationPoints);
          buffer.writeln();
        }
        
        if (note.handlingReminders?.isNotEmpty ?? false) {
          buffer.writeln('### Chip & Card Handling');
          buffer.writeln(note.handlingReminders);
          buffer.writeln();
        }
        
        if (note.edgeCases?.isNotEmpty ?? false) {
          buffer.writeln('### Edge Cases & Exceptions');
          buffer.writeln(note.edgeCases);
          buffer.writeln();
        }
        
        buffer.writeln('**Created:** ${note.createdAt.toString()}');
        buffer.writeln('**Updated:** ${note.updatedAt.toString()}');
        buffer.writeln();
        buffer.writeln('---');
        buffer.writeln();
      }
      
      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to export notes: $e');
    }
  }
  
  /// Save exported data to file and share
  static Future<void> saveAndShare({
    required String content,
    required String filename,
    required String mimeType,
  }) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$filename';
      
      // Write file
      final file = File(filePath);
      await file.writeAsString(content);
      
      // Share file
      await Share.shareXFiles(
        [XFile(filePath, mimeType: mimeType)],
        subject: 'Casino Dealer\'s Flow - $filename',
      );
    } catch (e) {
      throw Exception('Failed to save and share: $e');
    }
  }
  
  /// Export full backup (JSON)
  static Future<void> exportFullBackup() async {
    try {
      final jsonContent = await exportToJSON();
      final filename = 'casino_dealers_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      
      await saveAndShare(
        content: jsonContent,
        filename: filename,
        mimeType: 'application/json',
      );
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }
  
  /// Export shifts as CSV
  static Future<void> exportShiftsCSV() async {
    try {
      final csvContent = await exportShiftsToCSV();
      final filename = 'shifts_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      
      await saveAndShare(
        content: csvContent,
        filename: filename,
        mimeType: 'text/csv',
      );
    } catch (e) {
      throw Exception('Failed to export shifts: $e');
    }
  }
  
  /// Export notes as Markdown
  static Future<void> exportNotesMarkdown() async {
    try {
      final mdContent = await exportNotesToMarkdown();
      final filename = 'table_notes_${DateTime.now().millisecondsSinceEpoch}.md';
      
      await saveAndShare(
        content: mdContent,
        filename: filename,
        mimeType: 'text/markdown',
      );
    } catch (e) {
      throw Exception('Failed to export notes: $e');
    }
  }
  
  /// Get export statistics
  static Future<Map<String, int>> getExportStats() async {
    try {
      final shifts = await ShiftRepository.getAllShifts();
      final notes = await NotesRepository.getAllNotes();
      final stats = await UserStatsRepository.getUserStats();
      
      return {
        'shifts': shifts.length,
        'notes': notes.length,
        'totalXP': stats.totalXP,
      };
    } catch (e) {
      return {
        'shifts': 0,
        'notes': 0,
        'totalXP': 0,
      };
    }
  }
}
