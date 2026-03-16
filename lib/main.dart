import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AsMoviesApp());
}

class AsMoviesApp extends StatelessWidget {
  const AsMoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AsMovies',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF05060A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD5B13E),
          surface: Color(0xFF0B0E17),
        ),
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}
