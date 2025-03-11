import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transcript_manager.dart';
import '../theme/nintendo_theme.dart';

class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptManager>(
      builder: (context, manager, child) {
        Color color;
        IconData icon;
        String text;

        switch (manager.status) {
          case ConnectionStatus.connected:
            color = NintendoTheme.neonBlue;
            icon = Icons.check_circle;
            text = 'Connected';
            break;
          case ConnectionStatus.connecting:
            color = NintendoTheme.neonYellow;
            icon = Icons.pending;
            text = 'Connecting...';
            break;
          case ConnectionStatus.disconnected:
            color = NintendoTheme.nintendoGray;
            icon = Icons.cancel;
            text = 'Disconnected';
            break;
          case ConnectionStatus.error:
            color = NintendoTheme.neonRed;
            icon = Icons.error;
            text = 'Error: ${manager.errorMessage}';
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
