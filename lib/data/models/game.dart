/// Game category enum
enum GameCategory {
  hot,
  slots,
  tableGames,
  diceGames,
  newGames,
  highRoller,
  tournaments;

  String get displayName {
    switch (this) {
      case GameCategory.hot:
        return 'Hot Games';
      case GameCategory.slots:
        return 'Slots';
      case GameCategory.tableGames:
        return 'Table Games';
      case GameCategory.diceGames:
        return 'Dice & Casual';
      case GameCategory.newGames:
        return 'New Games';
      case GameCategory.highRoller:
        return 'High Roller';
      case GameCategory.tournaments:
        return 'Tournaments';
    }
  }

  String get emoji {
    switch (this) {
      case GameCategory.hot:
        return '🔥';
      case GameCategory.slots:
        return '🎰';
      case GameCategory.tableGames:
        return '🃏';
      case GameCategory.diceGames:
        return '🎲';
      case GameCategory.newGames:
        return '⭐';
      case GameCategory.highRoller:
        return '💰';
      case GameCategory.tournaments:
        return '🏆';
    }
  }
}

/// Game model representing a casino game
class Game {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final GameCategory category;
  final double rating;
  final bool isHot;
  final bool isNew;
  final int minBet;
  final int maxBet;
  final int playersCount;

  const Game({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.category,
    this.rating = 4.5,
    this.isHot = false,
    this.isNew = false,
    this.minBet = 100,
    this.maxBet = 10000,
    this.playersCount = 0,
  });

  /// Create a copy with modified fields
  Game copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    GameCategory? category,
    double? rating,
    bool? isHot,
    bool? isNew,
    int? minBet,
    int? maxBet,
    int? playersCount,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      isHot: isHot ?? this.isHot,
      isNew: isNew ?? this.isNew,
      minBet: minBet ?? this.minBet,
      maxBet: maxBet ?? this.maxBet,
      playersCount: playersCount ?? this.playersCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Game && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
