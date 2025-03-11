import 'package:flutter/foundation.dart';

class TranscriptSegment {
  final String text;
  final String speaker;
  final int speakerId;
  final bool isUser;
  final String? personId;
  final double startTime;
  final double endTime;
  final DateTime timestamp;

  TranscriptSegment({
    required this.text,
    required this.speaker,
    required this.speakerId,
    required this.isUser,
    this.personId,
    required this.startTime,
    required this.endTime,
    required this.timestamp,
  });

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      text: json['text'] as String,
      speaker: json['speaker'] as String,
      speakerId: json['speaker_id'] as int,
      isUser: json['is_user'] as bool,
      personId: json['person_id'] as String?,
      startTime: (json['start'] is int) 
          ? (json['start'] as int).toDouble() 
          : json['start'] as double,
      endTime: (json['end'] is int) 
          ? (json['end'] as int).toDouble() 
          : json['end'] as double,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'speaker': speaker,
      'speaker_id': speakerId,
      'is_user': isUser,
      'person_id': personId,
      'start': startTime,
      'end': endTime,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TranscriptSegment{text: $text, speaker: $speaker, speakerId: $speakerId, startTime: $startTime, endTime: $endTime}';
  }
}
