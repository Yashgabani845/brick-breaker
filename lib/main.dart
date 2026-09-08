import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/game_colors.dart';
import 'storage/game_storage.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive orientation and system UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameColors.oledDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize offline storage
  await GameStorage.instance.init();

  runApp(const BricksBreaker3DApp());
}

class BricksBreaker3DApp extends StatelessWidget {
  const BricksBreaker3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bricks Breaker 3D',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameColors.oledDark,
        primaryColor: GameColors.neonCyan,
        colorScheme: const ColorScheme.dark(
          primary: GameColors.neonCyan,
          secondary: GameColors.neonMagenta,
          surface: GameColors.spaceDark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
