import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../game_play/game_play_screen.dart';
import '../../../data/models/game_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../widgets/backgrounds/animated_casino_background.dart';

class GameDetailScreen extends StatelessWidget {
  final GameModel game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkFelt,
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: AnimatedCasinoBackground(
              child: const SizedBox.expand(),
            ),
          ),
          // Content
          CustomScrollView(
            slivers: [
              // Banner with back button and game info
              SliverToBoxAdapter(
                child: _buildBannerSection(context),
              ),
              // Content
              SliverToBoxAdapter(
                child: _buildContent(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection(BuildContext context) {
    final bannerPath = game.bannerImage;
    
    return Stack(
      children: [
        // Banner image
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
          ),
          child: bannerPath != null
              ? Image.network(
                  SupabaseService.getImageUrl(bannerPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.feltGreen,
                            AppColors.darkFelt,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.casino,
                          size: 80,
                          color: AppColors.gold.withOpacity(0.5),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.feltGreen,
                        AppColors.darkFelt,
                      ],
                    ),
                  ),
                ),
        ),
        // Gradient overlay
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.darkFelt.withOpacity(0.3),
                AppColors.darkFelt,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.deepBlack.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textLight,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Game icon overlay at bottom of banner
        Positioned(
          bottom: 0,
          left: 20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepBlack.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: game.imageUrl != null
                ? Image.network(
                    SupabaseService.getImageUrl(game.imageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.feltGreen,
                        child: Icon(
                          Icons.casino,
                          color: AppColors.gold,
                          size: 50,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.feltGreen,
                    child: Icon(
                      Icons.casino,
                      color: AppColors.gold,
                      size: 50,
                    ),
                  ),
          ),
        ),
        // Game title and tagline
        Positioned(
          bottom: 20,
          left: 136,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.name,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: AppColors.deepBlack,
                      blurRadius: 10,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                game.tagline ?? '',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: AppColors.deepBlack,
                      blurRadius: 10,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badges row
        if (game.isFeatured || game.isNew || game.isPopular)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                if (game.isFeatured) _buildBadge('⭐ Featured', AppColors.gold),
                if (game.isNew) ...[
                  if (game.isFeatured) const SizedBox(width: 8),
                  _buildBadge('🆕 New', AppColors.successGreen),
                ],
                if (game.isPopular) ...[
                  if (game.isFeatured || game.isNew) const SizedBox(width: 8),
                  _buildBadge('🔥 Popular', AppColors.redVelvet),
                ],
              ],
            ),
          ),
        
        // Play button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _buildPlayButton(context),
        ),
        
        const SizedBox(height: 24),
        
        // About section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionCard(
            title: 'About This Game',
            child: Text(
              game.description ?? 'No description available.',
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.85),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ),
        
        // Screenshots section - NO horizontal padding so it touches edges
        if (game.screenshots.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildScreenshotsSection(),
        ],
        
        const SizedBox(height: 20),
        
        // Game info section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionCard(
            title: 'Game Info',
            child: Column(
              children: [
                _buildInfoRow('Category', 'Slot Machine', Icons.category_rounded),
                Divider(color: AppColors.slateGray.withOpacity(0.3), height: 20),
                _buildInfoRow('Type', 'Video Slots', Icons.videogame_asset_rounded),
                Divider(color: AppColors.slateGray.withOpacity(0.3), height: 20),
                _buildInfoRow('Platform', 'iOS, Android, Web', Icons.devices_rounded),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Age rating disclaimer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'These games are intended for an adult audience (18+) and does not offer real money gambling or an opportunity to win real money prizes.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight.withOpacity(0.5),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 100), // Space for bottom nav
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (game.apiUrl != null && game.apiUrl!.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamePlayScreen(game: game),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold,
              AppColors.goldDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.goldLight.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.goldDark.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_filled_rounded,
              color: AppColors.deepBlack,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              'Play Now',
              style: TextStyle(
                color: AppColors.deepBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 12),
          child: Text(
            'Screenshots',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: game.screenshots.length,
            itemBuilder: (context, index) {
              String screenshotPath = game.screenshots[index];
              // Clean path
              if (screenshotPath.startsWith('/assets/')) {
                screenshotPath = screenshotPath.substring(8);
              } else if (screenshotPath.startsWith('/')) {
                screenshotPath = screenshotPath.substring(1);
              }
              
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index < game.screenshots.length - 1 ? 12 : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepBlack.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  SupabaseService.getImageUrl(screenshotPath),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.cardBackground,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.gold,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.cardBackground,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: AppColors.textLight.withOpacity(0.3),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Screenshot ${index + 1}',
                            style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.gold,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
