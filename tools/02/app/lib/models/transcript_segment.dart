import 'package:flutter/foundation.dart';

class TranscriptSegment {
  final String id; // Unique identifier for the segment
  final String text;
  final String speaker;
  final int speakerId;
  final bool isUser;
  final String? personId;
  final double startTime;
  final double endTime;
  final DateTime timestamp;

  TranscriptSegment({
    String? id,
    required this.text,
    required this.speaker,
    required this.speakerId,
    required this.isUser,
    this.personId,
    required this.startTime,
    required this.endTime,
    required this.timestamp,
  }) : id = id ?? '${timestamp.millisecondsSinceEpoch}_${startTime}_$speakerId';

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    final timestamp = json['timestamp'] != null
        ? DateTime.parse(json['timestamp'])
        : DateTime.now();
    
    return TranscriptSegment(
      id: json['id'] as String?,
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
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    return 'TranscriptSegment{id: $id, text: $text, speaker: $speaker, speakerId: $speakerId, startTime: $startTime, endTime: $endTime}';
  }
}
