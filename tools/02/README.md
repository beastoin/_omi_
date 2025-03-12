# Omi Transcript App

A Flutter application that connects to a WebSocket server to receive and display real-time transcript data. The app is designed with a Nintendo-inspired UI theme and provides functionality to view, copy, and paste transcript segments.

## Features

- **Real-time Transcript Display**: Connect to a WebSocket server to receive and display transcript segments in real-time.
- **Auto-Paste**: Automatically paste new transcript segments to the active application.
- **Copy to Clipboard**: Copy the entire transcript to the clipboard.
- **Paste to Active App**: Paste the transcript to the currently active application.
- **Connection Management**: Connect, disconnect, and auto-reconnect to the WebSocket server.
- **Settings Configuration**: Configure server URL, auto-reconnect, and auto-paste settings.
- **Nintendo-inspired UI**: Enjoy a visually appealing interface with Nintendo Switch-inspired colors and design elements.

## Requirements

- Flutter SDK (latest stable version recommended)
- Dart SDK (latest stable version recommended)
- macOS for running the desktop app (Windows and Linux support can be added)

## Dependencies

- `provider`: For state management
- `web_socket_channel`: For WebSocket communication
- `shared_preferences`: For storing settings
- `intl`: For date and time formatting
- `keypress_simulator`: For simulating keyboard shortcuts

## Getting Started

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd tools/02/app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

To run the app in debug mode:

```bash
flutter run -d macos
```

### Building the App

To build a release version of the app:

```bash
flutter build macos
```

The built app will be available in `build/macos/Build/Products/Release/`.

## Usage

1. **Connect to Server**: The app will automatically attempt to connect to the WebSocket server specified in the settings.
2. **View Transcripts**: Transcript segments will appear in the main view as they are received.
3. **Copy Transcript**: Click the "Copy" button to copy the entire transcript to the clipboard.
4. **Paste to Active App**: Click the "Paste to Active App" button to paste the transcript to the currently active application.
5. **Configure Settings**: Click the settings icon in the app bar to configure server URL, auto-reconnect, and auto-paste settings.

## WebSocket Server

The app expects to connect to a WebSocket server that sends transcript data in the following JSON format:

```json
{
  "segments": [
    {
      "text": "Transcript text content",
      "speaker": "Speaker Name",
      "speaker_id": 1,
      "is_user": false,
      "person_id": "optional-id",
      "start": 0.0,
      "end": 5.0,
      "timestamp": "2023-01-01T12:00:00Z"
    }
  ]
}
```

## Troubleshooting

- **Connection Issues**: Ensure the WebSocket server is running and accessible. Check the server URL in the settings.
- **Paste Functionality**: The paste functionality requires macOS permissions for accessibility. Go to System Preferences > Security & Privacy > Privacy > Accessibility and add the app to the list of allowed applications.


## Screenshots

<img width="1438" alt="Screenshot 2025-03-12 at 12 05 17" src="https://github.com/user-attachments/assets/755d3ce2-60dc-4fff-b087-78455476a7ec" />


## License

This project is licensed under the MIT License - see the LICENSE file for details.
