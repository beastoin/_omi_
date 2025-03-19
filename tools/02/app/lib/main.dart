import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'models/transcript_manager.dart';
import 'screens/home_screen.dart';
import 'theme/nintendo_theme.dart';
import 'services/tray_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager with proper options
  await windowManager.ensureInitialized();
  
  // Configure window manager
  await windowManager.setPreventClose(true);
  await windowManager.setTitle('Omi Flow');
  
  // Initialize tray service
  await TrayService().initialize();
  
  // Test notification on startup
  await Future.delayed(const Duration(seconds: 2), () {
    TrayService().showNotification('Omi Flow Started', 'Application is ready to use');
  });
  
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
