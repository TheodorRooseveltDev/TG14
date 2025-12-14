import 'package:flutter/foundation.dart';
import '../../data/models/game_model.dart';
import '../../data/services/supabase_service.dart';

class GamesProvider with ChangeNotifier {
  List<GameModel> _allGames = [];
  List<GameModel> _featuredGames = [];
  List<GameModel> _filteredGames = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<GameModel> get allGames => _allGames;
  List<GameModel> get featuredGames => _featuredGames;
  List<GameModel> get filteredGames => _filteredGames.isEmpty && _searchQuery.isEmpty && _selectedCategory == 'All' 
      ? _allGames 
      : _filteredGames;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _allGames.map((g) => g.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  Future<void> loadGames() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _allGames = await SupabaseService.fetchGames();
      _featuredGames = _allGames.where((g) => g.isFeatured).toList();
      
      // If no featured games, use first 4
      if (_featuredGames.isEmpty && _allGames.length >= 4) {
        _featuredGames = _allGames.take(4).toList();
      }
      
      _filteredGames = _allGames;
      _error = '';
    } catch (e) {
      _error = 'Failed to load games: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchGames(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredGames = _allGames.where((game) {
      final matchesSearch = _searchQuery.isEmpty || 
          game.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || 
          game.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    notifyListeners();
  }

  GameModel? getRandomGame() {
    if (_allGames.isEmpty) return null;
    final shuffled = List<GameModel>.from(_allGames)..shuffle();
    return shuffled.first;
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _filteredGames = _allGames;
    notifyListeners();
  }
}
