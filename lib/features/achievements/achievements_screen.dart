import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/achievement.dart';
import '../../services/achievements_repository.dart';

/// Screen displaying achievements and milestones
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<Achievement> _achievements = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'unlocked', 'label': 'Unlocked'},
    {'key': 'shifts', 'label': '📅 Shifts'},
    {'key': 'tips', 'label': '💰 Tips'},
    {'key': 'learning', 'label': '📚 Learning'},
    {'key': 'social', 'label': '🤝 Social'},
    {'key': 'mastery', 'label': '🏆 Mastery'},
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadAchievements();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadAchievements();
      }
    });
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final achievements = await AchievementsRepository.getAllAchievements();
      final stats = await AchievementsRepository.getAchievementStats();
      
      setState(() {
        _achievements = achievements;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Achievement> get _filteredAchievements {
    if (_selectedFilter == 'all') {
      return _achievements;
    } else if (_selectedFilter == 'unlocked') {
      return _achievements.where((a) => a.isUnlocked).toList();
    } else {
      return _achievements.where((a) => a.category == _selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg-min.jpg',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsCard(),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                        ),
                      )
                    : _buildAchievementsList(),
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
              Icons.emoji_events,
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
                  'Achievements',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your dealer milestones',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats.isEmpty) return const SizedBox.shrink();

    final unlocked = _stats['unlocked'] ?? 0;
    final total = _stats['total'] ?? 0;
    final percentage = _stats['percentage'] ?? 0;
    final totalXP = _stats['totalXP'] ?? 0;

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$unlocked / $total',
                        style: AppTypography.displaySmall.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total XP Earned',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.gold,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalXP XP',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total > 0 ? unlocked / total : 0,
                  minHeight: 8,
                  backgroundColor: AppColors.feltGreen,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
              const SizedBox(height: 8),
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

  Widget _buildFilters() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter['key'] == _selectedFilter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key']!;
                });
              },
              backgroundColor: AppColors.cardBackground,
              selectedColor: AppColors.gold.withOpacity(0.2),
              labelStyle: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.gold : AppColors.slateGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.gold
                    : AppColors.gold.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsList() {
    final filtered = _filteredAchievements;
    
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: AppColors.slateGray.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No achievements yet',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.slateGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep working to unlock achievements!',
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

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(filtered[index]);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progressPercentage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SmartCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon/Badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.gold.withOpacity(0.2)
                      : AppColors.feltGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked
                        ? AppColors.gold
                        : AppColors.gold.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _getIconData(achievement.iconName),
                        color: isUnlocked
                            ? AppColors.gold
                            : AppColors.slateGray.withOpacity(0.5),
                        size: 32,
                      ),
                    ),
                    if (!isUnlocked)
                      Center(
                        child: Icon(
                          Icons.lock,
                          color: AppColors.slateGray.withOpacity(0.7),
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isUnlocked
                                  ? AppColors.gold
                                  : AppColors.textOnGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.gold,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: AppColors.gold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+${achievement.xpReward}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      achievement.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.slateGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Progress bar
                    if (!isUnlocked) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                minHeight: 6,
                                backgroundColor: AppColors.feltGreen,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.gold.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${achievement.currentValue}/${achievement.targetValue}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.slateGray,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.gold,
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'calendar_view_week':
        return Icons.calendar_view_week;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'military_tech':
        return Icons.military_tech;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'star':
        return Icons.star;
      case 'attach_money':
        return Icons.attach_money;
      case 'payments':
        return Icons.payments;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'favorite':
        return Icons.favorite;
      case 'note_add':
        return Icons.note_add;
      case 'menu_book':
        return Icons.menu_book;
      case 'school':
        return Icons.school;
      case 'psychology':
        return Icons.psychology;
      case 'checklist':
        return Icons.checklist;
      case 'folder_special':
        return Icons.folder_special;
      case 'groups':
        return Icons.groups;
      case 'celebration':
        return Icons.celebration;
      case 'handshake':
        return Icons.handshake;
      case 'person_pin':
        return Icons.person_pin;
      case 'casino':
        return Icons.casino;
      case 'grade':
        return Icons.grade;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}
