import 'models/game.dart';

/// Mock data provider for games
/// This will be replaced with actual API data later
class MockData {
  MockData._();

  /// Get all mock games
  static List<Game> get allGames => [
    ...hotGames,
    ...slotGames,
    ...tableGames,
    ...diceGames,
  ];

  /// Hot games for homepage
  static List<Game> get hotGames => [
    const Game(
      id: 'hot_1',
      name: 'Golden Fortune',
      description: 'Spin the reels of fortune and win massive jackpots!',
      category: GameCategory.hot,
      rating: 4.9,
      isHot: true,
      playersCount: 1234,
    ),
    const Game(
      id: 'hot_2',
      name: 'Vegas Nights',
      description: 'Experience the glamour of Las Vegas in this exciting slot!',
      category: GameCategory.hot,
      rating: 4.8,
      isHot: true,
      playersCount: 987,
    ),
    const Game(
      id: 'hot_3',
      name: 'Diamond Rush',
      description: 'Hunt for diamonds and win sparkling prizes!',
      category: GameCategory.hot,
      rating: 4.7,
      isHot: true,
      playersCount: 756,
    ),
    const Game(
      id: 'hot_4',
      name: 'Lucky Dragon',
      description: 'The dragon brings luck and fortune to all who play!',
      category: GameCategory.hot,
      rating: 4.6,
      isHot: true,
      playersCount: 654,
    ),
    const Game(
      id: 'hot_5',
      name: 'Pharaoh\'s Gold',
      description: 'Discover ancient Egyptian treasures!',
      category: GameCategory.hot,
      rating: 4.5,
      isHot: true,
      playersCount: 543,
    ),
  ];

  /// Slot games
  static List<Game> get slotGames => [
    const Game(
      id: 'slot_1',
      name: 'Classic Fruits',
      description: 'Traditional fruit machine with modern twists.',
      category: GameCategory.slots,
      rating: 4.5,
      isNew: true,
    ),
    const Game(
      id: 'slot_2',
      name: 'Wild Safari',
      description: 'Go on an adventure with wild animals!',
      category: GameCategory.slots,
      rating: 4.4,
    ),
    const Game(
      id: 'slot_3',
      name: 'Ocean Treasures',
      description: 'Dive deep and find underwater riches.',
      category: GameCategory.slots,
      rating: 4.6,
    ),
    const Game(
      id: 'slot_4',
      name: 'Space Odyssey',
      description: 'Explore the cosmos and win galactic prizes!',
      category: GameCategory.slots,
      rating: 4.3,
      isNew: true,
    ),
    const Game(
      id: 'slot_5',
      name: 'Mystic Forest',
      description: 'Enter the enchanted forest of wins.',
      category: GameCategory.slots,
      rating: 4.5,
    ),
  ];

  /// Table games
  static List<Game> get tableGames => [
    const Game(
      id: 'table_1',
      name: 'Blackjack Pro',
      description: 'Classic 21 with professional dealing.',
      category: GameCategory.tableGames,
      rating: 4.8,
      isHot: true,
    ),
    const Game(
      id: 'table_2',
      name: 'Royal Roulette',
      description: 'Spin the wheel and test your luck!',
      category: GameCategory.tableGames,
      rating: 4.7,
    ),
    const Game(
      id: 'table_3',
      name: 'Texas Hold\'em',
      description: 'The king of poker games.',
      category: GameCategory.tableGames,
      rating: 4.9,
      isHot: true,
    ),
    const Game(
      id: 'table_4',
      name: 'Baccarat Elite',
      description: 'The sophisticated choice for high rollers.',
      category: GameCategory.tableGames,
      rating: 4.6,
    ),
    const Game(
      id: 'table_5',
      name: 'Craps Master',
      description: 'Roll the dice and win big!',
      category: GameCategory.tableGames,
      rating: 4.4,
    ),
  ];

  /// Dice and casual games
  static List<Game> get diceGames => [
    const Game(
      id: 'dice_1',
      name: 'Lucky Dice',
      description: 'Simple dice game with big payouts!',
      category: GameCategory.diceGames,
      rating: 4.3,
      isNew: true,
    ),
    const Game(
      id: 'dice_2',
      name: 'Scratch & Win',
      description: 'Scratch cards with instant prizes.',
      category: GameCategory.diceGames,
      rating: 4.2,
    ),
    const Game(
      id: 'dice_3',
      name: 'Keno Classic',
      description: 'Pick your lucky numbers!',
      category: GameCategory.diceGames,
      rating: 4.1,
    ),
    const Game(
      id: 'dice_4',
      name: 'Coin Flip',
      description: 'Heads or tails? Double your coins!',
      category: GameCategory.diceGames,
      rating: 4.0,
    ),
  ];

  /// Get games by category
  static List<Game> getByCategory(GameCategory category) {
    return allGames.where((game) => game.category == category).toList();
  }

  /// Get random game for mystery picker
  static Game getRandomGame() {
    final games = allGames;
    games.shuffle();
    return games.first;
  }
}
