import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/filled_pill_button.dart';
import '../../../../core/widgets/outline_pill_button.dart';
import '../widgets/exercise_placeholder.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_header.dart';

/// "Home 2" — warm-up stage screen.
/// Shows the exercise placeholder, warm-up/total timers and a Skip action.
class HomeWarmupScreen extends StatelessWidget {
  const HomeWarmupScreen({
    super.key,
    this.campusName = 'Campus Laguna',
    this.userName = 'Andrea',
    this.streakDays = 14,
  });

  final String campusName;
  final String userName;
  final int streakDays;

  void _handleWarmupTimer() {
    // TODO: open warm-up timer detail / start countdown.
  }

  void _handleTotalTimer() {
    // TODO: open total workout timer detail.
  }

  void _handleSkip() {
    // TODO: skip warm-up and move to the next stage.
  }

  void _handleNavTap(int index) {
    // TODO: route to the corresponding tab.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
              const ExercisePlaceholder(label: 'Calentamiento'),
              const SizedBox(height: AppSizes.sectionSpacing),
              OutlinePillButton(
                label: 'Timer calentamiento',
                onPressed: _handleWarmupTimer,
              ),
              const SizedBox(height: AppSizes.mediumSpacing),
              OutlinePillButton(
                label: 'Timer total',
                onPressed: _handleTotalTimer,
              ),
              const SizedBox(height: AppSizes.mediumSpacing),
              FilledPillButton(
                label: 'Skip',
                onPressed: _handleSkip,
                textColor: AppColors.buttonText,
              ),
              const SizedBox(height: AppSizes.mediumSpacing),
              HomeBottomNavBar(currentIndex: 1, onTap: _handleNavTap),
              const SizedBox(height: AppSizes.mediumSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
