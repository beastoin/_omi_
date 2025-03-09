# Omi Real-Time Processor

A Golang web server with WebSocket integration that handles real-time transcript and audio processing for the Omi device. The server supports multiple users through a UID-based connection system.

## Project Structure

```
x/server/
├── main.go           # Main entry point for the server
├── templates/        # HTML templates
│   ├── index.html    # Main page template with WebSocket client
├── static/           # Static assets
│   └── css/
│       └── style.css # CSS styles
├── prd.txt           # Product Requirements Document
├── impl.txt          # Implementation Document
├── Dockerfile        # Docker configuration
├── docker-compose.yml # Docker Compose configuration
└── README.md         # This file
```

## Requirements

- Go 1.16 or higher
- gorilla/websocket package

## Running the Server

1. Navigate to the server directory:
   ```
   cd tools/01
   ```

2. Run the server:
   ```
   go run main.go
   ```

3. Open your browser and navigate to (UID is required):
   ```
   http://localhost:8080/?uid=your_user_id
   ```

## API Endpoints

### WebSocket Connections

- `/ws?uid=<user_id>` - WebSocket endpoint for transcript updates
- `/ws/audio?uid=<user_id>&sample_rate=<rate>&channels=<num>` - WebSocket endpoint for audio streaming

### HTTP Endpoints

#### POST /transcript/process?uid=<user_id>

Accepts transcript data for processing.

Request body format:
```json
{
  "session_id": "string",
  "segments": [
    {
      "text": "string",
      "speaker": "SPEAKER_XX",
      "speaker_id": number,
      "is_user": boolean,
      "start": number,
      "end": number
    }
  ]
}
```

#### POST /audio/process?uid=<user_id>&sample_rate=<rate>&channels=<num>

Accepts raw PCM audio data for processing.

#### GET /audio/buffer?uid=<user_id>&format=<pcm|wav>&sample_rate=<rate>&channels=<num>

Returns the stored audio buffer for the specified user.

## Testing with cURL

Test the transcript processing endpoint:

```bash
curl -X POST "http://localhost:8080/transcript/process?uid=test_user" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test-session",
    "segments": [
      {
        "text": "Hello world",
        "speaker": "SPEAKER_00",
        "speaker_id": 0,
        "is_user": false,
        "start": 0.0,
        "end": 2.5
      }
    ]
  }'
```

Send audio data:

```bash
curl -X POST "http://localhost:8080/audio/process?uid=test_user&sample_rate=8000&channels=1" \
  --data-binary @audio_sample.pcm
```

## Docker Support

Build and run with Docker Compose:

```bash
docker-compose up -d
```

## Integration with Omi

This server is designed to work with the Omi device for real-time transcript and audio processing. For more information on how to integrate with Omi, see the [Omi documentation](https://docs.omi.me/docs/developer/apps/Integrations).
