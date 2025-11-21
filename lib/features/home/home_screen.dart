import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/shift_repository.dart';
import '../../services/notes_repository.dart';
import '../../services/user_stats_repository.dart';
import '../../models/user_stats.dart';
import '../shift_log/shift_form_screen.dart';
import '../table_notes/note_editor_screen.dart';

/// Home Dashboard - Sophisticated asymmetric layout
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late AnimationController _xpAnimationController;
  late Animation<double> _xpAnimation;
  
  // Data
  UserStats? _userStats;
  int _totalShifts = 0;
  int _totalNotes = 0;
  int _currentStreak = 0;
  bool _isLoading = true;
  
  @override
  bool get wantKeepAlive => true; // Preserve state when switching tabs
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _xpAnimationController.dispose();
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
      final streak = await ShiftRepository.getCurrentStreak();
      
      setState(() {
        _userStats = stats;
        _totalShifts = shifts.length;
        _totalNotes = notes.length;
        _currentStreak = streak;
        _isLoading = false;
      });
      
      // Update XP animation with real progress
      if (_userStats != null) {
        final progress = _userStats!.progressToNextRank;
        _xpAnimation = Tween<double>(
          begin: 0.0,
          end: progress,
        ).animate(CurvedAnimation(
          parent: _xpAnimationController,
          curve: Curves.easeOutCubic,
        ));
        _xpAnimationController.forward();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }
  
  void _setupAnimations() {
    _xpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _xpAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _xpAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: [
          // Rank Badge
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Text(
                  _userStats?.currentRank ?? 'Rookie Dealer',
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.gold,
            backgroundColor: AppColors.cardBackground,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Hero Header
                SliverToBoxAdapter(
                  child: _buildHeroHeader(),
                ),
                
                // Main Content
                SliverPadding(
                  padding: AppSpacing.screenPadding,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      
                      // Stats Overview Cards
                      _buildStatsOverview(),
                      
                      const SizedBox(height: 24),
                      
                      // Quick Actions
                      _buildQuickActions(),
                      
                      const SizedBox(height: 24),
                      
                      // Recent Activity
                      _buildRecentActivity(),
                      
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const ShiftFormScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.casino, color: AppColors.deepBlack),
        label: Text(
          'New Shift',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.deepBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 8,
      ),
    );
  }
  
  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting with dramatic styling
          Text(
            'Welcome Back',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.gold.withOpacity(0.8),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dealer',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // XP Progress with dramatic styling
          AnimatedBuilder(
            animation: _xpAnimation,
            builder: (context, child) {
              final xpCurrent = _userStats?.totalXP ?? 0;
              final xpNext = _userStats?.xpToNextRank ?? 100;
              final progress = _xpAnimation.value;
              
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _userStats?.currentRank ?? 'Rookie Dealer',
                          style: AppTypography.displaySmall.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTypography.displaySmall.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.gold,
                                    AppColors.gold.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withOpacity(0.6),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$xpCurrent XP • $xpNext to next rank',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTypography.displaySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Three stat cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.work,
                label: 'Shifts',
                value: _isLoading ? '...' : '$_totalShifts',
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.notes,
                label: 'Notes',
                value: _isLoading ? '...' : '$_totalNotes',
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: _isLoading ? '...' : '$_currentStreak',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Recent Activity',
                style: AppTypography.cardTitle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.casino,
            title: 'Ready to start your shift?',
            subtitle: 'Log your first shift of the day',
            time: 'Now',
          ),
          const Divider(height: 24, color: Colors.white24),
          _buildActivityItem(
            icon: Icons.school,
            title: 'Practice scenarios available',
            subtitle: '12 training situations ready',
            time: 'Always',
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.gold, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.gold.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.displaySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Start Shift',
                Icons.play_circle_filled,
                () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShiftFormScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Add Note',
                Icons.edit_note,
                () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NoteEditorScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold,
                AppColors.gold.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.deepBlack, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.deepBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
