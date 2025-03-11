import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transcript_manager.dart';
import '../models/transcript_segment.dart';
import '../theme/nintendo_theme.dart';

class TranscriptList extends StatefulWidget {
  const TranscriptList({Key? key}) : super(key: key);

  @override
  State<TranscriptList> createState() => _TranscriptListState();
}

class _TranscriptListState extends State<TranscriptList> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_autoScroll) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptManager>(
      builder: (context, manager, child) {
        final segments = manager.segments;
        
        if (segments.isNotEmpty) {
          _scrollToBottom();
        }
        
        return Column(
          children: [
            Expanded(
              child: segments.isEmpty
                  ? const Center(
                      child: Text(
                        'No transcript data yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification) {
                          final metrics = notification.metrics;
                          setState(() {
                            _autoScroll = metrics.atEdge && metrics.pixels > 0;
                          });
                        }
                        return true;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: segments.length,
                        itemBuilder: (context, index) {
                          return _buildTranscriptItem(segments[index]);
                        },
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? NintendoTheme.nintendoDarkGray.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _autoScroll
                          ? NintendoTheme.neonBlue.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _autoScroll
                            ? NintendoTheme.neonBlue
                            : NintendoTheme.nintendoGray.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _autoScroll,
                          activeColor: NintendoTheme.neonBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _autoScroll = value ?? true;
                            });
                            if (_autoScroll) {
                              _scrollToBottom();
                            }
                          },
                        ),
                        Text(
                          'Auto-scroll',
                          style: TextStyle(
                            fontWeight: _autoScroll ? FontWeight.bold : FontWeight.normal,
                            color: _autoScroll
                                ? NintendoTheme.neonBlue
                                : Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : NintendoTheme.nintendoGray,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      backgroundColor: NintendoTheme.neonRed.withOpacity(0.1),
                      foregroundColor: NintendoTheme.neonRed,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: NintendoTheme.neonRed.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () {
                      manager.clearTranscript();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTranscriptItem(TranscriptSegment segment) {
    final timeFormat = DateFormat('HH:mm:ss');
    final formattedTime = timeFormat.format(segment.timestamp);
    
    // Format audio timestamp (start/end time)
    final audioStartTime = Duration(milliseconds: (segment.startTime * 1000).round());
    final audioStartFormatted = '${audioStartTime.inMinutes}:${(audioStartTime.inSeconds % 60).toString().padLeft(2, '0')}';
    
    // Nintendo-style colors based on speaker ID
    final List<Color> speakerColors = [
      NintendoTheme.neonRed,
      NintendoTheme.neonBlue,
      NintendoTheme.neonYellow,
      NintendoTheme.luigiGreen,
      NintendoTheme.peachPink,
      NintendoTheme.bowserOrange,
    ];
    
    final speakerColor = speakerColors[segment.speakerId % speakerColors.length];
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? NintendoTheme.nintendoDarkGray
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: speakerColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: speakerColor,
          width: 3,
        ),
        image: DecorationImage(
          image: AssetImage(
            'assets/images/nintendo_pattern_${Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light'}.png',
          ),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with speaker info and time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: speakerColor.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: speakerColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  segment.speaker,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: speakerColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: speakerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: speakerColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    'ID: ${segment.speakerId}',
                    style: TextStyle(
                      color: speakerColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: NintendoTheme.nintendoGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.headphones,
                        size: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : NintendoTheme.nintendoGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        audioStartFormatted,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : NintendoTheme.nintendoGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: NintendoTheme.nintendoGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : NintendoTheme.nintendoGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : NintendoTheme.nintendoGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Transcript text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              segment.text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
