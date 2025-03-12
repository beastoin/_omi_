import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transcript_manager.dart';
import '../theme/nintendo_theme.dart';

class FloatingTranscriptOverlay extends StatelessWidget {
  const FloatingTranscriptOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptManager>(
      builder: (context, manager, child) {
        // Get the last few segments (most recent)
        final recentSegments = manager.segments.isNotEmpty 
            ? manager.segments.sublist(
                manager.segments.length > 3 ? manager.segments.length - 3 : 0)
            : [];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: recentSegments.isEmpty
              ? const Center(
                  child: Text(
                    'Waiting for transcript...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: recentSegments.map((segment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            if (segment.speaker.isNotEmpty)
                              TextSpan(
                                text: '[${segment.speaker}] ',
                                style: TextStyle(
                                  color: NintendoTheme.neonYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            TextSpan(
                              text: segment.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}
