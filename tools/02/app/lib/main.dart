import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/transcript_manager.dart';
import 'screens/home_screen.dart';
import 'theme/nintendo_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TranscriptManager(),
      child: MaterialApp(
        title: 'Omi Flow',
        theme: NintendoTheme.lightTheme,
        darkTheme: NintendoTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
