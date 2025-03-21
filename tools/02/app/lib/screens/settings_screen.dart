import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transcript_manager.dart';
import '../theme/nintendo_theme.dart';
import 'keywords_screen.dart';
import 'tools_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _serverUrlController;
  late TextEditingController _uidController;
  bool _autoReconnect = true;
  bool _keywordDetection = true;

  @override
  void initState() {
    super.initState();
    final manager = Provider.of<TranscriptManager>(context, listen: false);
    _serverUrlController = TextEditingController(text: manager.serverUrl);
    _uidController = TextEditingController(text: manager.uid);
    _keywordDetection = manager.keywordDetection;
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: 24),
            SizedBox(width: 8),
            Text('Settings'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).brightness == Brightness.dark
                  ? NintendoTheme.nintendoDarkGray
                  : NintendoTheme.nintendoLightGray.withOpacity(0.7),
            ],
          ),
        ),
        child: Consumer<TranscriptManager>(
          builder: (context, manager, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Server settings section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? NintendoTheme.nintendoDarkGray.withOpacity(0.7)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: NintendoTheme.neonBlue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: NintendoTheme.neonBlue,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cloud,
                              color: NintendoTheme.neonBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'WebSocket Server',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: NintendoTheme.neonBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _serverUrlController,
                          decoration: InputDecoration(
                            labelText: 'Server URL',
                            hintText: 'ws://localhost:8099/ws',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.neonBlue,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.neonBlue.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.neonBlue,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.link,
                              color: NintendoTheme.neonBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _uidController,
                          decoration: InputDecoration(
                            labelText: 'User ID',
                            hintText: 'Enter your user ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.neonBlue,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.neonBlue.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.neonBlue,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: NintendoTheme.neonBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Connection settings section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? NintendoTheme.nintendoDarkGray.withOpacity(0.7)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: NintendoTheme.neonRed.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: NintendoTheme.neonRed,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings_applications,
                              color: NintendoTheme.neonRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Connection Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: NintendoTheme.neonRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text(
                            'Auto Reconnect',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Automatically reconnect when connection is lost',
                          ),
                          value: _autoReconnect,
                          activeColor: NintendoTheme.neonRed,
                          onChanged: (value) {
                            setState(() {
                              _autoReconnect = value;
                            });
                          },
                        ),
                        const Divider(height: 1, thickness: 1),
                        SwitchListTile(
                          title: const Text(
                            'Keyword Detection',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Show notification when keywords are detected',
                          ),
                          value: _keywordDetection,
                          activeColor: NintendoTheme.neonRed,
                          onChanged: (value) {
                            setState(() {
                              _keywordDetection = value;
                            });
                          },
                        ),
                        const Divider(height: 1, thickness: 1),
                        ListTile(
                          title: const Text(
                            'Manage Keywords',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Add or remove keyword triggers',
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: NintendoTheme.neonRed,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const KeywordsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1),
                        ListTile(
                          title: const Text(
                            'Available Tools',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'View tools that can be triggered by commands',
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: NintendoTheme.neonRed,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ToolsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Save button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: NintendoTheme.neonYellow.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        await manager.saveSettings(
                          serverUrl: _serverUrlController.text,
                          uid: _uidController.text,
                          autoReconnect: _autoReconnect,
                          keywordDetection: _keywordDetection,
                        );
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Settings saved!'),
                              backgroundColor: NintendoTheme.neonYellow,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NintendoTheme.neonYellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            NintendoTheme.neonRed,
                            NintendoTheme.neonBlue,
                          ],
                        ).createShader(bounds),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'SAVE SETTINGS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
