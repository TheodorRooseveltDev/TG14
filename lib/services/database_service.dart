import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 100% OFFLINE Database Service - NO NETWORK EVER
/// All data stays on device. Period.
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'dealer_flow.db';
  static const int _dbVersion = 1;
  
  /// Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  
  /// Initialize local SQLite database
  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// Create all tables on first launch
  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
    await _insertDefaultData(db);
  }
  
  /// Handle database migrations
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle future schema changes
  }
  
  /// Create all database tables
  static Future<void> _createTables(Database db) async {
    // Shifts table
    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        start_time TEXT,
        end_time TEXT,
        games_dealt TEXT,
        crew_notes TEXT,
        challenges TEXT,
        wins TEXT,
        mood_before INTEGER,
        mood_after INTEGER,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Table notes
    await db.execute('''
      CREATE TABLE table_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_type TEXT NOT NULL,
        table_id TEXT,
        sequence_reminders TEXT,
        common_mistakes TEXT,
        player_tendencies TEXT,
        communication_points TEXT,
        handling_reminders TEXT,
        edge_cases TEXT,
        tags TEXT,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Game rules
    await db.execute('''
      CREATE TABLE game_rules (
        id TEXT PRIMARY KEY,
        game_name TEXT NOT NULL,
        overview TEXT NOT NULL,
        dealing_procedure TEXT NOT NULL,
        payout_structure TEXT NOT NULL,
        common_mistakes TEXT NOT NULL,
        house_edge TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Scenarios
    await db.execute('''
      CREATE TABLE scenarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_type TEXT NOT NULL,
        description TEXT NOT NULL,
        what_went_wrong TEXT,
        correct_approach TEXT,
        personal_takeaway TEXT,
        difficulty_level INTEGER,
        tags TEXT,
        times_reviewed INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Daily routines (checklists)
    await db.execute('''
      CREATE TABLE daily_routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        is_completed INTEGER DEFAULT 0,
        completed_at TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // User stats
    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY DEFAULT 1,
        total_xp INTEGER DEFAULT 0,
        current_rank TEXT DEFAULT 'Rookie Dealer',
        shifts_logged INTEGER DEFAULT 0,
        notes_created INTEGER DEFAULT 0,
        scenarios_analyzed INTEGER DEFAULT 0,
        routines_completed INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        total_hours_worked REAL DEFAULT 0,
        favorite_game TEXT,
        last_active TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Achievements
    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        target_value INTEGER NOT NULL,
        current_value INTEGER DEFAULT 0,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_at TEXT,
        xp_reward INTEGER NOT NULL,
        icon_name TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // App settings
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        theme TEXT DEFAULT 'green_felt',
        sound_enabled INTEGER DEFAULT 1,
        haptic_enabled INTEGER DEFAULT 1,
        quick_note_enabled INTEGER DEFAULT 1,
        biometric_lock INTEGER DEFAULT 0,
        last_backup_date TEXT,
        app_opened_count INTEGER DEFAULT 0,
        onboarding_completed INTEGER DEFAULT 0,
        selected_games TEXT,
        shift_reminder_time TEXT,
        auto_save_interval INTEGER DEFAULT 30
      )
    ''');
  }
  
  /// Create indexes for fast queries
  static Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_shifts_date ON shifts(date)');
    await db.execute('CREATE INDEX idx_shifts_created ON shifts(created_at)');
    await db.execute('CREATE INDEX idx_notes_game ON table_notes(game_type)');
    await db.execute('CREATE INDEX idx_notes_favorite ON table_notes(is_favorite)');
    await db.execute('CREATE INDEX idx_scenarios_game ON scenarios(game_type)');
    await db.execute('CREATE INDEX idx_daily_routines_category ON daily_routines(category)');
    await db.execute('CREATE INDEX idx_achievements_unlocked ON achievements(is_unlocked)');
    await db.execute('CREATE INDEX idx_achievements_category ON achievements(category)');
  }
  
  /// Insert default data
  static Future<void> _insertDefaultData(Database db) async {
    // Initialize user stats
    await db.insert('user_stats', {
      'id': 1,
      'total_xp': 0,
      'current_rank': 'Rookie Dealer',
      'last_active': DateTime.now().toIso8601String(),
    });
    
    // Initialize app settings
    await db.insert('app_settings', {
      'id': 1,
      'onboarding_completed': 0,
      'app_opened_count': 0,
    });
    
    // Game rules, scenarios, daily routines, and achievements
    // will be initialized via their respective repositories
    // to avoid circular dependencies
  }
  
  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  /// Reset database (for development/testing)
  static Future<void> reset() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    _database = null;
  }
}
