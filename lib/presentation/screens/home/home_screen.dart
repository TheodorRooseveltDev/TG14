import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../providers/games_provider.dart';
import '../../widgets/cards/premium_game_card.dart';
import '../../widgets/backgrounds/animated_casino_background.dart';
import '../games/games_screen.dart';
import '../wheel/wheel_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _navigateToGames() {
    setState(() => _currentIndex = 1);
  }

  void _navigateToWheel() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeContent(
        onNavigateToGames: _navigateToGames,
        onNavigateToWheel: _navigateToWheel,
      ),
      const GamesScreen(),
      const WheelScreen(),
      const SettingsScreen(),
    ];

    return Container(
      color: AppColors.darkFelt,
      child: Stack(
        children: [
          // Content
          IndexedStack(index: _currentIndex, children: screens),
          // Top gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _PremiumNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _PremiumNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 68,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.25),
                    width: 1,
                  ),
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      isActive: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.grid_view_rounded,
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      icon: Icons.auto_awesome_rounded,
                      isActive: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.settings_rounded,
                      isActive: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: bottomPadding > 0 ? bottomPadding : 16),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        height: 54,
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: isActive
                      ? AppColors.gold
                      : AppColors.slateGray.withOpacity(0.6),
                ),
                // Active indicator dot
                if (isActive)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
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

class _HomeContent extends StatefulWidget {
  final VoidCallback? onNavigateToGames;
  final VoidCallback? onNavigateToWheel;

  const _HomeContent({
    this.onNavigateToGames,
    this.onNavigateToWheel,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final PageController _pageController = PageController(viewportFraction: 0.7, initialPage: 10000);
  Timer? _autoScrollTimer;
  int _currentPage = 10000;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final provider = context.read<GamesProvider>();
        final featuredCount = provider.featuredGames.length;
        if (featuredCount > 0) {
          _currentPage++;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Material(
      color: Colors.transparent,
      child: AnimatedCasinoBackground(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Golden glow at top - extends to actual top of screen
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150 + topPadding,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      AppColors.gold.withOpacity(0.15),
                      AppColors.gold.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Top Welcome Banner - Mysterious & Inviting
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, topPadding + 16, 0, 0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Glowing background effect - extends to top of screen
                        Positioned(
                          top: -(topPadding + 16),
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.topCenter,
                                radius: 1.2,
                                colors: [
                                  AppColors.gold.withOpacity(0.15),
                                  AppColors.gold.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Column(
                            children: [
                              // Animated sparkle dots
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSparkle(0),
                                  const SizedBox(width: 8),
                                  _buildSparkle(100),
                                  const SizedBox(width: 8),
                                  _buildSparkle(200),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Main welcome text with shimmer
                              ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        AppColors.goldLight,
                                        AppColors.gold,
                                        AppColors.goldLight,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      '✦ COME AND PLAY ✦',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .shimmer(
                                    duration: 2000.ms,
                                    color: AppColors.goldLight.withOpacity(0.3),
                                  ),
                              const SizedBox(height: 6),
                              // Sub text
                              Text(
                                'Your winning streak awaits',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textLight.withOpacity(0.5),
                                  letterSpacing: 1,
                                ),
                              ).animate().fadeIn(delay: 300.ms),
                              const SizedBox(height: 12),
                              // Decorative line
                              Container(
                                width: 60,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.gold.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ).animate().scaleX(begin: 0, delay: 400.ms),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero Section - Premium & Engaging
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.8,
                        colors: [
                          AppColors.gold.withOpacity(0.12),
                          AppColors.feltGreen.withOpacity(0.8),
                          AppColors.darkFelt,
                          AppColors.deepBlack,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: -5,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: AppColors.deepBlack.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          // Background image
                          Positioned.fill(
                            child: Image.asset(
                              'assets/icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Strong blur overlay
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                              child: Container(
                                color: AppColors.deepBlack.withOpacity(0.5),
                              ),
                            ),
                          ),
                          // Shimmer overlay effect
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.gold.withOpacity(0.08),
                                    Colors.transparent,
                                    Colors.transparent,
                                    AppColors.gold.withOpacity(0.05),
                                  ],
                                  stops: const [0.0, 0.3, 0.7, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Decorative corner accents
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  left: BorderSide(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  right: BorderSide(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  left: BorderSide(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  right: BorderSide(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Main content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 40,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decorative line
                                Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 1,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                AppColors.gold.withOpacity(0.6),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: AppColors.gold,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 40,
                                          height: 1,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.gold.withOpacity(0.6),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .scaleX(begin: 0.5),
                                const SizedBox(height: 20),
                                // Main title - LUCKY ROYALE SLOTS
                                ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.goldLight,
                                              AppColors.gold,
                                              AppColors.goldDark,
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        'LUCKY ROYALE SLOTS',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 4,
                                          height: 1,
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 300.ms)
                                    .slideY(begin: 0.2),
                                const SizedBox(height: 14),
                                // Tagline
                                Text(
                                  'Play for fun. Win for glory.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textLight.withOpacity(0.8),
                                    letterSpacing: 0.5,
                                  ),
                                ).animate().fadeIn(delay: 400.ms),
                                const SizedBox(height: 28),
                                // Play Now button - bigger and better
                                GestureDetector(
                                      onTap: widget.onNavigateToGames,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 48,
                                          vertical: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.goldLight,
                                              AppColors.gold,
                                              AppColors.goldDark,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.gold.withOpacity(
                                                0.5,
                                              ),
                                              blurRadius: 25,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 8),
                                            ),
                                            BoxShadow(
                                              color: AppColors.goldDark
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.play_circle_filled_rounded,
                                              color: AppColors.deepBlack,
                                              size: 26,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'PLAY NOW',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.deepBlack,
                                                letterSpacing: 3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 500.ms)
                                    .scale(begin: const Offset(0.8, 0.8)),
                                const SizedBox(height: 20),
                                // Stats row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildMiniStat('50+', 'Games'),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      color: AppColors.gold.withOpacity(0.3),
                                    ),
                                    _buildMiniStat('24/7', 'Fun'),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      color: AppColors.gold.withOpacity(0.3),
                                    ),
                                    _buildMiniStat('100%', 'Free'),
                                  ],
                                ).animate().fadeIn(delay: 600.ms),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Featured section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 64, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ),

                // Featured games horizontal scroll
                SliverToBoxAdapter(
                  child: Consumer<GamesProvider>(
                    builder: (context, gamesProvider, child) {
                      if (gamesProvider.isLoading) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      final featuredGames = gamesProvider.featuredGames;
                      if (featuredGames.isEmpty) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'No featured games',
                              style: TextStyle(color: AppColors.slateGray),
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 260,
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final actualIndex = index % featuredGames.length;
                            final game = featuredGames[actualIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: FeaturedGameCard(game: game, index: actualIndex),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Quick play section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: GestureDetector(
                      onTap: widget.onNavigateToWheel,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gold.withOpacity(0.15),
                            AppColors.gold.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.motion_photos_on_rounded,
                              color: AppColors.deepBlack,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Can\'t decide?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Let the wheel pick a game for you',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.slateGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.gold,
                            size: 18,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                    ),
                  ),
                ),

                // Hot Games section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hot Games',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ),

                // Hot Games horizontal scroll
                SliverToBoxAdapter(
                  child: Consumer<GamesProvider>(
                    builder: (context, gamesProvider, child) {
                      // Get games in reverse order so they're different from featured
                      final allGames = gamesProvider.allGames;
                      final hotGames = allGames.reversed.take(5).toList();
                      if (gamesProvider.isLoading || hotGames.isEmpty) {
                        return const SizedBox(height: 240);
                      }
                      return SizedBox(
                        height: 240,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: hotGames.length,
                          itemBuilder: (context, index) {
                            final game = hotGames[index];
                            return FeaturedGameCard(game: game, index: index);
                          },
                        ),
                      );
                    },
                  ),
                ),

                // New Releases section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Releases',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ),

                // New Releases horizontal scroll
                SliverToBoxAdapter(
                  child: Consumer<GamesProvider>(
                    builder: (context, gamesProvider, child) {
                      // Get games from middle of the list
                      final allGames = gamesProvider.allGames;
                      final newGames = allGames.skip(4).take(5).toList();
                      if (gamesProvider.isLoading || newGames.isEmpty) {
                        return const SizedBox(height: 240);
                      }
                      return SizedBox(
                        height: 240,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: newGames.length,
                          itemBuilder: (context, index) {
                            final game = newGames[index];
                            return FeaturedGameCard(game: game, index: index);
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Top Rated section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Rated',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ),

                // Top Rated horizontal scroll
                SliverToBoxAdapter(
                  child: Consumer<GamesProvider>(
                    builder: (context, gamesProvider, child) {
                      // Get games from second half, reversed for variety
                      final allGames = gamesProvider.allGames;
                      final halfPoint = (allGames.length / 2).floor();
                      final topGames = allGames
                          .skip(halfPoint)
                          .take(5)
                          .toList();
                      if (gamesProvider.isLoading || topGames.isEmpty) {
                        return const SizedBox(height: 240);
                      }
                      return SizedBox(
                        height: 240,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: topGames.length,
                          itemBuilder: (context, index) {
                            final game = topGames[index];
                            return FeaturedGameCard(game: game, index: index);
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textLight.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSparkle(int delayMs) {
    return Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(delay: Duration(milliseconds: delayMs))
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.2, 1.2),
          duration: 1500.ms,
          delay: Duration(milliseconds: delayMs),
        );
  }
}
