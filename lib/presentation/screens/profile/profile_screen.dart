import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(
                  color: AppColors.gold,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.gold,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Player',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textLight,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Settings
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.volume_up_outlined,
                    title: 'Sound',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingsTile(
                    icon: Icons.vibration,
                    title: 'Haptics',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.gold.withOpacity(0.1),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textLight,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.slateGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}