# Omi Real-Time Processor - Implementation Document

## Architecture Overview

The Omi Real-Time Processor is built using a client-server architecture with the following components:

### Server-Side (Go)
- HTTP server for serving static content and handling API requests
- WebSocket hub for managing real-time connections
- Separate channels for transcript and audio data
- Audio processing utilities for format conversion

### Client-Side (JavaScript)
- WebSocket connections for real-time data reception
- Canvas-based audio visualization
- Client-side audio buffer management
- Interactive UI with Nintendo-inspired design elements

## Key Components

### 1. Connection Management
- `TranscriptHub` manages all WebSocket connections
- Separate connection pools for transcript and audio clients
- Connection tracking with metadata (UID, connection time)
- Automatic reconnection with exponential backoff

### 2. Audio Processing
- Real-time PCM audio data handling
- Client-side buffer for storing audio data
- WAV header generation for audio downloads
- Audio statistics calculation (peak, RMS)
- Waveform visualization using Canvas API

### 3. Transcript Processing
- JSON-based transcript segment handling
- Real-time display with speaker identification
- Timestamp and duration information

### 4. User Interface
- Interactive waveform displays with time markers
- Selection mechanism for audio segments
- Volume meter with dynamic color changes
- Connection status indicators
- Nintendo-style loading animation

## Data Flow

1. **Audio Processing:**
   - Client captures audio data
   - Data sent to server via POST to `/audio/process`
   - Server broadcasts to WebSocket clients on `/ws/audio`
   - Client receives and processes binary audio data
   - Visualization updated in real-time

2. **Transcript Processing:**
   - External system sends transcript data to `/transcript/process`
   - Server broadcasts to WebSocket clients on `/ws`
   - Client displays transcript segments in real-time

3. **Audio Storage and Playback:**
   - Client maintains audio buffer in memory
   - User can select segments for playback
   - Audio can be downloaded in WAV or PCM format

## Technical Implementation Details

### WebSocket Management
- Connection upgrade handled by Gorilla WebSocket library
- Client registration/unregistration via channels
- Broadcast mechanisms for different data types

### Audio Visualization
- Canvas-based waveform rendering
- Timeline with appropriate time markers
- Grid overlay for amplitude reference
- Selection overlay for segment selection

### Client-Side Storage
- In-memory audio buffer with size limits
- Conversion between binary and PCM formats
- WAV header generation for downloads

### UI Enhancements
- Nintendo-style loading animation
- Sound effects for user interactions
- Dynamic volume meter with color changes
- Responsive canvas sizing

## Future Improvements

1. Implement server-side audio processing for more advanced features
2. Add authentication for secure user identification
3. Support for more audio formats and higher quality
4. Implement audio filtering and enhancement
5. Add speech-to-text capabilities directly in the application
