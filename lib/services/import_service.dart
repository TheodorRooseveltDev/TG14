import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'database_service.dart';

/// Service for importing data into the app
class ImportService {
  /// Import data from JSON backup file
  static Future<bool> importFromJSON() async {
    try {
      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return false; // User cancelled
      }
      
      final filePath = result.files.first.path;
      if (filePath == null) {
        throw Exception('File path is null');
      }
      
      // Read file content
      final file = File(filePath);
      final jsonString = await file.readAsString();
      
      // Parse JSON
      final Map<String, dynamic> importData = json.decode(jsonString);
      
      // Validate structure
      if (!importData.containsKey('data') || !importData.containsKey('appVersion')) {
        throw Exception('Invalid backup file format');
      }
      
      final data = importData['data'] as Map<String, dynamic>;
      
      // Get database
      final db = await DatabaseService.database;
      
      // Import data in a transaction
      await db.transaction((txn) async {
        // Clear existing data (optional - could merge instead)
        await txn.delete('shifts');
        await txn.delete('table_notes');
        
        // Import shifts
        if (data.containsKey('shifts')) {
          final shifts = data['shifts'] as List;
          for (final shift in shifts) {
            await txn.insert('shifts', shift as Map<String, dynamic>);
          }
        }
        
        // Import table notes
        if (data.containsKey('table_notes')) {
          final notes = data['table_notes'] as List;
          for (final note in notes) {
            await txn.insert('table_notes', note as Map<String, dynamic>);
          }
        }
        
        // Import user stats (update, don't insert)
        if (data.containsKey('user_stats')) {
          final stats = data['user_stats'] as List;
          if (stats.isNotEmpty) {
            final userStat = stats.first as Map<String, dynamic>;
            await txn.update(
              'user_stats',
              userStat,
              where: 'id = 1',
            );
          }
        }
        
        // Import game rules
        if (data.containsKey('game_rules')) {
          await txn.delete('game_rules');
          final rules = data['game_rules'] as List;
          for (final rule in rules) {
            await txn.insert('game_rules', rule as Map<String, dynamic>);
          }
        }
        
        // Import scenarios
        if (data.containsKey('scenarios')) {
          await txn.delete('scenarios');
          final scenarios = data['scenarios'] as List;
          for (final scenario in scenarios) {
            await txn.insert('scenarios', scenario as Map<String, dynamic>);
          }
        }
        
        // Import routines
        if (data.containsKey('routines')) {
          await txn.delete('routines');
          final routines = data['routines'] as List;
          for (final routine in routines) {
            await txn.insert('routines', routine as Map<String, dynamic>);
          }
        }
        
        // Import achievements (update completion status)
        if (data.containsKey('achievements')) {
          await txn.delete('achievements');
          final achievements = data['achievements'] as List;
          for (final achievement in achievements) {
            await txn.insert('achievements', achievement as Map<String, dynamic>);
          }
        }
        
        // Import app settings (update, don't insert)
        if (data.containsKey('app_settings')) {
          final settings = data['app_settings'] as List;
          if (settings.isNotEmpty) {
            final setting = settings.first as Map<String, dynamic>;
            await txn.update(
              'app_settings',
              setting,
              where: 'id = 1',
            );
          }
        }
      });
      
      return true;
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
  
  /// Validate JSON backup file structure
  static Future<Map<String, dynamic>?> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importData = json.decode(jsonString);
      
      if (!importData.containsKey('data') || !importData.containsKey('appVersion')) {
        return null;
      }
      
      // Return metadata if valid
      return {
        'exportDate': importData['exportDate'],
        'appVersion': importData['appVersion'],
        'metadata': importData['metadata'],
      };
    } catch (e) {
      return null;
    }
  }
  
  /// Get import preview statistics
  static Future<Map<String, int>?> getImportPreview() async {
    try {
      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }
      
      final filePath = result.files.first.path;
      if (filePath == null) {
        return null;
      }
      
      // Read and parse file
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importData = json.decode(jsonString);
      
      if (!importData.containsKey('metadata')) {
        return null;
      }
      
      final metadata = importData['metadata'] as Map<String, dynamic>;
      
      return {
        'totalShifts': metadata['totalShifts'] as int? ?? 0,
        'totalNotes': metadata['totalNotes'] as int? ?? 0,
        'totalXP': metadata['totalXP'] as int? ?? 0,
      };
    } catch (e) {
      return null;
    }
  }
}
