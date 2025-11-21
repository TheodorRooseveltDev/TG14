import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Game Icon Widget - Visual representation of casino games
class GameIcon extends StatelessWidget {
  final String gameType;
  final double size;
  final bool showLabel;
  
  static const Map<String, String> gameSymbols = {
    'blackjack': '♠21',
    'roulette': '⭕',
    'baccarat': '♦B',
    'poker': '♣P',
    'craps': '⚀⚁',
    'all': '🎰',
  };
  
  static const Map<String, String> gameLabels = {
    'blackjack': 'Blackjack',
    'roulette': 'Roulette',
    'baccarat': 'Baccarat',
    'poker': 'Poker',
    'craps': 'Craps',
    'all': 'All Games',
  };
  
  const GameIcon({
    super.key,
    required this.gameType,
    this.size = 50,
    this.showLabel = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final symbol = gameSymbols[gameType.toLowerCase()] ?? '🎰';
    final label = gameLabels[gameType.toLowerCase()] ?? gameType;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(size * 0.2),
            border: Border.all(color: AppColors.gold, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                color: AppColors.gold,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.captionText,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Game Type Chip - Compact badge for game type
class GameTypeChip extends StatelessWidget {
  final String gameType;
  
  const GameTypeChip({
    super.key,
    required this.gameType,
  });
  
  @override
  Widget build(BuildContext context) {
    final symbol = GameIcon.gameSymbols[gameType.toLowerCase()] ?? '🎰';
    final label = GameIcon.gameLabels[gameType.toLowerCase()] ?? gameType;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbol,
            style: const TextStyle(
              color: AppColors.deepBlack,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.chipLabel,
          ),
        ],
      ),
    );
  }
}
