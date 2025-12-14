import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme/app_colors.dart';
import '../../../data/models/game_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../screens/game_detail/game_detail_screen.dart';

class PremiumGameCard extends StatefulWidget {
  final GameModel game;
  final int index;
  final bool showPlayButton;
  final double? width;
  final double? height;

  const PremiumGameCard({
    super.key,
    required this.game,
    this.index = 0,
    this.showPlayButton = true,
    this.width,
    this.height,
  });

  @override
  State<PremiumGameCard> createState() => _PremiumGameCardState();
}

class _PremiumGameCardState extends State<PremiumGameCard> {
  bool _isHovered = false;

  void _openGameDetail() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameDetailScreen(game: widget.game),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openGameDetail,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.identity()..scale(_isHovered ? 0.97 : 1.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered 
                ? AppColors.gold.withOpacity(0.6) 
                : AppColors.gold.withOpacity(0.15),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? AppColors.gold.withOpacity(0.2) 
                  : Colors.black.withOpacity(0.3),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              // Background with game image
              Positioned.fill(
                child: _buildGameImage(),
              ),
              
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.deepBlack.withOpacity(0.7),
                        AppColors.deepBlack.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Top badges
              if (widget.game.isNew || widget.game.isPopular)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildBadge(),
                ),
              
              // Bottom content
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Game name
                      Text(
                        widget.game.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Tagline
                      Text(
                        widget.game.tagline ?? widget.game.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slateGray,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.showPlayButton) ...[
                        const SizedBox(height: 12),
                        // Play Now button
                        _buildPlayButton(),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Shine effect on hover
              if (_isHovered)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.gold.withOpacity(0.1),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 50 * widget.index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildGameImage() {
    if (widget.game.imageUrl != null && widget.game.imageUrl!.isNotEmpty) {
      return Image.network(
        SupabaseService.getImageUrl(widget.game.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            AppColors.feltGreen.withOpacity(0.8),
            AppColors.darkFelt,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gold.withOpacity(0.3),
                AppColors.goldDark.withOpacity(0.2),
              ],
            ),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.casino_rounded,
            color: AppColors.gold,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.feltGreen.withOpacity(0.5),
            AppColors.darkFelt,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.gold.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    final isNew = widget.game.isNew;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNew 
              ? [AppColors.gold, AppColors.goldDark]
              : [AppColors.redVelvet, AppColors.redVelvet.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isNew ? AppColors.gold : AppColors.redVelvet).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNew ? Icons.auto_awesome : Icons.local_fire_department_rounded,
            size: 12,
            color: isNew ? AppColors.deepBlack : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            isNew ? 'NEW' : 'HOT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isNew ? AppColors.deepBlack : AppColors.textLight,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openGameDetail,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.deepBlack,
                  size: 20,
                ),
                SizedBox(width: 6),
                Text(
                  'PLAY NOW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlack,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Compact version for featured section (horizontal scroll)
class FeaturedGameCard extends StatefulWidget {
  final GameModel game;
  final int index;

  const FeaturedGameCard({
    super.key,
    required this.game,
    this.index = 0,
  });

  @override
  State<FeaturedGameCard> createState() => _FeaturedGameCardState();
}

class _FeaturedGameCardState extends State<FeaturedGameCard> {
  bool _isPressed = false;
  bool _isImageLoaded = false;

  void _openGameDetail() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameDetailScreen(game: widget.game),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openGameDetail,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isPressed 
                ? AppColors.gold.withOpacity(0.5) 
                : AppColors.gold.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed 
                  ? AppColors.gold.withOpacity(0.15) 
                  : Colors.black.withOpacity(0.3),
              blurRadius: _isPressed ? 16 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Full background image
              Positioned.fill(
                child: _buildGameImage(),
              ),
              
              // Gradient overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.deepBlack.withOpacity(0.85),
                        AppColors.deepBlack,
                      ],
                      stops: const [0.0, 0.4, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Content at bottom
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.game.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.game.tagline ?? widget.game.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gold.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Play button
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepBlack,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Badge
              if (widget.game.isNew || widget.game.isPopular)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.game.isNew 
                            ? [AppColors.gold, AppColors.goldDark]
                            : [AppColors.redVelvet, AppColors.redVelvet.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.game.isNew ? 'NEW' : 'HOT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: widget.game.isNew ? AppColors.deepBlack : AppColors.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 60 * widget.index))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.15, duration: 350.ms, curve: Curves.easeOut);
  }

  Widget _buildGameImage() {
    if (widget.game.imageUrl != null && widget.game.imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Show loader while image is loading
          if (!_isImageLoaded)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    AppColors.feltGreen,
                    AppColors.darkFelt,
                  ],
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold.withOpacity(0.6)),
                  ),
                ),
              ),
            ),
          // Actual image
          Image.network(
            SupabaseService.getImageUrl(widget.game.imageUrl),
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                // Image has loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isImageLoaded) {
                    setState(() => _isImageLoaded = true);
                  }
                });
                return child;
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        ],
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            AppColors.feltGreen,
            AppColors.darkFelt,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.casino_rounded,
          color: AppColors.gold.withOpacity(0.4),
          size: 40,
        ),
      ),
    );
  }
}
