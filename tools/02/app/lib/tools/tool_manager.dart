import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/command_response.dart';

/// Defines the structure for a tool that can be used by the command processor
class Tool {
  final String name;
  final String description;
  final List<String> triggers;
  final Future<String> Function(String command) execute;

  Tool({
    required this.name,
    required this.description,
    required this.triggers,
    required this.execute,
  });
  
  /// Execute the tool and return a CommandResponse
  Future<CommandResponse> executeWithResponse(String command) async {
    final result = await execute(command);
    return CommandResponse.fromTransmissionString(result);
  }
}

/// Manages the available tools and processes commands to execute the appropriate tool
class ToolManager {
  final List<Tool> _tools = [];
  
  /// Register a new tool
  void registerTool(Tool tool) {
    _tools.add(tool);
  }
  
  /// Process a command and execute the appropriate tool
  Future<CommandResponse> processCommand(String command) async {
    final lowerCommand = command.toLowerCase();
    
    // Find a tool that matches the command
    for (final tool in _tools) {
      for (final trigger in tool.triggers) {
        if (lowerCommand.contains(trigger.toLowerCase())) {
          try {
            final result = await tool.execute(command);
            
            // Convert the string result to a CommandResponse object
            return CommandResponse.fromTransmissionString(result);
          } catch (e) {
            return CommandResponse.error("Error executing ${tool.name}: $e");
          }
        }
      }
    }
    
    // No matching tool found
    return CommandResponse.text("No tool found to handle this command");
  }
  
  /// Get all registered tools
  List<Tool> get tools => List.unmodifiable(_tools);
}

/// A collection of predefined tools
class PredefinedTools {
  /// Creates a tool for opening Discord
  static Tool discordTool() {
    return Tool(
      name: "Discord",
      description: "Opens the Discord application",
      triggers: ["discord", "open discord"],
      execute: (command) async {
        try {
          if (Platform.isMacOS) {
            await Process.run('open', ['-a', 'Discord']);
            return "Discord has been opened";
          } else if (Platform.isWindows) {
            await Process.run('start', ['discord://']);
            return "Discord has been opened";
          } else if (Platform.isLinux) {
            await Process.run('discord', []);
            return "Discord has been opened";
          } else {
            // Fallback to web
            final Uri url = Uri.parse('https://discord.com/app');
            if (await launchUrl(url)) {
              return "Discord web app has been opened";
            } else {
              throw 'Could not launch Discord';
            }
          }
        } catch (e) {
          return "Failed to open Discord: $e";
        }
      },
    );
  }
  
  /// Creates a tool for opening a web browser
  static Tool browserTool() {
    return Tool(
      name: "Web Browser",
      description: "Opens a web browser with the specified URL",
      triggers: ["browser", "open browser", "web", "website", "go to"],
      execute: (command) async {
        try {
          // Extract URL from command
          final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
          final match = urlRegex.firstMatch(command);
          
          String url;
          if (match != null) {
            url = match.group(0)!;
          } else {
            // Try to extract a domain
            final domainRegex = RegExp(r'(?:go to|open|visit)\s+([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})');
            final domainMatch = domainRegex.firstMatch(command);
            
            if (domainMatch != null) {
              url = 'https://${domainMatch.group(1)}';
            } else {
              return "Could not find a valid URL in the command";
            }
          }
          
          final Uri uri = Uri.parse(url);
          if (await launchUrl(uri)) {
            return "Opened $url in browser";
          } else {
            throw 'Could not launch $url';
          }
        } catch (e) {
          return "Failed to open browser: $e";
        }
      },
    );
  }
  
  /// Creates a tool for opening system applications
  static Tool appTool() {
    return Tool(
      name: "Application",
      description: "Opens a system application",
      triggers: ["open app", "launch app", "start app", "open application"],
      execute: (command) async {
        try {
          // Extract app name from command
          final appRegex = RegExp(r'(?:open|launch|start)\s+(?:app|application)?\s*([a-zA-Z0-9 ]+)');
          final match = appRegex.firstMatch(command);
          
          if (match == null) {
            return "Could not find an application name in the command";
          }
          
          final appName = match.group(1)!.trim();
          
          if (Platform.isMacOS) {
            await Process.run('open', ['-a', appName]);
            return "$appName has been opened";
          } else if (Platform.isWindows) {
            await Process.run('start', [appName]);
            return "$appName has been opened";
          } else if (Platform.isLinux) {
            await Process.run(appName.toLowerCase(), []);
            return "$appName has been opened";
          } else {
            return "Opening applications is not supported on this platform";
          }
        } catch (e) {
          return "Failed to open application: $e";
        }
      },
    );
  }
  
  /// Creates a tool for opening Telegram
  static Tool telegramTool() {
    return Tool(
      name: "Telegram",
      description: "Opens the Telegram messaging application",
      triggers: ["telegram", "open telegram", "launch telegram", "message", "chat"],
      execute: (command) async {
        try {
          if (Platform.isMacOS) {
            await Process.run('open', ['-a', 'Telegram']);
            return "Telegram has been opened";
          } else if (Platform.isWindows) {
            await Process.run('start', ['telegram://']);
            return "Telegram has been opened";
          } else if (Platform.isLinux) {
            await Process.run('telegram-desktop', []);
            return "Telegram has been opened";
          } else {
            // Fallback to web
            final Uri url = Uri.parse('https://web.telegram.org/');
            if (await launchUrl(url)) {
              return "Telegram web app has been opened";
            } else {
              throw 'Could not launch Telegram';
            }
          }
        } catch (e) {
          return "Failed to open Telegram: $e";
        }
      },
    );
  }
  
  /// Creates a tool for enhancing writing with different styles
  static Tool writingEnhancementTool() {
    return Tool(
      name: "Writing Enhancement",
      description: "Enhances selected text according to a specified style",
      triggers: ["enhance my writing", "enhance writing", "improve writing", "rewrite", "make it more"],
      execute: (command) async {
        try {
          // First, simulate Cmd+C to copy the selected text
          await keyPressSimulator.simulateKeyDown(
            PhysicalKeyboardKey.keyC,
            [ModifierKey.metaModifier],
          );

          await keyPressSimulator.simulateKeyUp(
            PhysicalKeyboardKey.keyC,
            [ModifierKey.metaModifier],
          );
          
          // Small delay to ensure the clipboard has been updated
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Now get text from clipboard
          final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
          final text = clipboardData?.text;
          
          if (text == null || text.isEmpty) {
            return "No text selected to enhance. Please select text first.";
          }
          
          // Extract the instruction from the command
          String instruction = "professional";  // Default instruction
          
          // Look for instruction after the trigger words
          final lowerCommand = command.toLowerCase();
          for (final trigger in ["enhance my writing", "enhance writing", "improve writing", "rewrite", "make it more"]) {
            if (lowerCommand.contains(trigger)) {
              final index = lowerCommand.indexOf(trigger) + trigger.length;
              if (index < lowerCommand.length) {
                final remainingText = lowerCommand.substring(index).trim();
                if (remainingText.isNotEmpty) {
                  instruction = remainingText;
                }
              }
              break;
            }
          }
          
          // Format the return value for the TranscriptManager to process
          // Ensure we're using a format that won't break when splitting by colon
          // by encoding the text if it might contain colons
          final encodedText = Uri.encodeComponent(text);
          return "WRITING_ENHANCEMENT:$encodedText:$instruction";
        } catch (e) {
          return "Failed to enhance writing: $e";
        }
      },
    );
  }

  /// Creates a tool for grammar correction
  static Tool grammarCorrectionTool() {
    return Tool(
      name: "Grammar Correction",
      description: "Corrects grammar, spelling, and punctuation in selected text",
      triggers: ["correct me", "fix grammar", "grammar check", "correct grammar", "fix my text"],
      execute: (command) async {
        try {
          // First, simulate Cmd+C to copy the selected text
          await keyPressSimulator.simulateKeyDown(
            PhysicalKeyboardKey.keyC,
            [ModifierKey.metaModifier],
          );

          await keyPressSimulator.simulateKeyUp(
            PhysicalKeyboardKey.keyC,
            [ModifierKey.metaModifier],
          );
          
          // Small delay to ensure the clipboard has been updated
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Now get text from clipboard
          final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
          final text = clipboardData?.text;
          
          if (text == null || text.isEmpty) {
            return "No text selected to correct. Please select text first.";
          }
          
          // This will be implemented in the TranscriptManager
          return "GRAMMAR_CORRECTION:$text";
        } catch (e) {
          return "Failed to correct grammar: $e";
        }
      },
    );
  }

  /// Creates a tool for toggling auto-paste feature
  static Tool autoPasteToggleTool() {
    return Tool(
      name: "Auto-Paste Toggle",
      description: "Toggles the auto-paste feature on or off",
      triggers: ["toggle auto paste", "auto paste", "toggle paste", "turn on auto paste", "turn off auto paste"],
      execute: (command) async {
        try {
          // This tool requires access to the TranscriptManager which will be provided at runtime
          // The actual toggling is done in the TranscriptManager class
          final lowerCommand = command.toLowerCase();
          
          if (lowerCommand.contains("on") || lowerCommand.contains("enable")) {
            return "AUTO_PASTE_TOGGLE:ON";
          } else if (lowerCommand.contains("off") || lowerCommand.contains("disable")) {
            return "AUTO_PASTE_TOGGLE:OFF";
          } else {
            return "AUTO_PASTE_TOGGLE:TOGGLE";
          }
        } catch (e) {
          return "Failed to toggle auto-paste: $e";
        }
      },
    );
  }

  /// Register all predefined tools with the tool manager
  static void registerAll(ToolManager manager) {
    manager.registerTool(discordTool());
    manager.registerTool(browserTool());
    manager.registerTool(appTool());
    manager.registerTool(telegramTool());
    manager.registerTool(autoPasteToggleTool());
    manager.registerTool(grammarCorrectionTool());
    manager.registerTool(writingEnhancementTool());
  }
}
