import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/theme.dart';
import '../../../data/models/game.dart';

/// Game card for horizontal scroll lists
class GameCard extends StatefulWidget {
  final Game game;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: AppSpacing.gameCardWidth,
          height: AppSpacing.gameCardHeight,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.gameCardRadius,
            boxShadow: AppShadows.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Stack(
                children: [
                  Container(
                    height: AppSpacing.gameCardImageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.gold.withOpacity(0.2),
                          AppColors.feltGreen,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getGameIcon(),
                        size: 48,
                        color: AppColors.gold.withOpacity(0.5),
                      ),
                    ),
                  ),

                  // Hot badge
                  if (widget.game.isHot)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.redVelvet,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: AppShadows.redGlow,
                        ),
                        child: Text(
                          'HOT',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // New badge
                  if (widget.game.isNew && !widget.game.isHot)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEW',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.deepBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game name
                    Text(
                      widget.game.name,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.game.rating.toStringAsFixed(1),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGameIcon() {
    switch (widget.game.category) {
      case GameCategory.slots:
        return Icons.casino;
      case GameCategory.tableGames:
        return Icons.style;
      case GameCategory.diceGames:
        return Icons.casino_outlined;
      default:
        return Icons.videogame_asset;
    }
  }
}

/// Section header for game categories
class GameCategoryHeader extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback? onSeeAllTap;

  const GameCategoryHeader({
    super.key,
    required this.title,
    required this.emoji,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          if (onSeeAllTap != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSeeAllTap?.call();
              },
              child: Text(
                'See All →',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Game category horizontal scroll list
class GameCategoryList extends StatelessWidget {
  final String title;
  final String emoji;
  final List<Game> games;
  final VoidCallback? onSeeAllTap;
  final Function(Game)? onGameTap;

  const GameCategoryList({
    super.key,
    required this.title,
    required this.emoji,
    required this.games,
    this.onSeeAllTap,
    this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        GameCategoryHeader(
          title: title,
          emoji: emoji,
          onSeeAllTap: onSeeAllTap,
        ),

        const SizedBox(height: 12),

        // Games horizontal list
        SizedBox(
          height: AppSpacing.gameCardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: games.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == games.length - 1 ? 0 : 12,
                ),
                child: GameCard(
                  game: games[index],
                  onTap: () => onGameTap?.call(games[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
