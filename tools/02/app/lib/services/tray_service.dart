import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayService with TrayListener {
  static final TrayService _instance = TrayService._internal();
  
  factory TrayService() {
    return _instance;
  }
  
  TrayService._internal();
  
  Future<void> initialize() async {
    // Initialize window manager
    await windowManager.ensureInitialized();
    
    // Add tray listener
    trayManager.addListener(this);
    
    // Set tray icon
    await _setupTrayIcon();
    
    // Set tray menu
    await _setupTrayMenu();
  }
  
  Future<void> _setupTrayIcon() async {
    try {
      if (Platform.isMacOS) {
        await trayManager.setIcon(
          'assets/images/tray_icon.png',
        );
      } else if (Platform.isWindows) {
        await trayManager.setIcon(
          'assets/images/tray_icon.ico',
        );
      } else if (Platform.isLinux) {
        await trayManager.setIcon(
          'assets/images/tray_icon.png',
        );
      }
    } catch (e) {
      print('Error setting tray icon: $e');
      // Try to set a default icon or use a system icon
      try {
        if (Platform.isMacOS) {
          await trayManager.setIcon(
            '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns',
          );
        }
      } catch (e) {
        print('Could not set fallback icon: $e');
      }
    }
  }
  
  Future<void> _setupTrayMenu() async {
    Menu menu = Menu(
      items: [
        MenuItem(
          label: 'Show',
          onClick: (_) async {
            await windowManager.show();
          },
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Exit',
          onClick: (_) async {
            await windowManager.destroy();
          },
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }
  
  // Path to the recording icon
  static const String _recordingIconPath = 'assets/images/recording_icon.png';
  // Path to the normal icon
  static const String _normalIconPath = 'assets/images/tray_icon.png';
  // Current recording state
  bool _isRecording = false;

  // Getter for recording state
  bool get isRecording => _isRecording;

  Future<void> showNotification(String title, String message) async {
    // Set tooltip with the message
    await trayManager.setToolTip(message);
    
    // Log the notification for debugging
    print('Showing notification: $title - $message');
    
    // Check if this is a recording-related notification and update icon
    if (title.contains("Recording") && !_isRecording) {
      await setRecordingIcon(true);
    } else if (title.contains("Completed") && _isRecording) {
      await setRecordingIcon(false);
    }
    
    // Use dart:io to show native notifications
    if (Platform.isMacOS) {
      try {
        // Escape quotes in the message and title to prevent script errors
        final escapedTitle = title.replaceAll('"', '\\"');
        final escapedMessage = message.replaceAll('"', '\\"');
        
        // On macOS, use osascript with sound to make the notification more noticeable
        final result = await Process.run('osascript', [
          '-e',
          'display notification "$escapedMessage" with title "$escapedTitle" sound name "Submarine"'
        ]);
        
        if (result.exitCode != 0) {
          print('Error showing notification: ${result.stderr}');
        }
      } catch (e) {
        print('Exception showing notification: $e');
        
        // Fallback to simpler notification if the first attempt fails
        try {
          await Process.run('osascript', [
            '-e',
            'display notification "Command mode active" with title "Omi Flow"'
          ]);
        } catch (e) {
          print('Fallback notification failed: $e');
        }
      }
    } else if (Platform.isWindows) {
      // On Windows, we'll just update the tooltip for now
      // A more complete solution would use a package like flutter_local_notifications
      print('Windows Notification: $title - $message');
    } else if (Platform.isLinux) {
      // On Linux, we can use notify-send if available
      try {
        await Process.run('notify-send', [title, message]);
      } catch (e) {
        print('Could not send notification: $e');
      }
    }
  }
  
  // Method to set the recording icon state
  Future<void> setRecordingIcon(bool recording) async {
    _isRecording = recording;
    
    try {
      if (recording) {
        // Use a red recording icon
        await trayManager.setIcon(
          _recordingIconPath,
          isTemplate: true
        );
      } else {
        // Use the normal icon
        await trayManager.setIcon(
          _normalIconPath,
          isTemplate: true
        );
      }
    } catch (e) {
      print('Could not update tray icon: $e');
    }
  }
  
  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }
  
  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }
  
  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    print('Menu item clicked: ${menuItem.label}');
  }
  
  void dispose() {
    trayManager.removeListener(this);
  }
}
