import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Lock to portrait mode
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
    return MaterialApp(
      title: 'Partizo - Truth or Dare',
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
      home: const Scaffold(
        body: Center(
          child: Text(
            'PARTIZO',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
