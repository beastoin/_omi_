# \*\omi/*

## Tools

### 01 - Transcript WebSocket Server

A Go-based WebSocket server that processes and broadcasts transcript data.

### 02 - Transcript Desktop App

A Flutter desktop application that connects to the WebSocket server to receive and display real-time transcript data.

Features:
- Real-time transcript display with Nintendo-inspired UI
- Auto-paste functionality to paste new transcript segments to active applications
- Copy entire transcript to clipboard
- Connection management with auto-reconnect capability
- Configurable settings for server URL and behavior

To run the app:
```bash
cd tools/02/app
flutter run -d macos
```

For more details, see the [tools/02/README.md](tools/02/README.md) file.
