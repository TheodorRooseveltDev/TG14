import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/game_rules_repository.dart';
import 'services/scenarios_repository.dart';
import 'services/daily_routines_repository.dart';
import 'services/achievements_repository.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay
  AppTheme.setSystemUIOverlay();
  
  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize database
  await DatabaseService.database;
  
  // Initialize default game rules
  await GameRulesRepository.initializeDefaultRules();
  
  // Initialize default practice scenarios
  await ScenariosRepository.initializeDefaultScenarios();
  
  // Initialize default daily routines
  await DailyRoutinesRepository.initializeDefaultRoutines();
  
  // Initialize default achievements
  await AchievementsRepository.initializeDefaultAchievements();
  
  runApp(const CasinoDealersFlowApp());
}

class CasinoDealersFlowApp extends StatelessWidget {
  const CasinoDealersFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casino Dealer\'s Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

