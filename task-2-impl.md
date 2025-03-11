# Omi Transcript Desktop App - Implementation Document

## Architecture Overview

The Omi Transcript Desktop App is built using Flutter for desktop with the following components:

### Core Components
- **WebSocket Client**: Connects to the backend WebSocket server to receive real-time transcript data
- **Transcript Manager**: Processes and stores transcript segments
- **UI Layer**: Displays transcript data and provides user controls
- **Keypress Simulator**: Enables pasting text to other applications

## Technical Implementation Details

### 1. Project Setup
- Flutter desktop application targeting macOS
- Dependencies:
  - `web_socket_channel`: For WebSocket communication
  - `keypress_simulator`: For simulating keyboard shortcuts
  - `provider`: For state management

### 2. WebSocket Connection
- Connect to `/ws` endpoint with UID parameter
- Handle connection lifecycle (connect, disconnect, reconnect)
- Process incoming JSON transcript data
- Implement error handling and reconnection logic

### 3. Transcript Management
- Store transcript segments in a list
- Process incoming segments and update UI
- Implement selection of transcript segments
- Format transcript data for display

### 4. UI Implementation
- Main transcript display area with scrollable list
- Connection status indicator
- Controls for selecting and pasting text
- Settings for WebSocket server configuration

### 5. Paste Functionality
- Select transcript text to paste
- Use keypress_simulator to simulate Command+V
- Implement paste button and keyboard shortcuts

## Data Flow
1. Application connects to WebSocket server
2. Server sends transcript segments as JSON
3. App processes and displays transcript segments
4. User selects text and triggers paste function
5. App simulates keyboard shortcuts to paste text in the active application

## Error Handling
- Connection failures with automatic retry
- Invalid data handling
- UI feedback for connection status

## Future Improvements
- Support for audio streaming
- Transcript search functionality
- Custom styling options
- Support for additional platforms
