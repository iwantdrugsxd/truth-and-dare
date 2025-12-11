import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/undercover_provider.dart';
import 'screens/game_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const PartizoApp());
  });
}

class PartizoApp extends StatelessWidget {
  const PartizoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => UndercoverProvider()),
      ],
      child: MaterialApp(
        title: 'Partizo - Party Games',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppTheme.cyan,
          scaffoldBackgroundColor: AppTheme.background,
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.cyan,
            secondary: AppTheme.magenta,
            surface: AppTheme.cardBackground,
            background: AppTheme.background,
          ),
        ),
        home: const GameSelectionScreen(),
      ),
    );
  }
}
