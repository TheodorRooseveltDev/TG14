import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../providers/games_provider.dart';
import '../../widgets/cards/premium_game_card.dart';
import '../../widgets/backgrounds/animated_casino_background.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedCasinoBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Games',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore our collection',
                    style: TextStyle(fontSize: 15, color: AppColors.slateGray),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            // Games grid
            Expanded(
              child: Consumer<GamesProvider>(
                builder: (context, gamesProvider, child) {
                  if (gamesProvider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  final games = gamesProvider.allGames;

                  if (games.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.casino_rounded,
                            size: 64,
                            color: AppColors.slateGray.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No games available',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.slateGray,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return FeaturedGameCard(game: game, index: index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
