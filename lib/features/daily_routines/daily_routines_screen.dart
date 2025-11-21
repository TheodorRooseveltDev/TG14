import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/daily_routine.dart';
import '../../services/daily_routines_repository.dart';

/// Screen for managing daily routine checklists
class DailyRoutinesScreen extends StatefulWidget {
  const DailyRoutinesScreen({super.key});

  @override
  State<DailyRoutinesScreen> createState() => _DailyRoutinesScreenState();
}

class _DailyRoutinesScreenState extends State<DailyRoutinesScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<DailyRoutine> _allRoutines = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  final List<String> _categories = ['pre-shift', 'during-shift', 'post-shift'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRoutines();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadRoutines();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadRoutines();
      }
    });
  }

  Future<void> _loadRoutines() async {
    setState(() => _isLoading = true);

    try {
      final routines = await DailyRoutinesRepository.getAllRoutines();
      final stats = await DailyRoutinesRepository.getCompletionStats();
      
      setState(() {
        _allRoutines = routines;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleRoutine(DailyRoutine routine) async {
    final newStatus = !routine.isCompleted;
    await DailyRoutinesRepository.toggleCompletion(routine.id!, newStatus);
    await _loadRoutines();
  }

  Future<void> _resetAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            const Icon(Icons.refresh, color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Text(
              'Reset All Checklists?',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
          ],
        ),
        content: Text(
          'This will uncheck all items. Use this at the start of a new day.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.slateGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slateGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.cardBackground,
            ),
            child: Text(
              'Reset',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DailyRoutinesRepository.resetAllCompletions();
      await _loadRoutines();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All checklists reset!',
              style: AppTypography.bodyMedium,
            ),
            backgroundColor: AppColors.cardBackground,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsCard(),
              const SizedBox(height: 16),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                        ),
                      )
                    : _buildTabBarView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.gold,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.checklist,
              color: AppColors.gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Routines',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional dealer checklists',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gold),
            onPressed: _resetAll,
            tooltip: 'Reset all',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats.isEmpty) return const SizedBox.shrink();

    final totalCompleted = _stats['completed'] ?? 0;
    final total = _stats['total'] ?? 0;
    final percentage = _stats['percentage'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SmartCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Progress',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$totalCompleted / $total',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textOnGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total > 0 ? totalCompleted / total : 0,
                  minHeight: 8,
                  backgroundColor: AppColors.feltGreen,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$percentage% Complete',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        padding: const EdgeInsets.all(6),
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: AppColors.deepBlack,
        unselectedLabelColor: AppColors.gold,
        labelStyle: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text('🌅 Pre-Shift'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text('🎲 During'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text('🌙 Post-Shift'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: _categories.map((category) {
        final routines = _allRoutines.where((r) => r.category == category).toList();
        
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: routines.length,
          itemBuilder: (context, index) {
            return _buildRoutineCard(routines[index]);
          },
        );
      }).toList(),
    );
  }

  Widget _buildRoutineCard(DailyRoutine routine) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SmartCard(
        onTap: () => _toggleRoutine(routine),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: routine.isCompleted
                      ? AppColors.gold
                      : AppColors.feltGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: routine.isCompleted
                        ? AppColors.gold
                        : AppColors.gold.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: routine.isCompleted
                    ? const Icon(
                        Icons.check,
                        color: AppColors.feltGreen,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: routine.isCompleted
                            ? AppColors.slateGray
                            : AppColors.textOnGreen,
                        fontWeight: FontWeight.w600,
                        decoration: routine.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      routine.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.slateGray,
                        height: 1.4,
                      ),
                    ),
                    if (routine.isCompleted && routine.completedAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: AppColors.gold.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed at ${_formatTime(routine.completedAt!)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.gold.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
