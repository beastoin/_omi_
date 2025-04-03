import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transcript_manager.dart';
import '../theme/nintendo_theme.dart';
import 'keywords_screen.dart';
import 'tools_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String? initialSection;
  
  const SettingsScreen({Key? key, this.initialSection}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _serverUrlController;
  late TextEditingController _uidController;
  late TextEditingController _apiKeyController;
  final FocusNode _apiKeyFocusNode = FocusNode();
  bool _autoReconnect = true;
  bool _keywordDetection = true;
  String _selectedModel = 'gpt-3.5-turbo';
  bool _isCustomModel = false;
  late TextEditingController _customModelController;
  
  // Available LLM models
  final List<String> _availableModels = [
    'gpt-3.5-turbo',
    'gpt-4',
    'gpt-4-turbo',
    'gpt-4o',
    'Custom...',
  ];

  @override
  void initState() {
    super.initState();
    final manager = Provider.of<TranscriptManager>(context, listen: false);
    _serverUrlController = TextEditingController(text: manager.serverUrl);
    _uidController = TextEditingController(text: manager.uid);
    _apiKeyController = TextEditingController();
    _customModelController = TextEditingController();
    _keywordDetection = manager.keywordDetection;
    
    // Check if the current model is one of our predefined ones
    final currentModel = manager.llmModel;
    if (_availableModels.contains(currentModel)) {
      _selectedModel = currentModel;
      _isCustomModel = false;
    } else {
      _selectedModel = 'Custom...';
      _customModelController.text = currentModel;
      _isCustomModel = true;
    }
    
    // If an initial section is specified, scroll to it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSection == "api_key") {
        // Focus on API key field
        _apiKeyFocusNode.requestFocus();
        
        // Show a hint to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter your OpenAI API key to continue with your command'),
            backgroundColor: NintendoTheme.neonRed,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _uidController.dispose();
    _apiKeyController.dispose();
    _customModelController.dispose();
    _apiKeyFocusNode.dispose();
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
                  
                  // API Key section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? NintendoTheme.nintendoDarkGray.withOpacity(0.7)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: NintendoTheme.luigiGreen.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: NintendoTheme.luigiGreen,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.api,
                              color: NintendoTheme.luigiGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'API Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: NintendoTheme.luigiGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _apiKeyController,
                          focusNode: _apiKeyFocusNode,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'OpenAI API Key',
                            hintText: 'Enter your OpenAI API key for grammar correction',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.luigiGreen,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.luigiGreen.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.luigiGreen,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.vpn_key,
                              color: NintendoTheme.luigiGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedModel,
                          decoration: InputDecoration(
                            labelText: 'LLM Model',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.luigiGreen,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.luigiGreen.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: NintendoTheme.luigiGreen,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.model_training,
                              color: NintendoTheme.luigiGreen,
                            ),
                          ),
                          items: _availableModels.map((String model) {
                            return DropdownMenuItem<String>(
                              value: model,
                              child: Text(model),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedModel = newValue;
                                _isCustomModel = newValue == 'Custom...';
                              });
                            }
                          },
                        ),
                        if (_isCustomModel) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _customModelController,
                            decoration: InputDecoration(
                              labelText: 'Custom Model Name',
                              hintText: 'Enter model identifier (e.g., gpt-4-32k)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: NintendoTheme.luigiGreen,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: NintendoTheme.luigiGreen.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: NintendoTheme.luigiGreen,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.edit,
                                color: NintendoTheme.luigiGreen,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Required for grammar correction tool. Your API key is stored locally and never shared.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
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
                          apiKey: _apiKeyController.text,
                          llmModel: _isCustomModel ? _customModelController.text : _selectedModel,
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
