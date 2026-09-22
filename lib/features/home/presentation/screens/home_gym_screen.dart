import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/filled_pill_button.dart';
import '../../../../core/widgets/outline_pill_button.dart';
import '../widgets/exercise_placeholder.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_header.dart';

/// "Home 3" — active gym/workout screen.
class HomeGymScreen extends StatelessWidget {
  const HomeGymScreen({
    super.key,
    this.campusName = 'Campus Laguna',
    this.userName = 'Andrea',
    this.streakDays = 14,
  });

  final String campusName;
  final String userName;
  final int streakDays;

  void _handleBreakTimer() {}
  void _handleTotalTimer() {}
  void _handleBreak() {}
  void _handleStop() {}
  void _handleNavTap(int index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(  // ← ESTO ES LO IMPORTANTE
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.mediumSpacing),
                HomeHeader(
                  campusName: campusName,
                  userName: userName,
                  streakDays: streakDays,
                ),
                const SizedBox(height: AppSizes.sectionSpacing),
                const ExercisePlaceholder(label: 'Gimnasio'),
                const SizedBox(height: AppSizes.sectionSpacing),
                OutlinePillButton(
                  label: 'Timer Break',
                  onPressed: _handleBreakTimer,
                ),
                const SizedBox(height: AppSizes.mediumSpacing),
                OutlinePillButton(
                  label: 'Timer total',
                  onPressed: _handleTotalTimer,
                ),
                const SizedBox(height: AppSizes.mediumSpacing),
                FilledPillButton(
                  label: 'Break',
                  onPressed: _handleBreak,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSizes.mediumSpacing),
                FilledPillButton(
                  label: 'Stop',
                  onPressed: _handleStop,
                  backgroundColor: AppColors.danger,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSizes.mediumSpacing),
                HomeBottomNavBar(currentIndex: 1, onTap: _handleNavTap),
                const SizedBox(height: AppSizes.mediumSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}