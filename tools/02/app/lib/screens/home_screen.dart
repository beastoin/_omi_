import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:provider/provider.dart';
import '../models/transcript_manager.dart';
import '../theme/nintendo_theme.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/transcript_list.dart';
import '../widgets/custom_toast.dart';
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
      
      // Auto-paste is now handled directly in the TranscriptManager
      // No need to add a listener here
    });
  }
  
  @override
  void dispose() {
    // No listener to remove
    super.dispose();
  }
  
  Future<void> _copyToClipboard(BuildContext context) async {
    final manager = Provider.of<TranscriptManager>(context, listen: false);
    final text = manager.getTranscriptText();
    
    // If there's no text to copy, return early
    if (text.isEmpty) return;
    
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMainContent(context),
          
          // Custom toast for keyword detection
          Consumer<TranscriptManager>(
            builder: (context, manager, _) {
              if (manager.errorMessage.isNotEmpty) {
                return CustomToast(
                  message: manager.errorMessage,
                  onDismiss: () {
                    // Clear the error message
                    manager.saveSettings(keywords: manager.keywords);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Recording indicator
          Consumer<TranscriptManager>(
            builder: (context, manager, _) {
              if (manager.isRecordingCommand) {
                return Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: NintendoTheme.neonRed,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'RECORDING',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent(BuildContext context) {
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
                'Omi Flow',
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
                      onPressed: () {
                        final manager = Provider.of<TranscriptManager>(context, listen: false);
                        final text = manager.getTranscriptText();
                        
                        // If there's no text to copy, return early
                        if (text.isEmpty) return;
                        
                        Clipboard.setData(ClipboardData(text: text)).then((_) {
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
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Consumer<TranscriptManager>(
                    builder: (context, manager, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? NintendoTheme.nintendoDarkGray.withOpacity(0.7)
                              : Colors.white.withOpacity(0.7),
                          boxShadow: [
                            BoxShadow(
                              color: manager.autoPaste 
                                  ? NintendoTheme.neonRed.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: manager.autoPaste 
                                ? NintendoTheme.neonRed
                                : Colors.grey.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              'Auto-Paste',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: manager.autoPaste 
                                    ? NintendoTheme.neonRed
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: manager.autoPaste,
                              onChanged: (value) {
                                manager.saveSettings(
                                  serverUrl: manager.serverUrl,
                                  autoPaste: value,
                                );
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value 
                                          ? 'Auto-paste enabled! New transcript segments will be pasted automatically.'
                                          : 'Auto-paste disabled.',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: value ? NintendoTheme.neonRed : Colors.grey,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              },
                              activeColor: NintendoTheme.neonRed,
                              activeTrackColor: NintendoTheme.neonRed.withOpacity(0.5),
                            ),
                          ],
                        ),
                      );
                    },
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
