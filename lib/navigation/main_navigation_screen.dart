import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../features/home/home_screen.dart';
import '../features/shift_log/shift_log_screen.dart';
import '../features/table_notes/table_notes_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/more/more_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  // Create screen instances once to preserve state
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const ShiftLogScreen(),
      const TableNotesScreen(),
      const StatsScreen(),
      const MoreScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
          top: BorderSide(color: AppColors.gold, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.event_note_outlined, Icons.event_note, 'Shifts'),
              _buildNavItem(2, Icons.sticky_note_2_outlined, Icons.sticky_note_2, 'Notes'),
              _buildNavItem(3, Icons.bar_chart_outlined, Icons.bar_chart, 'Stats'),
              _buildNavItem(4, Icons.more_horiz, Icons.more_horiz, 'More'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: isSelected ? AppColors.gold : AppColors.gold.withOpacity(0.5),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.captionText.copyWith(
                  color: isSelected ? AppColors.gold : AppColors.gold.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
