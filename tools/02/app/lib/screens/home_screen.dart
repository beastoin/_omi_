import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:provider/provider.dart';
import '../models/transcript_manager.dart';
import '../theme/nintendo_theme.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/transcript_list.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPasting = false;

  @override
  void initState() {
    super.initState();
    // Connect to WebSocket when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final manager = Provider.of<TranscriptManager>(context, listen: false);
      manager.connect();
    });
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final manager = Provider.of<TranscriptManager>(context, listen: false);
    final text = manager.getTranscriptText();
    
    await Clipboard.setData(ClipboardData(text: text));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transcript copied to clipboard!'),
          duration: const Duration(seconds: 2),
          backgroundColor: NintendoTheme.neonBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }

  Future<void> _pasteToActiveApp(BuildContext context) async {
    if (_isPasting) return;
    
    setState(() {
      _isPasting = true;
    });
    
    try {
      // First copy to clipboard
      await _copyToClipboard(context);
      
      // Then simulate Cmd+V keystroke
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
      
      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pasted to active application!'),
            duration: const Duration(seconds: 2),
            backgroundColor: NintendoTheme.neonRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to paste: $e'),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isPasting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, size: 28),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  NintendoTheme.neonRed,
                  NintendoTheme.neonYellow,
                  NintendoTheme.neonBlue,
                ],
              ).createShader(bounds),
              child: const Text(
                'Omi Transcript',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<TranscriptManager>(
            builder: (context, manager, child) {
              return IconButton(
                icon: Icon(
                  manager.isConnected ? Icons.link : Icons.link_off,
                  color: manager.isConnected ? NintendoTheme.neonYellow : Colors.white70,
                ),
                onPressed: () {
                  if (manager.isConnected) {
                    manager.disconnect();
                  } else {
                    manager.connect();
                  }
                },
                tooltip: manager.isConnected ? 'Disconnect' : 'Connect',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    NintendoTheme.nintendoDarkGray,
                    NintendoTheme.neonBlue.withOpacity(0.1),
                    NintendoTheme.nintendoDarkGray,
                  ]
                : [
                    NintendoTheme.nintendoLightGray,
                    Colors.white,
                    NintendoTheme.neonRed.withOpacity(0.05),
                  ],
          ),
          image: DecorationImage(
            image: AssetImage(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/nintendo_pattern_dark.png'
                  : 'assets/images/nintendo_pattern_light.png',
            ),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? NintendoTheme.nintendoDarkGray.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const ConnectionStatusWidget(),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: NintendoTheme.neonBlue.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                      style: TextButton.styleFrom(
                        foregroundColor: NintendoTheme.neonBlue,
                        backgroundColor: NintendoTheme.neonBlue.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: NintendoTheme.neonBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () => _copyToClipboard(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: NintendoTheme.neonRed.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: _isPasting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.paste, size: 24),
                      label: const Text(
                        'Paste to Active App',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NintendoTheme.neonRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _isPasting ? null : () => _pasteToActiveApp(context),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 2),
            const Expanded(
              child: TranscriptList(),
            ),
          ],
        ),
      ),
    );
  }
}
