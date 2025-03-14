import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transcript_manager.dart';
import '../theme/nintendo_theme.dart';
import '../tools/tool_manager.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build, size: 24),
            SizedBox(width: 8),
            Text('Available Tools'),
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
            final tools = manager.availableTools;
            
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                              Icons.info_outline,
                              color: NintendoTheme.neonBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Command Tools',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: NintendoTheme.neonBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'These tools can be triggered by voice commands. Start with a keyword like "Hey Flow" and then say a command that includes one of the trigger phrases listed below.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Example: "Hey Flow, open Discord" or "Hey Flow, go to google.com"',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tools list
                  Expanded(
                    child: Container(
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
                                Icons.build,
                                color: NintendoTheme.neonRed,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Available Tools',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: NintendoTheme.neonRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: tools.isEmpty
                                ? Center(
                                    child: Text(
                                      'No tools available',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: tools.length,
                                    itemBuilder: (context, index) {
                                      final tool = tools[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: NintendoTheme.neonRed.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: ExpansionTile(
                                          title: Text(
                                            tool.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          subtitle: Text(
                                            tool.description,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          leading: Icon(
                                            _getIconForTool(tool.name),
                                            color: NintendoTheme.neonRed,
                                          ),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Trigger Phrases:',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ...tool.triggers.map((trigger) => Padding(
                                                    padding: const EdgeInsets.only(bottom: 4),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.arrow_right, size: 16),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '"$trigger"',
                                                          style: const TextStyle(
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )).toList(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
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
  
  IconData _getIconForTool(String toolName) {
    switch (toolName.toLowerCase()) {
      case 'discord':
        return Icons.discord;
      case 'web browser':
        return Icons.public;
      case 'application':
        return Icons.apps;
      default:
        return Icons.build;
    }
  }
}
