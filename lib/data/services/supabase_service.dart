import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/game_model.dart';

class SupabaseService {
  static SupabaseClient? _client;
  
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (url == null || anonKey == null) {
      throw Exception('Supabase credentials not found in .env');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    
    _client = Supabase.instance.client;
  }

  // Get storage bucket URL
  static String get storageBucket {
    return dotenv.env['SUPABASE_STORAGE_BUCKET'] ?? 'assets';
  }

  // Get image URL from storage
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    
    // Remove leading slash if present for storage path
    String cleanPath = path;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    
    // If path starts with 'assets/', it's relative to the bucket
    if (cleanPath.startsWith('assets/')) {
      cleanPath = cleanPath.substring(7); // Remove 'assets/' prefix
    }
    
    final url = client.storage.from(storageBucket).getPublicUrl(cleanPath);
    return url;
  }

  // Fetch all games
  static Future<List<GameModel>> fetchGames() async {
    try {
      final response = await client
          .from('games')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => GameModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch featured games
  static Future<List<GameModel>> fetchFeaturedGames() async {
    try {
      final response = await client
          .from('games')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => GameModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch games by category
  static Future<List<GameModel>> fetchGamesByCategory(String category) async {
    try {
      final response = await client
          .from('games')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => GameModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Search games
  static Future<List<GameModel>> searchGames(String query) async {
    try {
      final response = await client
          .from('games')
          .select()
          .ilike('name', '%$query%')
          .order('name');
      
      return (response as List)
          .map((json) => GameModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get random game (for wheel)
  static Future<GameModel?> getRandomGame() async {
    try {
      final games = await fetchGames();
      if (games.isEmpty) return null;
      games.shuffle();
      return games.first;
    } catch (e) {
      return null;
    }
  }
}
