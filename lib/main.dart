import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'data/services/supabase_service.dart';
import 'providers/games_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  // Set system UI overlay style
  AppTheme.setSystemUIOverlayStyle();
  
  // Lock to portrait mode for best casino experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SocialCasinoApp());
}

class SocialCasinoApp extends StatelessWidget {
  const SocialCasinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GamesProvider()..loadGames()),
      ],
      child: MaterialApp(
        title: 'Social Casino',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}