import 'dart:convert';

/// Represents the response from a command processing operation
class CommandResponse {
  /// The type of response
  final CommandResponseType type;
  
  /// The main content of the response
  final String content;
  
  /// Additional parameters for the response
  final Map<String, String> parameters;
  
  /// Whether the command was successful
  final bool success;
  
  /// Error message if the command failed
  final String? errorMessage;

  CommandResponse({
    required this.type,
    required this.content,
    this.parameters = const {},
    this.success = true,
    this.errorMessage,
  });

  /// Creates a successful text response
  factory CommandResponse.text(String message) {
    return CommandResponse(
      type: CommandResponseType.text,
      content: message,
    );
  }

  /// Creates an error response
  factory CommandResponse.error(String errorMessage) {
    return CommandResponse(
      type: CommandResponseType.text,
      content: '',
      success: false,
      errorMessage: errorMessage,
    );
  }

  /// Creates a grammar correction response
  factory CommandResponse.grammarCorrection(String text) {
    return CommandResponse(
      type: CommandResponseType.grammarCorrection,
      content: text,
    );
  }

  /// Creates a writing enhancement response
  factory CommandResponse.writingEnhancement(String text, String instruction) {
    return CommandResponse(
      type: CommandResponseType.writingEnhancement,
      content: text,
      parameters: {'instruction': instruction},
    );
  }

  /// Creates an auto-paste toggle response
  factory CommandResponse.autoPasteToggle(String action) {
    return CommandResponse(
      type: CommandResponseType.autoPasteToggle,
      content: action,
    );
  }

  /// Converts the response to a string format for transmission
  String toTransmissionString() {
    switch (type) {
      case CommandResponseType.grammarCorrection:
        return "GRAMMAR_CORRECTION:$content";
      case CommandResponseType.writingEnhancement:
        final encodedText = Uri.encodeComponent(content);
        final instruction = parameters['instruction'] ?? 'professional';
        return "WRITING_ENHANCEMENT:$encodedText:$instruction";
      case CommandResponseType.autoPasteToggle:
        return "AUTO_PASTE_TOGGLE:$content";
      case CommandResponseType.text:
      default:
        return content;
    }
  }

  /// Creates a response from a transmission string
  factory CommandResponse.fromTransmissionString(String transmissionString) {
    if (transmissionString.startsWith("GRAMMAR_CORRECTION:")) {
      final text = transmissionString.substring("GRAMMAR_CORRECTION:".length);
      return CommandResponse.grammarCorrection(text);
    } else if (transmissionString.startsWith("WRITING_ENHANCEMENT:")) {
      final parts = transmissionString.substring("WRITING_ENHANCEMENT:".length).split(":");
      if (parts.length >= 2) {
        final text = Uri.decodeComponent(parts[0]);
        final instruction = parts[1];
        return CommandResponse.writingEnhancement(text, instruction);
      } else {
        return CommandResponse.error("Invalid format for writing enhancement");
      }
    } else if (transmissionString.startsWith("AUTO_PASTE_TOGGLE:")) {
      final action = transmissionString.split(":")[1];
      return CommandResponse.autoPasteToggle(action);
    } else {
      return CommandResponse.text(transmissionString);
    }
  }

  /// Converts the response to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'content': content,
      'parameters': parameters,
      'success': success,
      'errorMessage': errorMessage,
    };
  }

  /// Creates a response from a JSON map
  factory CommandResponse.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = CommandResponseType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => CommandResponseType.text,
    );
    
    return CommandResponse(
      type: type,
      content: json['content'] as String,
      parameters: Map<String, String>.from(json['parameters'] as Map),
      success: json['success'] as bool,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

/// Enum representing the different types of command responses
enum CommandResponseType {
  /// Simple text response
  text,
  
  /// Grammar correction response
  grammarCorrection,
  
  /// Writing enhancement response
  writingEnhancement,
  
  /// Auto-paste toggle response
  autoPasteToggle,
}
