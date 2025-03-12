import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'home_screen.dart';
import '../widgets/floating_transcript_overlay.dart';

class MainScreenWithOverlay extends StatefulWidget {
  const MainScreenWithOverlay({Key? key}) : super(key: key);

  @override
  State<MainScreenWithOverlay> createState() => _MainScreenWithOverlayState();
}

class _MainScreenWithOverlayState extends State<MainScreenWithOverlay> with WindowListener {
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main app content
          Expanded(
            child: HomeScreen(
              toggleOverlay: () {
                setState(() {
                  _showOverlay = !_showOverlay;
                });
              },
              showOverlay: _showOverlay,
            ),
          ),
          
          // Floating transcript overlay at the bottom
          if (_showOverlay)
            const FloatingTranscriptOverlay(),
        ],
      ),
    );
  }
}
