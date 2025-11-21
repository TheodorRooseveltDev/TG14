import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/user_stats_repository.dart';
import '../../services/export_service.dart';
import '../../services/import_service.dart';
import '../../services/database_service.dart';
import '../../models/user_stats.dart';
import '../game_rules/game_rules_screen.dart';
import '../scenarios/scenarios_screen.dart';
import '../daily_routines/daily_routines_screen.dart';
import '../achievements/achievements_screen.dart';
import '../tools/tip_calculator_screen.dart';
import '../tools/break_timer_screen.dart';
import '../onboarding/onboarding_screen.dart';

/// More Screen - Settings, resources, and additional features
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});
  
  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen>
    with AutomaticKeepAliveClientMixin {
  UserStats? _userStats;
  bool _isLoading = true;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await UserStatsRepository.getUserStats();
      setState(() {
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _openWebView(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WebViewScreen(url: url, title: title),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: SafeArea(
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
                    
                    // User Profile Card
                    _buildProfileCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Resources Section
                    _buildSectionHeader('Resources'),
                    const SizedBox(height: 12),
                    _buildResourcesSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Tools Section
                    _buildSectionHeader('Tools'),
                    const SizedBox(height: 12),
                    _buildToolsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Settings Section
                    _buildSectionHeader('Settings'),
                    const SizedBox(height: 12),
                    _buildSettingsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // About Section
                    _buildSectionHeader('About'),
                    const SizedBox(height: 12),
                    _buildAboutSection(),
                    
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
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
                'More',
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
                'Settings, resources, and tools',
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
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.displaySmall.copyWith(
        color: AppColors.gold,
      ),
    );
  }
  
  Widget _buildProfileCard() {
    if (_isLoading) {
      return SmartCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
        ),
      );
    }
    
    return SmartCard(
      onTap: () {
        // TODO: Navigate to profile edit
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Professional Dealer',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.gold,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _userStats?.currentRank ?? 'Rookie Dealer',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_userStats?.totalXP ?? 0} XP',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateGray,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.event_note,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_userStats?.shiftsLogged ?? 0} shifts',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Edit icon
            Icon(
              Icons.chevron_right,
              color: AppColors.gold.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResourcesSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.menu_book,
          title: 'Game Rules',
          subtitle: 'Study rules for 8 casino games',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GameRulesScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.psychology,
          title: 'Practice Scenarios',
          subtitle: 'Common situations and solutions',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScenariosScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.checklist,
          title: 'Daily Routines',
          subtitle: 'Pre-shift and post-shift checklists',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DailyRoutinesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildToolsSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.emoji_events,
          title: 'Achievements',
          subtitle: 'Track your milestones',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AchievementsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.calculate,
          title: 'Tip Calculator',
          subtitle: 'Quick tip calculations',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TipCalculatorScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.timer,
          title: 'Break Timer',
          subtitle: 'Manage your break times',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BreakTimerScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.delete_outline,
          title: 'Clear All Data',
          subtitle: 'Reset app to initial state',
          onTap: () {
            _showClearDataDialog(context);
          },
          isDestructive: true,
        ),
      ],
    );
  }
  
  Widget _buildAboutSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.info_outline,
          title: 'About Casino Dealer\'s Flow',
          subtitle: 'Version 1.0.0',
          onTap: () {
            _showAboutDialog(context);
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          subtitle: 'Your data stays on your device',
          onTap: () {
            _openWebView('https://casinodealersflow.com/privacy', 'Privacy Policy');
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.description,
          title: 'Terms & Conditions',
          subtitle: 'Terms of service',
          onTap: () {
            _openWebView('https://casinodealersflow.com/terms', 'Terms & Conditions');
          },
        ),
      ],
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return SmartCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : AppColors.gold).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red.shade300 : AppColors.gold,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDestructive ? Colors.red.shade300 : AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateGray,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.gold.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.construction, color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Text(
              'Coming Soon',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
          ],
        ),
        content: Text(
          '$feature is currently under development and will be available in a future update.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.slateGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade300, size: 28),
            const SizedBox(width: 12),
            Text(
              'Clear All Data?',
              style: AppTypography.cardTitle.copyWith(color: Colors.red.shade300),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all your shifts, notes, and progress. This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.slateGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              );
              
              // Clear all data
              await DatabaseService.reset();
              
              // Reset onboarding flag
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('onboarding_completed', false);
              
              // Close loading dialog
              if (mounted) Navigator.pop(context);
              
              // Navigate to onboarding
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Delete Everything',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.red.shade300,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        title: Column(
          children: [
            Icon(Icons.casino, color: AppColors.gold, size: 48),
            const SizedBox(height: 12),
            Text(
              'Casino Dealer\'s Flow',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slateGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'A professional tool for casino dealers to track shifts, log table notes, and improve their skills.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.slateGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '100% Offline • Premium Design • Professional Tools',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Text(
              'Privacy Policy',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '100% Offline Application',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Casino Dealer\'s Flow is completely offline. All your data stays on your device and is never transmitted anywhere.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Data Storage',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• All data is stored locally on your device using SQLite\n'
                '• No cloud sync or external servers\n'
                '• No analytics or tracking\n'
                '• No advertisements\n'
                '• No internet connection required',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Control',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have complete control over your data. Export it anytime or delete it from the app settings.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Export/Import Handlers
  Future<void> _handleExportBackup(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );

    try {
      final stats = await ExportService.getExportStats();
      Navigator.pop(context); // Close loading

      // Show confirmation with stats
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.cloud_download, color: AppColors.gold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Export Full Backup',
                style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This will create a complete backup of all your data:',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('Shifts', '${stats['shifts']}'),
              _buildStatRow('Notes', '${stats['notes']}'),
              _buildStatRow('Total XP', '${stats['xp']}'),
              const SizedBox(height: 16),
              Text(
                'The backup will be saved as a JSON file that you can share or store safely.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
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
                'Export',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        );

        await ExportService.exportFullBackup();
        
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          _showSuccessDialog(context, 'Backup Exported', 
              'Your complete backup has been exported successfully!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still showing
        _showErrorDialog(context, 'Export Failed', e.toString());
      }
    }
  }

  Future<void> _handleExportShifts(BuildContext context) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );

    try {
      final stats = await ExportService.getExportStats();
      Navigator.pop(context);

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.table_chart, color: AppColors.gold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Export Shifts',
                style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export ${stats['shifts']} shift${stats['shifts'] == 1 ? '' : 's'} as a CSV spreadsheet.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You can open this file in Excel, Numbers, or Google Sheets for analysis.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
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
                'Export',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        );

        await ExportService.exportShiftsCSV();
        
        if (context.mounted) {
          Navigator.pop(context);
          _showSuccessDialog(context, 'Shifts Exported', 
              'Your shift history has been exported to CSV!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, 'Export Failed', e.toString());
      }
    }
  }

  Future<void> _handleExportNotes(BuildContext context) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );

    try {
      final stats = await ExportService.getExportStats();
      Navigator.pop(context);

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.description, color: AppColors.gold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Export Notes',
                style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export ${stats['notes']} note${stats['notes'] == 1 ? '' : 's'} as a Markdown document.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Notes will be formatted with sections, tags, and favorites for easy reading.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
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
                'Export',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        );

        await ExportService.exportNotesMarkdown();
        
        if (context.mounted) {
          Navigator.pop(context);
          _showSuccessDialog(context, 'Notes Exported', 
              'Your table notes have been exported to Markdown!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, 'Export Failed', e.toString());
      }
    }
  }

  Future<void> _handleImportBackup(BuildContext context) async {

    try {
      // Get preview of the backup file
      final preview = await ImportService.getImportPreview();
      
      if (preview == null) {
        // User cancelled file picker
        return;
      }

      if (!context.mounted) return;

      // Show preview and confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: AppColors.gold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Import Backup',
                style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This backup contains:',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('Shifts', '${preview['totalShifts'] ?? 0}'),
              _buildStatRow('Notes', '${preview['totalNotes'] ?? 0}'),
              _buildStatRow('Total XP', '${preview['totalXP'] ?? 0}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[300], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Warning: This will replace all current data!',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.red[300],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Import',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        );

        await ImportService.importFromJSON();
        
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          
          // Refresh the stats
          await _loadData();
          
          _showSuccessDialog(context, 'Import Complete', 
              'Your data has been restored successfully!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if showing
        _showErrorDialog(context, 'Import Failed', e.toString());
      }
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.slateGray,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.slateGray,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.cardBackground,
            ),
            child: Text(
              'OK',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[300], size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(color: Colors.red[300]),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.slateGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slateGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// WebView Screen for Privacy Policy and Terms
class _WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const _WebViewScreen({required this.url, required this.title});

  @override
  State<_WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<_WebViewScreen> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
          if (_progress < 1.0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.cardBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
        ],
      ),
    );
  }
}
