# Omi Transcript Desktop App - Product Requirements Document

## Overview
The Omi Transcript Desktop App is a macOS application that connects to the Omi Real-Time Processor backend to display real-time transcripts and allows users to paste these transcripts into other applications.

## Features

### 1. Real-Time Transcript Display
- Connect to the WebSocket endpoint to receive transcript data
- Display transcript segments in real-time with speaker identification
- Show timestamp information for each segment
- Maintain a scrollable history of transcript segments

### 2. Transcript Paste Functionality
- Allow users to select transcript segments
- Provide a button to copy selected segments to clipboard
- Implement keyboard shortcut simulation to paste text into other applications
- Support Command+V keyboard shortcut simulation

## User Interface
- Clean, minimal interface focused on transcript display
- Transcript segments should be clearly separated and identified by speaker
- Controls for connection management and paste functionality
- Status indicators for connection state

## Technical Requirements
- macOS desktop application built with Flutter
- WebSocket connection to backend transcript service
- Integration with keypress_simulator for keyboard shortcut simulation
- Proper error handling for connection issues

## Success Criteria
- Application successfully connects to the backend WebSocket
- Real-time transcript segments are displayed correctly
- Selected transcript text can be pasted into other applications
- Application performs reliably on macOS
