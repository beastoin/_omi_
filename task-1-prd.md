# Omi Real-Time Processor - Project Requirements Document

## Overview
Omi is a real-time audio and transcript processing system designed to capture, process, and visualize audio streams and their corresponding transcripts in real-time.

## Core Requirements

### 1. User Identification
- Each user must have a unique identifier (UID)
- System must support multiple concurrent users
- If no UID is provided, generate a random one and redirect

### 2. Real-Time Transcript Processing
- Receive and display transcript segments in real-time
- Support multiple speakers with distinct visual identifiers
- Display timing information for each segment
- Maintain connection status and reconnect automatically if disconnected

### 3. Real-Time Audio Processing
- Capture and stream audio data in real-time
- Display waveform visualization of incoming audio
- Show audio statistics (sample rate, channels, peak values, RMS)
- Support automatic reconnection if connection is lost
- Track and display connection duration

### 4. Audio Storage and Playback
- Store audio data on the client side
- Allow playback of stored audio
- Support selection of specific audio segments
- Enable downloading of audio in different formats (WAV, PCM)
- Provide auto-load functionality to periodically refresh stored audio

### 5. User Interface
- Nintendo-inspired design with appropriate animations and sound effects
- Responsive layout that adapts to different screen sizes
- Clear status indicators for all connections
- Interactive waveform displays with time markers
- Volume meter with color indicators based on audio levels

### 6. Technical Requirements
- WebSocket-based real-time communication
- Support for binary audio data transmission
- PCM audio processing and conversion
- Client-side audio buffer management
- Automatic reconnection with exponential backoff
- Cross-browser compatibility

### 7. Performance Requirements
- Handle continuous audio streams efficiently
- Process and display transcript data with minimal latency
- Support long-running connections
- Efficient memory usage for audio storage
