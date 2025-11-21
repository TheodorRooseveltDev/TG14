import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/scenario.dart';

/// Repository for accessing practice scenarios from the database
class ScenariosRepository {
  /// Get all scenarios
  static Future<List<Scenario>> getAllScenarios() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scenarios',
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) => Scenario.fromMap(maps[i]));
  }
  
  /// Get scenario by ID
  static Future<Scenario?> getScenarioById(int id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scenarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Scenario.fromMap(maps.first);
  }
  
  /// Get scenarios by game type
  static Future<List<Scenario>> getScenariosByGame(String gameType) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scenarios',
      where: 'game_type = ?',
      whereArgs: [gameType],
      orderBy: 'difficulty_level ASC, created_at DESC',
    );
    
    return List.generate(maps.length, (i) => Scenario.fromMap(maps[i]));
  }
  
  /// Get scenarios by difficulty level
  static Future<List<Scenario>> getScenariosByDifficulty(int level) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scenarios',
      where: 'difficulty_level = ?',
      whereArgs: [level],
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) => Scenario.fromMap(maps[i]));
  }
  
  /// Search scenarios
  static Future<List<Scenario>> searchScenarios(String query) async {
    if (query.isEmpty) {
      return getAllScenarios();
    }
    
    final db = await DatabaseService.database;
    final searchTerm = '%${query.toLowerCase()}%';
    
    final List<Map<String, dynamic>> maps = await db.query(
      'scenarios',
      where: '''
        LOWER(description) LIKE ? OR 
        LOWER(what_went_wrong) LIKE ? OR 
        LOWER(correct_approach) LIKE ? OR
        LOWER(tags) LIKE ?
      ''',
      whereArgs: [searchTerm, searchTerm, searchTerm, searchTerm],
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) => Scenario.fromMap(maps[i]));
  }
  
  /// Insert new scenario
  static Future<int> insertScenario(Scenario scenario) async {
    final db = await DatabaseService.database;
    return await db.insert(
      'scenarios',
      scenario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Update scenario
  static Future<void> updateScenario(Scenario scenario) async {
    final db = await DatabaseService.database;
    await db.update(
      'scenarios',
      scenario.toMap(),
      where: 'id = ?',
      whereArgs: [scenario.id],
    );
  }
  
  /// Delete scenario
  static Future<void> deleteScenario(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'scenarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Increment review count
  static Future<void> incrementReviewCount(int id) async {
    final db = await DatabaseService.database;
    await db.rawUpdate('''
      UPDATE scenarios 
      SET times_reviewed = times_reviewed + 1 
      WHERE id = ?
    ''', [id]);
  }
  
  /// Initialize default scenarios
  static Future<void> initializeDefaultScenarios() async {
    final existing = await getAllScenarios();
    if (existing.isNotEmpty) return; // Already initialized
    
    final defaultScenarios = _getDefaultScenarios();
    for (final scenario in defaultScenarios) {
      await insertScenario(scenario);
    }
  }
  
  /// Get default practice scenarios
  static List<Scenario> _getDefaultScenarios() {
    return [
      // Blackjack Scenarios
      Scenario(
        gameType: 'Blackjack',
        description: 'Player splits 10s against dealer 6',
        whatWentWrong: 'You allowed the player to split two face cards (King and Queen) without questioning it. This is generally a bad play and some casinos have specific rules about splitting unlike 10-value cards.',
        correctApproach: 'Politely confirm with the player: "You\'d like to split these?" This gives them a moment to reconsider. Know your casino\'s policy on splitting unlike 10-value cards. Some houses only allow splitting identical cards (two Kings, not King-Queen).',
        personalTakeaway: 'Always verify unusual plays, especially splits. This protects both the player and maintains game integrity. A quick confirmation can prevent player complaints later.',
        difficultyLevel: 2,
        tags: ['splitting', 'player-communication', 'house-rules'],
      ),
      
      Scenario(
        gameType: 'Blackjack',
        description: 'Dealer blackjack with players having insurance',
        whatWentWrong: 'You paid out all winning hands before collecting insurance bets, causing confusion about which chips belonged to insurance vs. original bets.',
        correctApproach: 'Proper sequence: 1) Reveal hole card showing blackjack, 2) Immediately collect all losing insurance bets, 3) Pay winning insurance bets 2:1, 4) Clear all other bets (all push against dealer blackjack), 5) Start new hand.',
        personalTakeaway: 'Insurance resolution must happen first and separately. Keep insurance bets in front until resolved. Announce clearly: "Insurance pays 2 to 1" then "Dealer blackjack, all hands push."',
        difficultyLevel: 3,
        tags: ['insurance', 'blackjack', 'procedure', 'chip-handling'],
      ),
      
      // Roulette Scenarios
      Scenario(
        gameType: 'Roulette',
        description: 'Late bet placed as ball drops into pocket',
        whatWentWrong: 'A player quickly placed chips on 17 just as the ball was settling into the 17 pocket. You weren\'t sure if the bet was placed before or after "no more bets."',
        correctApproach: 'Call over your supervisor immediately. Explain what you observed. The timing is critical - if there\'s any doubt, the bet should not be paid. Most casinos have cameras that can review the exact timing. Never make this call alone.',
        personalTakeaway: 'Call "no more bets" clearly and at the right time (when ball is about to drop). Watch all players, not just the wheel. Past posters often work in teams to distract you. When in doubt, call surveillance.',
        difficultyLevel: 4,
        tags: ['past-posting', 'security', 'timing', 'supervisor'],
      ),
      
      Scenario(
        gameType: 'Roulette',
        description: 'Multiple players using same color chips',
        whatWentWrong: 'You lost track of which stacks belonged to which player because you allowed two players to share red chips, and their bets got mixed up during payout.',
        correctApproach: 'Each player MUST have unique color chips. When new player joins: 1) Assign them a specific color, 2) Set their chip value, 3) Place color marker on rail, 4) Never allow sharing. If all colors are taken, player must wait or play with cash (table minimum only).',
        personalTakeaway: 'Chip color discipline is non-negotiable. It prevents disputes and maintains game integrity. Always verify color assignments before accepting bets. Keep color markers visible.',
        difficultyLevel: 2,
        tags: ['chip-management', 'procedure', 'player-disputes'],
      ),
      
      // Craps Scenarios
      Scenario(
        gameType: 'Craps',
        description: 'Dice leave the table on come-out roll',
        whatWentWrong: 'Both dice flew off the table. You retrieved them and put them back in play without inspection or offering new dice to the shooter.',
        correctApproach: 'Procedure when dice leave table: 1) Call "Dice out!" immediately, 2) Inspect both dice carefully for damage/switches, 3) Show dice to boxman, 4) Offer shooter the stick with 5 dice, 5) Let shooter choose dice (they may want new ones), 6) Resume play.',
        personalTakeaway: 'Dice leaving the table is a security issue. Never rush this. Inspect thoroughly for chips, damage, or dice switches. Players may be superstitious about dice - respect that and offer fresh ones.',
        difficultyLevel: 3,
        tags: ['dice-security', 'procedure', 'integrity'],
      ),
      
      Scenario(
        gameType: 'Craps',
        description: 'Player wants odds but point is already established',
        whatWentWrong: 'Player made a Pass Line bet after the point was established (showing 6). You accepted the bet because they seemed confused and you wanted to help.',
        correctApproach: 'Politely explain: "Pass Line is closed once the point is established. You can make a Come bet instead, which works the same way." Point to the Come area. Never accept bets that violate game rules, even to "help" confused players.',
        personalTakeaway: 'Know which bets are allowed at each phase (come-out vs. point). Help players understand alternatives (Come vs. Pass Line). Being helpful means teaching correct play, not bending rules.',
        difficultyLevel: 2,
        tags: ['betting-rules', 'player-education', 'timing'],
      ),
      
      // Baccarat Scenarios
      Scenario(
        gameType: 'Baccarat',
        description: 'Third card for Banker with Player\'s third card was 8',
        whatWentWrong: 'Banker had 3, Player drew an 8 as third card. You gave Banker a third card, but Banker should stand when Player draws 8.',
        correctApproach: 'Banker third card rules when Banker has 3: Draw if Player\'s third card was 0-7 or 9, STAND if Player\'s third card was 8. This is the most commonly missed rule. Keep a reference card until memorized.',
        personalTakeaway: 'The "Banker 3 vs Player 8" rule is the exception everyone forgets. When Banker has 3, pause and verify Player\'s third card value before dealing. Write it on your reference card in red.',
        difficultyLevel: 4,
        tags: ['third-card-rules', 'baccarat', 'common-mistake'],
      ),
      
      // Poker Scenarios
      Scenario(
        gameType: 'Poker',
        description: 'String bet in cash game',
        whatWentWrong: 'Player said "I call your 20..." then went back to their stack and added more chips saying "...and raise 40." You allowed the raise because they verbally announced it.',
        correctApproach: 'This is a string bet - NOT allowed. Only the first action (call 20) counts. Rule: One motion forward or verbal declaration first. Once chips are placed and hand returns to stack, the action is complete. Announce: "Call only, sir/ma\'am."',
        personalTakeaway: 'String bets are angle shooting. Enforce strictly and consistently. If player declares "raise" first, they can go back for chips. If they push chips first, that\'s their bet - final.',
        difficultyLevel: 3,
        tags: ['string-bet', 'betting-rules', 'angle-shooting'],
      ),
      
      Scenario(
        gameType: 'Poker',
        description: 'Player exposes cards before action complete',
        whatWentWrong: 'Player with flush flipped their cards up excitedly before river action was complete. One player behind them still had to act. You weren\'t sure how to proceed.',
        correctApproach: 'Immediately protect the hand with your hand and say: "Your hand is still live but please keep it face down until action is complete." Hand is NOT dead unless both cards are fully exposed and pushed forward. Resume action with exposed hand face down.',
        personalTakeaway: 'Know the difference between exposed cards (still live if protected) and mucked cards (dead). Prevent premature celebration from killing hands. One-player-per-hand rule means you can\'t help, but can prevent their hand from being killed.',
        difficultyLevel: 3,
        tags: ['hand-protection', 'procedure', 'live-hand'],
      ),
      
      // Three Card Poker Scenario
      Scenario(
        gameType: 'Three Card Poker',
        description: 'Paid Play bet when dealer doesn\'t qualify',
        whatWentWrong: 'Dealer had Jack-high (doesn\'t qualify). You paid both Ante and Play bets 1:1. The Play bet should have been returned as a push.',
        correctApproach: 'When dealer doesn\'t qualify (worse than Q-high): 1) Pay Ante bets 1:1, 2) Return (push) all Play bets, 3) Pay Pair Plus separately regardless, 4) Pay Ante Bonus even if dealer wins. Common mistake - memorize this.',
        personalTakeaway: 'Dealer qualification affects Ante and Play differently. Play bet ALWAYS pushes when dealer doesn\'t qualify. Ante Bonus always pays. Keep a mental checklist: "Dealer qualified? No - Ante pays, Play pushes."',
        difficultyLevel: 3,
        tags: ['payout-error', 'qualification', 'three-card-poker'],
      ),
      
      // Pai Gow Poker Scenario
      Scenario(
        gameType: 'Pai Gow Poker',
        description: 'Player set hand with 2-card high hand beating 5-card hand',
        whatWentWrong: 'Player set their hand incorrectly (pair in low hand, high card in high hand). You didn\'t catch it until after revealing your hand. Player had already seen your cards.',
        correctApproach: 'Check EVERY player hand before revealing dealer hand. Fouled hands (low beats high) are dead - collect bet immediately. If you catch it after revealing dealer cards, call supervisor. House rules vary on whether player gets another chance.',
        personalTakeaway: 'Verification before dealer reveal is critical. Check each player: low hand lower than high hand. If uncertain about a hand ranking, verify before proceeding. Prevention is easier than resolution.',
        difficultyLevel: 3,
        tags: ['fouled-hand', 'verification', 'pai-gow'],
      ),
      
      // Multi-game Scenario
      Scenario(
        gameType: 'General',
        description: 'Angry player creating hostile environment',
        whatWentWrong: 'Player started yelling at another player for "taking cards" and making the table lose. You tried to calm them down alone, and situation escalated.',
        correctApproach: 'Never argue with angry players. Steps: 1) Stay calm and professional, 2) Acknowledge their frustration: "I understand you\'re upset," 3) Immediately signal floor supervisor, 4) Don\'t take sides or explain probability, 5) Let supervisor handle.',
        personalTakeaway: 'Dealers enforce rules, supervisors handle disputes. Don\'t try to be the hero. Your job is game protection and smooth operation, not psychology. Always back up from confrontation and get management.',
        difficultyLevel: 4,
        tags: ['player-management', 'supervisor', 'de-escalation', 'safety'],
      ),
      
      Scenario(
        gameType: 'General',
        description: 'Suspected collusion between two players',
        whatWentWrong: 'Two players seemed to be signaling each other and only bet heavy when both had strong hands. You noticed but didn\'t report it because you weren\'t 100% certain.',
        correctApproach: 'Report ANY suspicious behavior immediately to your supervisor. You don\'t need proof - that\'s surveillance\'s job. Better to report and be wrong than miss actual collusion. Note: exact behaviors, time, player descriptions, seat positions.',
        personalTakeaway: 'Trust your instincts on suspicious behavior. You\'re the first line of defense against cheating. Document and report - investigation is not your responsibility. Never confront suspected cheaters yourself.',
        difficultyLevel: 5,
        tags: ['collusion', 'security', 'surveillance', 'reporting'],
      ),
    ];
  }
}
