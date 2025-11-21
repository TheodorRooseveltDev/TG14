import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/game_rule.dart';

/// Repository for accessing game rules from the database
class GameRulesRepository {
  /// Get all game rules
  static Future<List<GameRule>> getAllRules() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_rules',
      orderBy: 'game_name ASC',
    );
    
    return List.generate(maps.length, (i) => GameRule.fromMap(maps[i]));
  }
  
  /// Get a specific game rule by ID
  static Future<GameRule?> getRuleById(String id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_rules',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return GameRule.fromMap(maps.first);
  }
  
  /// Get game rule by game name
  static Future<GameRule?> getRuleByGameName(String gameName) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_rules',
      where: 'game_name = ?',
      whereArgs: [gameName],
    );
    
    if (maps.isEmpty) return null;
    return GameRule.fromMap(maps.first);
  }
  
  /// Search game rules by keyword
  static Future<List<GameRule>> searchRules(String query) async {
    if (query.isEmpty) {
      return getAllRules();
    }
    
    final db = await DatabaseService.database;
    final searchTerm = '%${query.toLowerCase()}%';
    
    final List<Map<String, dynamic>> maps = await db.query(
      'game_rules',
      where: '''
        LOWER(game_name) LIKE ? OR 
        LOWER(overview) LIKE ? OR 
        LOWER(dealing_procedure) LIKE ? OR 
        LOWER(common_mistakes) LIKE ?
      ''',
      whereArgs: [searchTerm, searchTerm, searchTerm, searchTerm],
      orderBy: 'game_name ASC',
    );
    
    return List.generate(maps.length, (i) => GameRule.fromMap(maps[i]));
  }
  
  /// Insert or update a game rule
  static Future<void> upsertRule(GameRule rule) async {
    final db = await DatabaseService.database;
    await db.insert(
      'game_rules',
      rule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Initialize default game rules (called on first app launch)
  static Future<void> initializeDefaultRules() async {
    final existingRules = await getAllRules();
    if (existingRules.isNotEmpty) return; // Already initialized
    
    final defaultRules = _getDefaultGameRules();
    for (final rule in defaultRules) {
      await upsertRule(rule);
    }
  }
  
  /// Get default game rules for initialization
  static List<GameRule> _getDefaultGameRules() {
    return [
      GameRule(
        id: 'blackjack',
        gameName: 'Blackjack',
        overview: '''
Blackjack is a comparing card game where players compete against the dealer, not each other. The objective is to beat the dealer by getting a count as close to 21 as possible without exceeding it.

**Card Values:**
• Number cards (2-10): Face value
• Face cards (J, Q, K): 10 points
• Ace: 1 or 11 points (player's choice)

**Winning Conditions:**
• Player gets closer to 21 than dealer without busting
• Player gets 21 (Blackjack) with first two cards
• Dealer busts (goes over 21)
''',
        dealingProcedure: '''
**1. Initial Setup**
• Shuffle 6-8 decks thoroughly
• Insert cut card 1-1.5 decks from the end
• Burn top card after shuffle

**2. Betting Phase**
• Players place bets in betting circles
• Verify minimum/maximum bet limits
• No bets accepted after "no more bets" call

**3. Initial Deal**
• Deal one card face-up to each player (left to right)
• Deal one card face-up to yourself (dealer)
• Deal second card face-up to each player
• Deal second card face-down to yourself (hole card)
• Check for dealer blackjack if showing Ace or 10-value

**4. Player Decisions**
Each player in turn can:
• **Hit**: Request another card
• **Stand**: Keep current hand
• **Double Down**: Double bet, receive one card only
• **Split**: Divide pairs into two hands (matching bet)
• **Surrender**: Forfeit half bet (if available)
• **Insurance**: Bet against dealer blackjack (if dealer shows Ace)

**5. Dealer Play**
• Reveal hole card
• Must hit on 16 or less
• Must stand on 17 or more (or soft 17 per house rules)

**6. Payouts**
• Blackjack pays 3:2 (unless dealer also has blackjack)
• Regular win pays 1:1
• Insurance pays 2:1
• Push (tie) returns original bet
''',
        payoutStructure: '''
**Standard Payouts:**
• Blackjack (natural 21): 3:2 or 1.5x bet
• Regular win: 1:1 or even money
• Insurance: 2:1
• Push (tie): Return original bet

**Special Situations:**
• Surrender: Lose half bet, return half
• Both have blackjack: Push
• Player blackjack vs dealer 21: Player wins 3:2

**Side Bets (if offered):**
• Perfect Pairs: Up to 30:1
• 21+3: Up to 100:1
• Royal Match: Up to 25:1
''',
        commonMistakes: '''
• **Dealer Errors:**
  - Dealing before all bets are placed
  - Not checking for dealer blackjack with Ace/10 showing
  - Paying blackjack at even money instead of 3:2
  - Not burning a card after shuffle
  - Allowing player actions out of turn
  - Incorrect hand totaling (especially with Aces)
  - Dealing to busted hands

• **Player Confusion:**
  - Not understanding soft vs hard hands
  - Thinking they can hit after doubling down
  - Expecting to split unlike 10-value cards
  - Touching cards in face-up games
  - Not knowing when surrender is available

• **Procedural Issues:**
  - Accepting late bets
  - Not clearing cards promptly
  - Poor chip cutting/stacking
  - Slow pace affecting game flow
  - Not protecting hole card properly
''',
        houseEdge: '0.5% - 2% (varies by rules and player strategy)',
        createdAt: DateTime.now(),
      ),
      
      GameRule(
        id: 'roulette',
        gameName: 'Roulette',
        overview: '''
Roulette is a casino game where players bet on where a ball will land on a spinning wheel. The wheel has 38 pockets (American) or 37 pockets (European): numbers 1-36, plus 0 and 00 (American only).

**Bet Types:**
• **Inside Bets**: Specific numbers or small groups
• **Outside Bets**: Larger groups, colors, odd/even

**Winning:**
Players win if the ball lands on a number/color/group they bet on. Multiple bets can be placed simultaneously.
''',
        dealingProcedure: '''
**1. Opening the Game**
• Verify wheel is level and balanced
• Check all number markers and wheel pockets
• Ensure ball is regulation size and weight
• Clean wheel and layout if needed

**2. Accepting Bets**
• Announce "Place your bets" clearly
• Monitor all betting areas
• Ensure chips are placed correctly on layout
• Accept bets until ball is about to drop
• Announce "No more bets" clearly

**3. Spinning the Wheel**
• Spin wheel in one direction (typically counterclockwise)
• Launch ball in opposite direction on track
• Maintain consistent spin speed
• Watch for ball drop timing

**4. Determining the Winner**
• Call out winning number clearly: "17 black, odd"
• Place marker (dolly) on winning number
• Verify no late bets were placed
• Clear all losing bets from layout systematically

**5. Paying Winners**
• Pay inside bets first (highest payouts)
• Then pay outside bets
• Use proper chip cutting and stacking
• Double-check all payouts
• Remove marker when all bets are settled

**6. Next Spin**
• Ensure layout is clear
• Announce "Place your bets"
• Repeat cycle
''',
        payoutStructure: '''
**Inside Bets:**
• Straight Up (single number): 35:1
• Split (two numbers): 17:1
• Street (three numbers): 11:1
• Corner (four numbers): 8:1
• Six Line (six numbers): 5:1

**Outside Bets:**
• Column (12 numbers): 2:1
• Dozen (12 numbers): 2:1
• Red/Black: 1:1
• Even/Odd: 1:1
• High (19-36)/Low (1-18): 1:1

**Special Bets:**
• Basket (0, 00, 1, 2, 3): 6:1 (American only)
• First Five (0, 00, 1, 2, 3): 6:1 (worst bet)

**Example Payouts:**
• \$5 on 17 straight up wins: \$175 (\$5 × 35) + original \$5
• \$10 on red wins: \$10 + original \$10
• \$20 on corner wins: \$160 (\$20 × 8) + original \$20
''',
        commonMistakes: '''
• **Dealer Errors:**
  - Accepting bets after "no more bets" called
  - Calling wrong winning number
  - Incorrect payout calculations
  - Not placing marker on winning number immediately
  - Sweeping losing bets too quickly
  - Paying bets that should have lost
  - Poor chip cutting technique
  - Inconsistent ball spin speed

• **Timing Issues:**
  - Calling "no more bets" too early or late
  - Rushing payouts and making errors
  - Slow game pace
  - Not maintaining consistent spin intervals

• **Layout Management:**
  - Not organizing chips properly by color
  - Allowing chip stacks to obscure numbers
  - Forgetting which player placed which bet
  - Not tracking multiple same-color chip bets

• **Wheel Issues:**
  - Not checking for wheel bias
  - Inconsistent spin direction
  - Not replacing worn balls
  - Dirty wheel affecting ball action
''',
        houseEdge: 'American (00): 5.26% | European (single 0): 2.70%',
        createdAt: DateTime.now(),
      ),
      
      GameRule(
        id: 'craps',
        gameName: 'Craps',
        overview: '''
Craps is a dice game where players bet on the outcome of rolling two dice. The game has multiple betting options with different odds and payouts.

**Basic Concept:**
• Shooter rolls two dice
• Come Out Roll: First roll of a new round
• Point: Number established (4, 5, 6, 8, 9, 10)
• Pass Line wins if 7 or 11 on come out, loses on 2, 3, or 12
• Don't Pass wins opposite of Pass Line

**Game Flow:**
Come out roll → Point established → Roll until point or 7 → New come out roll
''',
        dealingProcedure: '''
**1. Table Setup**
• Verify all dice are present and regulation
• Check all betting areas are clear
• Position stick, chips, and markers properly
• Ensure on/off puck is visible

**2. Come Out Roll**
• Place puck on "OFF" side
• Offer dice to shooter
• Call "Dice are out, place your bets"
• Ensure Pass/Don't Pass bets are placed
• Call "Stick, lock it up" when betting closes
• Shooter must hit back wall with both dice

**3. Establishing the Point**
• If 7 or 11: Pass wins, Don't Pass loses, pay and clear
• If 2, 3, or 12: Pass loses, Don't Pass wins/pushes
• If 4, 5, 6, 8, 9, 10: Move puck to that number (ON side)
• Announce: "Point is [number]"

**4. Point Phase**
• Accept Come, Don't Come, and Place bets
• Shooter continues rolling
• If point number rolled: Pass wins, pay and clear
• If 7 rolled: Don't Pass wins, Pass loses
• All other numbers: Resolve Come/Place bets only

**5. Paying Bets**
• Call out result clearly
• Pay winners in proper order
• Clear losing bets
• Return puck to OFF for new come out roll

**6. Dice Control**
• Always offer 5 dice to shooter
• Inspect dice if they leave table
• Replace dice if suspicious
• Change sticks regularly
''',
        payoutStructure: '''
**Pass Line/Come:**
• Pass/Come: 1:1
• Don't Pass/Don't Come: 1:1 (push on 12)

**Odds Bets (behind the line):**
• 4 or 10: 2:1
• 5 or 9: 3:2
• 6 or 8: 6:5

**Place Bets:**
• 4 or 10: 9:5
• 5 or 9: 7:5
• 6 or 8: 7:6

**Field Bet:**
• 3, 4, 9, 10, 11: 1:1
• 2: 2:1
• 12: 3:1 (or 2:1 depending on house)

**Proposition Bets:**
• Any 7: 4:1
• Any Craps (2, 3, 12): 7:1
• Hardways:
  - Hard 4 or 10: 7:1
  - Hard 6 or 8: 9:1
• Specific numbers (2 or 12): 30:1
• Specific number (3 or 11): 15:1
''',
        commonMistakes: '''
• **Dealer Errors:**
  - Incorrect payout calculations (especially odds bets)
  - Not moving puck to correct point number
  - Paying wrong hardway bets
  - Accepting late bets after dice leave shooter's hand
  - Not calling out dice results clearly
  - Poor stick work causing dice to leave table
  - Forgetting to pay odds bets on Come bets

• **Puck Management:**
  - Leaving puck on wrong number
  - Not flipping to OFF after seven-out
  - Unclear puck position causing confusion

• **Come Bet Confusion:**
  - Not moving Come bets to point numbers
  - Paying Come bets at wrong odds
  - Forgetting odds on traveling Come bets
  - Not returning Don't Come bets properly

• **Proposition Bet Errors:**
  - Confusion between "any 7" and specific numbers
  - Wrong hardway payouts
  - Field bet payout errors on 2 and 12
  - Not booking one-roll bets correctly

• **Procedural Issues:**
  - Slow game pace
  - Poor communication with boxman
  - Not protecting the bankroll
  - Sloppy chip handling
  - Letting players touch dice with both hands
''',
        houseEdge: 'Pass Line: 1.41% | Don\'t Pass: 1.36% | Field: 2.78% - 5.56% | Any 7: 16.67%',
        createdAt: DateTime.now(),
      ),
      
      GameRule(
        id: 'baccarat',
        gameName: 'Baccarat',
        overview: '''
Baccarat is a comparing card game where players bet on which hand will win: Player, Banker, or Tie. The dealer handles all cards; players only make betting decisions.

**Card Values:**
• Ace: 1 point
• 2-9: Face value
• 10, J, Q, K: 0 points

**Hand Value:**
Sum of cards, rightmost digit only (e.g., 7+8=15, value is 5)

**Natural:**
First two cards totaling 8 or 9 (automatic win unless tie)
''',
        dealingProcedure: '''
**1. Betting Phase**
• Call "Place your bets"
• Players bet on Player, Banker, or Tie
• Accept bets until cards are ready
• Call "No more bets"

**2. Initial Deal**
• Deal cards from shoe alternating:
  - First card to Player (face down)
  - Second card to Banker (face down)
  - Third card to Player (face down)
  - Fourth card to Banker (face down)
• Slide cards under paddle until betting complete

**3. Reveal Initial Cards**
• Turn over Player hand first
• Then turn over Banker hand
• Announce totals clearly
• Check for naturals (8 or 9)

**4. Natural Check**
• If either hand has 8 or 9: Stand both hands
• Higher natural wins
• Same natural: Tie
• If natural present, no third cards drawn

**5. Third Card Rules - Player**
• Player stands on 6-7
• Player draws on 0-5
• Announce: "Player draws" or "Player stands"

**6. Third Card Rules - Banker**
Complex rules based on Banker total and Player's third card:
• 0-2: Always draw
• 3: Draw unless Player's 3rd card was 8
• 4: Draw if Player's 3rd card was 2-7
• 5: Draw if Player's 3rd card was 4-7
• 6: Draw if Player's 3rd card was 6-7
• 7: Always stand

**7. Determine Winner**
• Compare final totals
• Announce result clearly
• Pay winners, collect losing bets
• Burn one card if total is 10+ (optional rule)
''',
        payoutStructure: '''
**Standard Payouts:**
• Player bet wins: 1:1 (even money)
• Banker bet wins: 0.95:1 (1:1 minus 5% commission)
• Tie bet wins: 8:1 or 9:1 (varies by casino)

**Commission Tracking:**
• Track 5% commission on Banker wins per player
• Mark commission owed on layout
• Collect commission periodically or at shoe end
• Round half-cents down

**Side Bets (if offered):**
• Pair (Player or Banker): 11:1
• Perfect Pair: 25:1
• Either Pair: 5:1
• Big (5 or 6 cards total): 0.54:1
• Small (4 cards total): 1.5:1

**Example Payouts:**
• \$100 on Player wins: \$200 total (\$100 win + \$100 bet)
• \$100 on Banker wins: \$195 total (\$95 win + \$100 bet)
• \$10 on Tie wins (8:1): \$90 total (\$80 win + \$10 bet)
''',
        commonMistakes: '''
• **Dealer Errors:**
  - Drawing third card when natural present
  - Incorrect third card rules for Banker
  - Wrong commission calculations
  - Paying Banker bets at even money
  - Not announcing totals clearly
  - Revealing cards before betting closed
  - Burning wrong cards

• **Third Card Rule Errors:**
  - Most common: Banker 3 vs Player's 8
  - Banker 5 vs Player's 4-7 confusion
  - Drawing on Banker 7
  - Not drawing on Banker 0-2

• **Commission Issues:**
  - Forgetting to mark commission owed
  - Incorrect commission calculations
  - Not collecting commission regularly
  - Rounding errors

• **Hand Total Errors:**
  - Not dropping tens digit (e.g., calling 15 as 15 not 5)
  - Miscounting face cards as 10
  - Adding cards incorrectly

• **Procedural Problems:**
  - Accepting late bets
  - Poor shoe handling
  - Slow dealing pace
  - Not protecting cards properly
  - Burning cards at wrong times
''',
        houseEdge: 'Banker: 1.06% | Player: 1.24% | Tie: 14.36% (at 8:1)',
        createdAt: DateTime.now(),
      ),
      
      GameRule(
        id: 'texas-holdem',
        gameName: 'Texas Hold\'em Poker',
        overview: '''
Texas Hold'em is a community card poker game where players make the best 5-card hand using their 2 hole cards and 5 community cards.

**Game Structure:**
• 2-10 players per table
• Dealer button rotates clockwise
• Small blind and big blind (forced bets)
• Four betting rounds: Pre-flop, Flop, Turn, River

**Hand Rankings (highest to lowest):**
Royal Flush > Straight Flush > Four of a Kind > Full House > Flush > Straight > Three of a Kind > Two Pair > Pair > High Card
''',
        dealingProcedure: '''
**1. Pre-Game Setup**
• Shuffle cards thoroughly
• Position dealer button
• Post small blind (left of button)
• Post big blind (left of small blind)
• Verify all players have chips

**2. Pre-Flop**
• Burn top card (face down)
• Deal one card at a time to each player (2 cards total)
• Start with small blind, move clockwise
• Action starts left of big blind
• Players can: Fold, Call, Raise

**3. The Flop**
• Burn one card
• Deal three community cards face-up in center
• Betting starts left of dealer button
• Players can: Check, Bet, Fold, Call, Raise

**4. The Turn**
• Burn one card
• Deal one community card face-up (4th card)
• Betting round starts left of button
• Same actions as flop

**5. The River**
• Burn one card
• Deal one community card face-up (5th card)
• Final betting round
• Same actions as previous rounds

**6. Showdown**
• Players reveal hands
• Best 5-card hand wins
• Use any combination of 2 hole cards + 5 community cards
• Award pot to winner(s)
• Split pot if tied

**7. Next Hand**
• Move dealer button clockwise
• Collect all cards
• Shuffle and repeat
''',
        payoutStructure: '''
**Rake Structure:**
• 2.5% - 10% of pot (varies by casino)
• Maximum rake cap (e.g., \$5-\$15)
• Taken incrementally during betting rounds
• No rake if hand doesn't reach flop

**Tournament Payouts:**
Typically top 10-15% of field paid:
• 1st: 30-40% of prize pool
• 2nd: 20-25%
• 3rd: 12-15%
• 4th-9th: Decreasing percentages

**Cash Game:**
• Winner takes entire pot minus rake
• Side pots for all-in situations
• Multiple winners split pot equally

**Bad Beat Jackpot (if offered):**
• Qualifying hands (e.g., quad 8s beaten)
• Losing hand: 40-50%
• Winning hand: 25-30%
• Table share: 20-25%
• Other tables: 5-10%
''',
        commonMistakes: '''
• **Dealer Errors:**
  - Not burning cards before community cards
  - Exposing burn cards
  - Dealing too many or too few cards
  - Incorrect pot calculations
  - Awarding pot to wrong player
  - Not enforcing betting action order
  - Allowing string bets
  - Misreading hands at showdown

• **Betting Round Issues:**
  - Accepting action out of turn
  - Not enforcing minimum raises
  - Allowing verbal bets without chip follow-through
  - String bet confusion
  - Not protecting pot size count

• **Hand Reading Errors:**
  - Miscounting flushes (wrong suit)
  - Missing straights
  - Not identifying best possible hand
  - Chopping pots that shouldn't be split
  - Awarding side pots incorrectly

• **Card Protection:**
  - Not protecting muck pile
  - Exposing cards during deal
  - Allowing players to see discarded cards
  - Fouled hands not caught immediately
  - Players showing cards to each other

• **Procedural Problems:**
  - Slow dealing pace
  - Poor chip handling
  - Not managing table talk
  - Allowing excessive celebration/criticism
  - Not enforcing one-player-per-hand rule
''',
        houseEdge: 'Rake: 2.5% - 10% of pot (not house edge, but casino profit)',
        createdAt: DateTime.now(),
      ),
      
      GameRule(
        id: 'three-card-poker',
        gameName: 'Three Card Poker',
        overview: '''
Three Card Poker has two games in one: Play (against dealer) and Pair Plus (bonus bet). Players receive 3 cards and make the best poker hand.

**Hand Rankings (3-card specific):**
• Straight Flush
• Three of a Kind
• Straight
• Flush
• Pair
• High Card

Note: Straight beats flush in 3-card poker!

**Play Game:**
Player vs Dealer. Dealer needs Q-high to qualify.

**Pair Plus:**
Bonus bet pays for pair or better regardless of dealer hand.
''',
        dealingProcedure: '''
**1. Betting Phase**
• Call "Place your bets"
• Players place Ante bet (and/or Pair Plus)
• Verify minimum/maximum limits
• Call "No more bets"

**2. Initial Deal**
• Deal 3 cards face-down to each player
• Deal 3 cards face-down to yourself (dealer)
• Deal left to right, one card at a time

**3. Player Decision Phase**
• Players look at their cards
• Each player decides:
  - **Fold**: Lose Ante bet
  - **Play**: Make Play bet equal to Ante

**4. Dealer Qualification**
• Reveal dealer hand
• Check if dealer has Q-high or better
• Announce "Dealer plays" or "Dealer doesn't play"

**5. Hand Resolution**
If dealer doesn't qualify (worse than Q-high):
• Pay Ante bets 1:1
• Return Play bets (push)
• Pay Pair Plus separately

If dealer qualifies:
• Compare hands
• Higher hand wins
• Pay Ante and Play bets 1:1 if player wins
• Collect both bets if dealer wins
• Push both if tied

**6. Pair Plus Payouts**
• Always paid regardless of dealer hand
• Pay according to paytable
• Collected if player doesn't have pair+

**7. Ante Bonus**
• Automatic bonus for premium hands
• Paid even if dealer beats player:
  - Straight: 1:1
  - Three of a Kind: 4:1
  - Straight Flush: 5:1
''',
        payoutStructure: '''
**Play/Ante Bets:**
• Win: 1:1 (even money)
• Dealer doesn't qualify: Ante pays 1:1, Play pushes

**Ante Bonus (automatic):**
• Straight: 1:1
• Three of a Kind: 4:1
• Straight Flush: 5:1

**Pair Plus Paytable:**
Standard paytable:
• Pair: 1:1
• Flush: 3:1
• Straight: 6:1
• Three of a Kind: 30:1
• Straight Flush: 40:1

Alternative paytable (higher payouts):
• Pair: 1:1
• Flush: 4:1
• Straight: 6:1
• Three of a Kind: 33:1
• Straight Flush: 50:1

**Example:**
\$10 Ante + \$10 Pair Plus
Player has flush, dealer has K-high:
• Dealer doesn't qualify
• Ante wins: \$10
• Play bet: Push (returned)
• Pair Plus: \$30 (3:1 on \$10)
• Total payout: \$10 + \$30 = \$40 plus original bets
''',
        commonMistakes: '''
• **Dealer Errors:**
  - Not checking dealer qualification properly
  - Paying Play bet when dealer doesn't qualify (should push)
  - Forgetting to pay Ante Bonus
  - Wrong Pair Plus payouts
  - Paying Ante Bonus when dealer wins (should still pay)
  - Misreading 3-card hand rankings

• **Hand Ranking Confusion:**
  - Thinking flush beats straight (opposite in 3-card)
  - Not recognizing A-2-3 as straight
  - Confusing dealer qualification (Q-high minimum)

• **Ante Bonus Issues:**
  - Not paying bonus when dealer beats player
  - Paying bonus on hands that don't qualify
  - Wrong bonus amounts

• **Pair Plus Errors:**
  - Paying Pair Plus when player folded
  - Not collecting Pair Plus on losing hands
  - Wrong payout calculations
  - Confusing paytables

• **Procedural Problems:**
  - Exposing dealer cards too early
  - Allowing players to show cards to each other
  - Accepting bets after cards dealt
  - Not protecting player cards
  - Poor chip cutting on multiple payouts
''',
        houseEdge: 'Ante/Play: 3.37% | Pair Plus: 7.28% (standard) or 2.32% (alternative)',
        createdAt: DateTime.now(),
      ),
      
      GameRule(
        id: 'pai-gow-poker',
        gameName: 'Pai Gow Poker',
        overview: '''
Pai Gow Poker is a poker variation where players create two hands from 7 cards: a 5-card "high" hand and a 2-card "low" hand. The 5-card hand must rank higher than the 2-card hand.

**Objective:**
Beat both dealer hands to win. If one wins and one loses, it's a push.

**Joker Rules:**
• Can complete straights and flushes
• Otherwise counts as an Ace
• One joker in 53-card deck

**Hand Rankings:**
Standard poker rankings for 5-card hand. 2-card hand: Pair or high cards only.
''',
        dealingProcedure: '''
**1. Setup and Betting**
• Players place bets
• Dealer sets dice or uses random number generator
• Determine which seat receives first hand

**2. Dealing Cards**
• Use 53-card deck (52 + joker)
• Deal 7 cards to each player position and dealer
• Deal based on dice roll/RNG result
• Discard remaining cards

**3. Player Hand Setting**
• Players arrange 7 cards into:
  - 5-card "high" hand
  - 2-card "low" hand
• 5-card hand MUST beat 2-card hand
• Players can request "house way" assistance
• Face cards down when set

**4. Dealer Hand Setting**
• Dealer reveals all 7 cards
• Sets hand according to "house way" rules
• House way is specific formula always used

**5. Comparison**
• Reveal each player's hands
• Compare dealer's high vs player's high
• Compare dealer's low vs player's low
• Determine winner:
  - Player wins both: Player wins (pays 5% commission)
  - Dealer wins both: Dealer wins
  - Split (each wins one): Push
  - Identical hand: "Copy" - Dealer wins

**6. Payouts**
• Winning bets pay 1:1 minus 5% commission
• Push returns original bet
• Losing bets collected
• Commission tracked and collected
''',
        payoutStructure: '''
**Standard Payout:**
• Win (beat both hands): 0.95:1 (1:1 minus 5% commission)
• Push (split hands): Return bet
• Loss (dealer wins both): Lose bet

**Commission:**
• 5% on all winning bets
• Rounded to nearest \$0.25 or \$1
• Can be tracked and paid later
• Some casinos offer "no commission" with modified rules

**Bonus Bets (if offered):**
• Seven-card straight flush: 8,000:1
• Royal flush + royal match: 2,000:1
• Seven-card straight flush with joker: 1,000:1
• Five aces: 400:1
• Royal flush: 150:1
• Straight flush: 50:1
• Four of a kind: 25:1
• Full house: 5:1
• Flush: 4:1
• Three of a kind: 3:1
• Straight: 2:1

**Example Payouts:**
• \$100 bet wins: \$95 (\$100 - \$5 commission)
• \$50 bet wins: \$47.50 (\$50 - \$2.50 commission)
• \$25 bet wins: \$23.75 (\$25 - \$1.25 commission)
''',
        commonMistakes: '''
• **Dealer Errors:**
  - Not following house way strictly
  - Incorrect hand comparisons
  - Wrong commission calculations
  - Not catching player foul hands (2-card > 5-card)
  - Paying copy hands to player (dealer should win)
  - Exposing cards before all players set

• **House Way Violations:**
  - Deviating from established house way
  - Not knowing house way for complex hands
  - Setting hands differently than rulebook
  - Personal preference over house way

• **Hand Setting Errors:**
  - Not catching fouled hands (low > high)
  - Allowing players to reset after seeing dealer
  - Misreading joker (thinking it's wild for everything)
  - Not recognizing 5-ace hand with joker

• **Commission Issues:**
  - Forgetting to collect commission
  - Wrong commission amounts
  - Not tracking accumulated commission
  - Rounding errors

• **Copy Hand Confusion:**
  - Giving copy hands to player
  - Not recognizing identical hands
  - Comparing hands incorrectly

• **Procedural Problems:**
  - Wrong dealing order from dice
  - Allowing players to touch cards after setting
  - Not protecting dealer hand
  - Slow hand comparisons
  - Poor chip handling with commission
''',
        houseEdge: '2.84% (with 5% commission on wins)',
        createdAt: DateTime.now(),
      ),
      
      GameRule(
        id: 'ultimate-texas-holdem',
        gameName: 'Ultimate Texas Hold\'em',
        overview: '''
Ultimate Texas Hold'em is a heads-up poker variation where players compete against the dealer using community cards. Unlike regular poker, players can't raise the dealer out of the hand.

**Structure:**
• Player makes Ante and Blind bets (equal amounts)
• Optional Trips bonus bet
• Best 5-card hand from 2 hole cards + 5 community cards

**Betting Rounds:**
• Pre-flop: Bet 3x or 4x, or check
• After flop: Bet 2x or check
• After river: Bet 1x or fold
''',
        dealingProcedure: '''
**1. Betting Phase**
• Players place Ante and Blind bets (equal)
• Optional Trips bet
• Call "No more bets"

**2. Initial Deal**
• Deal 2 cards face-down to each player
• Deal 2 cards face-down to dealer
• Players check cards

**3. Pre-Flop Decision**
• Players can:
  - **Play 3x or 4x Ante** (no more betting later)
  - **Check** (can bet later)

**4. The Flop**
• Deal 3 community cards face-up
• If player checked pre-flop:
  - **Play 2x Ante** (no more betting)
  - **Check** (can bet after river)

**5. The River**
• Deal 2 more community cards (turn and river together)
• If player still hasn't bet:
  - **Play 1x Ante**
  - **Fold** (lose Ante and Blind)

**6. Dealer Qualification**
• Dealer reveals hand
• Needs pair or better to qualify
• If doesn't qualify:
  - Ante pushes
  - Play bet and Blind play normally

**7. Hand Resolution**
• Compare best 5-card hands
• Player wins: Pay Ante (if dealer qualified), Play, and Blind
• Dealer wins: Collect all bets
• Tie: Push Ante and Play
• Blind pays bonus for premium hands regardless of win/loss

**8. Trips Bonus**
• Pay according to paytable
• Independent of dealer hand
• Lose if player has less than three of a kind
''',
        payoutStructure: '''
**Standard Bets:**
• Ante: 1:1 (if dealer qualifies and player wins)
• Play: 1:1 (if player wins)
• Blind: Pays according to bonus schedule

**Blind Bonus Paytable:**
• Royal Flush: 500:1
• Straight Flush: 50:1
• Four of a Kind: 10:1
• Full House: 3:1
• Flush: 3:2
• Straight: 1:1
• All other: Push (return bet)

**Trips Bonus Paytable:**
• Royal Flush: 50:1
• Straight Flush: 40:1
• Four of a Kind: 30:1
• Full House: 8:1
• Flush: 6:1
• Straight: 5:1
• Three of a Kind: 3:1
• All other: Lose

**Example:**
\$10 Ante + \$10 Blind + \$5 Trips
Player has flush, bet 4x pre-flop (\$40 Play)
Dealer has pair (qualifies)
Player wins:
• Ante: \$10
• Play: \$40
• Blind: \$15 (3:2 on \$10)
• Trips: \$30 (6:1 on \$5)
Total: \$95 + original bets returned
''',
        commonMistakes: '''
• **Dealer Errors:**
  - Allowing bets after player already committed
  - Wrong Blind bonus payouts
  - Not checking dealer qualification
  - Pushing Ante when dealer qualifies
  - Collecting Blind when it should push
  - Wrong Trips payouts

• **Betting Round Confusion:**
  - Allowing 4x bet after flop
  - Allowing 3x or 2x bet after river
  - Not enforcing bet-or-fold after river
  - Letting players change bet amounts

• **Blind Bet Issues:**
  - Not paying Blind bonus when dealer wins
  - Paying Blind on straights and below (should push)
  - Wrong bonus calculations

• **Dealer Qualification:**
  - Not checking qualification properly
  - Paying Ante when dealer doesn't qualify (should push)
  - Confusing qualification rules

• **Trips Bonus:**
  - Paying Trips when player folded
  - Not collecting on losing Trips hands
  - Wrong paytable being used
  - Paying on pairs and below

• **Procedural Problems:**
  - Exposing dealer cards too early
  - Not protecting community cards
  - Slow dealing pace
  - Poor chip stacking on multiple payouts
''',
        houseEdge: 'Ante/Blind: 2.19% | Trips: 3.50% (paytable dependent)',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
