import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/undercover_provider.dart';
import 'providers/reveal_me_provider.dart';
import 'screens/game_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PartizoApp());
}

class PartizoApp extends StatelessWidget {
  const PartizoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => UndercoverProvider()),
        ChangeNotifierProvider(create: (_) => RevealMeProvider()),
      ],
      child: MaterialApp(
        title: 'PARTIZO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppTheme.background,
          textTheme: GoogleFonts.rajdhaniTextTheme(
            ThemeData.dark().textTheme,
          ),
          colorScheme: ColorScheme.dark(
            primary: AppTheme.cyan,
            secondary: AppTheme.magenta,
            surface: AppTheme.cardBackground,
          ),
        ),
        home: FutureBuilder<bool>(
          future: AuthService.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data == true
                ? const GameSelectionScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
