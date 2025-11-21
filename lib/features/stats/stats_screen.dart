import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/widgets/xp_progress_ring.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/shift_repository.dart';
import '../../services/notes_repository.dart';
import '../../services/user_stats_repository.dart';
import '../../models/user_stats.dart';
import '../../models/shift.dart';

/// Stats Screen - Comprehensive analytics and progress tracking
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  UserStats? _userStats;
  List<Shift> _allShifts = [];
  int _totalNotes = 0;
  bool _isLoading = true;
  
  // Analytics data
  double _totalHours = 0.0;
  String? _favoriteGame;
  int _currentStreak = 0;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when app lifecycle changes (app resumes)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadData();
    }
  }

  // Called when navigating back to this screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await UserStatsRepository.getUserStats();
      final shifts = await ShiftRepository.getAllShifts();
      final notes = await NotesRepository.getAllNotes();
      final hours = await ShiftRepository.getTotalHoursWorked();
      final currentStreak = await ShiftRepository.getCurrentStreak();
      
      // Calculate favorite game from shifts
      String? favoriteGame;
      if (shifts.isNotEmpty) {
        final gameCounts = <String, int>{};
        for (final shift in shifts) {
          for (final game in shift.gamesDealt) {
            gameCounts[game] = (gameCounts[game] ?? 0) + 1;
          }
        }
        if (gameCounts.isNotEmpty) {
          favoriteGame = gameCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
        }
      }
      
      setState(() {
        _userStats = stats;
        _allShifts = shifts;
        _totalNotes = notes.length;
        _totalHours = hours;
        _favoriteGame = favoriteGame;
        _currentStreak = currentStreak;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.gold,
            backgroundColor: AppColors.cardBackground,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: AppSpacing.screenPadding,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      
                      // XP Progress Section
                      _buildXPProgressSection(),
                      
                      const SizedBox(height: 16),
                      
                      // Quick Stats Grid
                      _buildQuickStatsGrid(),
                      
                      const SizedBox(height: 16),
                      
                      // Shift Analytics
                      _buildShiftAnalytics(),
                      
                      const SizedBox(height: 16),
                      
                      // Performance Metrics
                      _buildPerformanceMetrics(),
                      
                      const SizedBox(height: 16),
                      
                      // Recent Activity
                      _buildRecentActivity(),
                      
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Your Statistics',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.gold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your progress and growth',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
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
  
  Widget _buildXPProgressSection() {
    if (_isLoading || _userStats == null) {
      return SmartCard(
        child: SizedBox(
          height: 150,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
        ),
      );
    }
    
    final progress = _userStats!.progressToNextRank;
    final nextRank = _userStats!.nextRank;
    final xpToNext = _userStats!.xpToNextRank;
    
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.gold, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Rank Progress',
                  style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                // XP Ring
                XPProgressRing(
                  progress: progress,
                  size: 100,
                  strokeWidth: 8,
                  centerText: '${(progress * 100).toInt()}%',
                ),
                const SizedBox(width: 24),
                
                // Rank Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Rank',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userStats!.currentRank,
                        style: AppTypography.displaySmall.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (nextRank != null) ...[
                        Text(
                          'Next: $nextRank',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.slateGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$xpToNext XP to go',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Max Rank Achieved!',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // XP Bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total XP Earned',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.deepBlack.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_userStats!.totalXP} XP',
                        style: AppTypography.displaySmall.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: SmartCard(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time, color: AppColors.gold, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading ? '...' : '${_allShifts.length}',
                    style: AppTypography.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Shifts',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SmartCard(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule, color: AppColors.gold, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading ? '...' : '${_totalHours.toStringAsFixed(0)}h',
                    style: AppTypography.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hours Worked',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildShiftAnalytics() {
    final avgHours = _allShifts.isEmpty ? 0.0 : _totalHours / _allShifts.length;
    
    // Calculate total wins and challenges
    int totalWins = 0;
    int totalChallenges = 0;
    for (final shift in _allShifts) {
      totalWins += shift.wins.length;
      totalChallenges += shift.challenges.length;
    }
    
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: AppColors.gold, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Shift Analytics',
                  style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticItem(
                    'Total Wins',
                    '$totalWins',
                    Icons.celebration,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticItem(
                    'Challenges',
                    '$totalChallenges',
                    Icons.warning_amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticItem(
                    'Avg Hours',
                    '${avgHours.toStringAsFixed(1)}h',
                    Icons.timelapse,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticItem(
                    'Favorite Game',
                    _favoriteGame ?? 'N/A',
                    Icons.casino,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnalyticItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.gold.withOpacity(0.6), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.slateGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.displaySmall.copyWith(
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPerformanceMetrics() {
    // Calculate average mood
    int totalMoodBefore = 0;
    int totalMoodAfter = 0;
    int moodCount = 0;
    
    for (final shift in _allShifts) {
      if (shift.moodBefore != null && shift.moodAfter != null) {
        totalMoodBefore += shift.moodBefore!;
        totalMoodAfter += shift.moodAfter!;
        moodCount++;
      }
    }
    
    final avgMoodBefore = moodCount > 0 ? totalMoodBefore / moodCount : 0.0;
    final avgMoodAfter = moodCount > 0 ? totalMoodAfter / moodCount : 0.0;
    final moodImprovement = avgMoodAfter - avgMoodBefore;
    
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.whatshot, color: AppColors.gold, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Performance',
                  style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Streak metrics
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.deepBlack.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: AppColors.gold,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_currentStreak',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current Streak',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.slateGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.deepBlack.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          moodImprovement >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: AppColors.gold,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${moodImprovement >= 0 ? '+' : ''}${moodImprovement.toStringAsFixed(1)}',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mood Change',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.slateGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Table Notes
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.deepBlack.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: AppColors.gold,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table Notes Created',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.slateGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalNotes notes',
                          style: AppTypography.displaySmall.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '+${_totalNotes * 20} XP',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    if (_allShifts.isEmpty) {
      return SmartCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: AppColors.gold.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No Activity Yet',
                style: AppTypography.cardTitle.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start logging shifts to see your activity',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Get last 5 shifts
    final recentShifts = _allShifts.take(5).toList();
    
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: AppColors.gold, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Recent Activity',
                  style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...recentShifts.map((shift) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActivityItem(shift),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityItem(Shift shift) {
    final firstGame = shift.gamesDealt.isNotEmpty ? shift.gamesDealt.first : 'N/A';
    final gamesCount = shift.gamesDealt.length;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.deepBlack.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getGameSymbol(firstGame),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gamesCount > 1 ? '$firstGame +${gamesCount - 1}' : firstGame,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(shift.date),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateGray,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (shift.moodAfter != null)
                Text(
                  _getMoodEmoji(shift.moodAfter!),
                  style: const TextStyle(fontSize: 20),
                ),
              const SizedBox(height: 2),
              Text(
                '+50 XP',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gold.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getMoodEmoji(int mood) {
    if (mood >= 9) return '🤩';
    if (mood >= 7) return '😊';
    if (mood >= 5) return '🙂';
    if (mood >= 3) return '😐';
    return '😟';
  }
  
  String _getGameSymbol(String game) {
    switch (game.toLowerCase()) {
      case 'blackjack':
        return '♠21';
      case 'roulette':
        return '⭕';
      case 'baccarat':
        return '♦B';
      case 'poker':
        return '♣P';
      case 'craps':
        return '⚀⚁';
      case 'bingo':
        return '🎱';
      case 'slots':
        return '🎰';
      case 'pai gow':
        return '🀄';
      default:
        return '🎲';
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    
    return '${date.month}/${date.day}/${date.year}';
  }
}
