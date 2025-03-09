package main

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"log"
	"math"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

// WebSocket upgrader
var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all connections
	},
}

// ClientConnection represents a WebSocket connection with its UID
type ClientConnection struct {
	conn *websocket.Conn
	uid  string
}

// TranscriptHub manages WebSocket connections
type TranscriptHub struct {
	clients          map[string]map[*websocket.Conn]bool // Map of UID to connections
	broadcast        chan struct {
		segments []Segment
		uid      string
	}
	audioClients     map[string]map[*websocket.Conn]bool // Map of UID to connections
	audioBroadcast   chan struct {
		data []byte
		uid  string
	}
	audioStats       chan struct {
		stats map[string]interface{}
		uid   string
	}
	register         chan ClientConnection
	registerAudio    chan ClientConnection
	unregister       chan ClientConnection
	unregisterAudio  chan ClientConnection
	mutex            sync.Mutex
	
	// Audio storage - now per UID
	audioBuffers     map[string][]byte
	audioBufferMutex sync.Mutex
	maxAudioBuffer   int
}

// NewTranscriptHub creates a new hub instance
func NewTranscriptHub() *TranscriptHub {
	return &TranscriptHub{
		clients:         make(map[string]map[*websocket.Conn]bool),
		broadcast:       make(chan struct {
			segments []Segment
			uid      string
		}),
		audioClients:    make(map[string]map[*websocket.Conn]bool),
		audioBroadcast:  make(chan struct {
			data []byte
			uid  string
		}),
		audioStats:      make(chan struct {
			stats map[string]interface{}
			uid   string
		}),
		register:        make(chan ClientConnection),
		registerAudio:   make(chan ClientConnection),
		unregister:      make(chan ClientConnection),
		unregisterAudio: make(chan ClientConnection),
		audioBuffers:    make(map[string][]byte),
		maxAudioBuffer:  10 * 1024 * 1024, // 10MB max buffer per UID
	}
}

// Run starts the hub
func (h *TranscriptHub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mutex.Lock()
			// Initialize map for this UID if it doesn't exist
			if _, ok := h.clients[client.uid]; !ok {
				h.clients[client.uid] = make(map[*websocket.Conn]bool)
			}
			h.clients[client.uid][client.conn] = true
			h.mutex.Unlock()
			
		case client := <-h.registerAudio:
			h.mutex.Lock()
			// Initialize map for this UID if it doesn't exist
			if _, ok := h.audioClients[client.uid]; !ok {
				h.audioClients[client.uid] = make(map[*websocket.Conn]bool)
			}
			h.audioClients[client.uid][client.conn] = true
			h.mutex.Unlock()
			
		case client := <-h.unregister:
			h.mutex.Lock()
			if clientMap, ok := h.clients[client.uid]; ok {
				if _, exists := clientMap[client.conn]; exists {
					delete(clientMap, client.conn)
					client.conn.Close()
					
					// Remove the UID map if empty
					if len(clientMap) == 0 {
						delete(h.clients, client.uid)
					}
				}
			}
			h.mutex.Unlock()
			
		case client := <-h.unregisterAudio:
			h.mutex.Lock()
			if clientMap, ok := h.audioClients[client.uid]; ok {
				if _, exists := clientMap[client.conn]; exists {
					delete(clientMap, client.conn)
					client.conn.Close()
					
					// Remove the UID map if empty
					if len(clientMap) == 0 {
						delete(h.audioClients, client.uid)
					}
				}
			}
			h.mutex.Unlock()
			
		case broadcast := <-h.broadcast:
			h.mutex.Lock()
			// Send only to clients with matching UID
			if clientMap, ok := h.clients[broadcast.uid]; ok {
				for client := range clientMap {
					err := client.WriteJSON(broadcast.segments)
					if err != nil {
						log.Printf("Error writing to WebSocket: %v", err)
						client.Close()
						delete(clientMap, client)
					}
				}
				
				// Remove the UID map if empty
				if len(clientMap) == 0 {
					delete(h.clients, broadcast.uid)
				}
			}
			h.mutex.Unlock()
			
		case audioBroadcast := <-h.audioBroadcast:
			h.mutex.Lock()
			// Send only to audio clients with matching UID
			if clientMap, ok := h.audioClients[audioBroadcast.uid]; ok {
				for client := range clientMap {
					err := client.WriteMessage(websocket.BinaryMessage, audioBroadcast.data)
					if err != nil {
						log.Printf("Error writing audio to WebSocket: %v", err)
						client.Close()
						delete(clientMap, client)
					}
				}
				
				// Remove the UID map if empty
				if len(clientMap) == 0 {
					delete(h.audioClients, audioBroadcast.uid)
				}
			}
			h.mutex.Unlock()
			
		case statsUpdate := <-h.audioStats:
			h.mutex.Lock()
			// Send stats only to audio clients with matching UID
			if clientMap, ok := h.audioClients[statsUpdate.uid]; ok {
				for client := range clientMap {
					err := client.WriteJSON(statsUpdate.stats)
					if err != nil {
						log.Printf("Error writing audio stats to WebSocket: %v", err)
						client.Close()
						delete(clientMap, client)
					}
				}
				
				// Remove the UID map if empty
				if len(clientMap) == 0 {
					delete(h.audioClients, statsUpdate.uid)
				}
			}
			h.mutex.Unlock()
		}
	}
}

// Segment represents a segment of the transcript
type Segment struct {
	Text      string    `json:"text"`
	Speaker   string    `json:"speaker"`
	SpeakerID int       `json:"speaker_id"`
	IsUser    bool      `json:"is_user"`
	PersonID  *string   `json:"person_id"`
	StartTime float64   `json:"start"`
	EndTime   float64   `json:"end"`
	Timestamp time.Time `json:"timestamp,omitempty"` // When the segment was received
}

// AudioStats represents statistics about the audio data
type AudioStats struct {
	SampleRate int     `json:"sample_rate"`
	Channels   int     `json:"channels"`
	PeakValue  int16   `json:"peak_value"`
	RMSValue   float64 `json:"rms_value"`
	ByteCount  int     `json:"byte_count"`
	UID        string  `json:"uid"`
	Timestamp  int64   `json:"timestamp"`
}

// TranscriptRequest represents the incoming request for transcript processing
type TranscriptRequest struct {
	SessionID string    `json:"session_id"`
	Segments  []Segment `json:"segments"`
}

// TranscriptResponse represents the response to a transcript processing request
type TranscriptResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

// Global hub for managing WebSocket connections
var hub *TranscriptHub

func main() {
	// Initialize the WebSocket hub
	hub = NewTranscriptHub()
	go hub.Run()

	// Set up routes
	http.HandleFunc("/", handleIndex)
	http.HandleFunc("/transcript/process", handleTranscriptProcess)
	http.HandleFunc("/audio/process", handleAudioProcess)
	http.HandleFunc("/audio/buffer", handleAudioBuffer)
	http.HandleFunc("/ws", handleWebSocket)
	http.HandleFunc("/ws/audio", handleAudioWebSocket)

	// Serve static files
	fs := http.FileServer(http.Dir("./static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// Start the server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	fmt.Printf("Server starting on port %s...\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

// handleWebSocket upgrades HTTP connection to WebSocket
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Error upgrading to WebSocket: %v", err)
		return
	}

	// Get UID from query parameters - required
	uid := r.URL.Query().Get("uid")
	if uid == "" {
		log.Printf("WebSocket connection attempt without UID")
		http.Error(w, "UID parameter is required", http.StatusBadRequest)
		return
	}

	// Register the client with its UID
	clientConn := ClientConnection{conn: conn, uid: uid}
	hub.register <- clientConn

	// Handle disconnection
	defer func() {
		hub.unregister <- clientConn
	}()

	// Keep the connection alive
	for {
		// Read messages (not used, but needed to detect disconnection)
		_, _, err := conn.ReadMessage()
		if err != nil {
			break
		}
	}
}

// handleAudioBuffer returns the stored audio buffer
func handleAudioBuffer(w http.ResponseWriter, r *http.Request) {
	// Set headers for audio data
	w.Header().Set("Content-Type", "audio/pcm")
	w.Header().Set("Content-Disposition", "attachment; filename=audio_buffer.pcm")
	
	// Get query parameters
	format := r.URL.Query().Get("format")
	
	// UID is required
	uid := r.URL.Query().Get("uid")
	if uid == "" {
		log.Printf("Audio buffer request without UID")
		http.Error(w, "UID parameter is required", http.StatusBadRequest)
		return
	}
	
	// Lock the buffer while reading
	hub.audioBufferMutex.Lock()
	defer hub.audioBufferMutex.Unlock()
	
	// Get the audio buffer for this UID
	audioBuffer, ok := hub.audioBuffers[uid]
	if !ok {
		// Return empty response if no buffer exists for this UID
		w.WriteHeader(http.StatusOK)
		return
	}
	
	if format == "wav" {
		// Convert PCM to WAV format
		sampleRate := 8000 // Default
		channels := 1      // Default
		
		if sampleRateParam := r.URL.Query().Get("sample_rate"); sampleRateParam != "" {
			fmt.Sscanf(sampleRateParam, "%d", &sampleRate)
		}
		
		if channelsParam := r.URL.Query().Get("channels"); channelsParam != "" {
			fmt.Sscanf(channelsParam, "%d", &channels)
		}
		
		// Create WAV header
		header := createWavHeader(len(audioBuffer), sampleRate, channels)
		
		// Write WAV header
		w.Header().Set("Content-Type", "audio/wav")
		w.Header().Set("Content-Disposition", "attachment; filename=audio_buffer.wav")
		w.Write(header)
	}
	
	// Write the audio buffer
	w.Write(audioBuffer)
}

// createWavHeader generates a WAV header for the given PCM data
func createWavHeader(dataSize int, sampleRate, channels int) []byte {
	// WAV header is 44 bytes
	header := make([]byte, 44)
	
	// RIFF header
	copy(header[0:4], []byte("RIFF"))
	// File size (data size + 36 bytes of header)
	binary.LittleEndian.PutUint32(header[4:8], uint32(dataSize+36))
	// WAVE format
	copy(header[8:12], []byte("WAVE"))
	
	// fmt chunk
	copy(header[12:16], []byte("fmt "))
	// fmt chunk size (16 bytes)
	binary.LittleEndian.PutUint32(header[16:20], 16)
	// Audio format (1 = PCM)
	binary.LittleEndian.PutUint16(header[20:22], 1)
	// Number of channels
	binary.LittleEndian.PutUint16(header[22:24], uint16(channels))
	// Sample rate
	binary.LittleEndian.PutUint32(header[24:28], uint32(sampleRate))
	// Byte rate (SampleRate * NumChannels * BitsPerSample/8)
	binary.LittleEndian.PutUint32(header[28:32], uint32(sampleRate*channels*2))
	// Block align (NumChannels * BitsPerSample/8)
	binary.LittleEndian.PutUint16(header[32:34], uint16(channels*2))
	// Bits per sample
	binary.LittleEndian.PutUint16(header[34:36], 16)
	
	// data chunk
	copy(header[36:40], []byte("data"))
	// Data size
	binary.LittleEndian.PutUint32(header[40:44], uint32(dataSize))
	
	return header
}

// handleAudioWebSocket upgrades HTTP connection to WebSocket for audio streaming
func handleAudioWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Error upgrading to WebSocket for audio: %v", err)
		return
	}

	// Get query parameters
	sampleRate := 8000 // Default sample rate
	channels := 1      // Default channels
	
	// UID is required
	uid := r.URL.Query().Get("uid")
	if uid == "" {
		log.Printf("Audio WebSocket connection attempt without UID")
		http.Error(w, "UID parameter is required", http.StatusBadRequest)
		return
	}
	
	if sampleRateParam := r.URL.Query().Get("sample_rate"); sampleRateParam != "" {
		fmt.Sscanf(sampleRateParam, "%d", &sampleRate)
	}
	
	if channelsParam := r.URL.Query().Get("channels"); channelsParam != "" {
		fmt.Sscanf(channelsParam, "%d", &channels)
	}

	// Send initial audio parameters
	initialStats := map[string]interface{}{
		"sample_rate": sampleRate,
		"channels":    channels,
		"message":     "Connected to audio stream",
		"uid":         uid,
	}
	
	if err := conn.WriteJSON(initialStats); err != nil {
		log.Printf("Error sending initial audio parameters: %v", err)
		conn.Close()
		return
	}

	// Register the client with its UID
	clientConn := ClientConnection{conn: conn, uid: uid}
	hub.registerAudio <- clientConn

	// Handle disconnection
	defer func() {
		hub.unregisterAudio <- clientConn
	}()

	// Keep the connection alive
	for {
		// Read messages (not used, but needed to detect disconnection)
		_, _, err := conn.ReadMessage()
		if err != nil {
			break
		}
	}
}

// handleIndex serves the main page
func handleIndex(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	tmpl, err := template.ParseFiles(filepath.Join("templates", "index.html"))
	if err != nil {
		log.Printf("Error parsing template: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	err = tmpl.Execute(w, nil)
	if err != nil {
		log.Printf("Error executing template: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
	}
}

// handleTranscriptProcess handles POST requests for transcript processing
func handleTranscriptProcess(w http.ResponseWriter, r *http.Request) {
	// Only accept POST requests
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Get UID from query parameters - required
	uid := r.URL.Query().Get("uid")
	if uid == "" {
		log.Printf("Transcript process request without UID")
		http.Error(w, "UID parameter is required", http.StatusBadRequest)
		return
	}

	// Read and log the request body
	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error reading request body: %v", err)
		http.Error(w, "Error reading request body", http.StatusBadRequest)
		return
	}
	
	// Log the raw request body
	log.Printf("Request body: %s", string(bodyBytes))
	
	// Parse the request body
	var request TranscriptRequest
	if err := json.Unmarshal(bodyBytes, &request); err != nil {
		log.Printf("Error decoding request: %v", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate the request
	if len(request.Segments) == 0 {
		http.Error(w, "No segments provided", http.StatusBadRequest)
		return
	}

	// Add timestamp to each segment
	now := time.Now()
	for i := range request.Segments {
		request.Segments[i].Timestamp = now
	}

	// Process the transcript (in a real application, this would do more)
	log.Printf("Session ID: %s, UID: %s", request.SessionID, uid)
	log.Printf("Received %d segments", len(request.Segments))
	for i, segment := range request.Segments {
		log.Printf("Segment %d: %s (%.2f - %.2f)", i+1, segment.Text, segment.StartTime, segment.EndTime)
	}

	// Broadcast to WebSocket clients with the specified UID
	go func() {
		hub.broadcast <- struct {
			segments []Segment
			uid      string
		}{
			segments: request.Segments,
			uid:      uid,
		}
	}()

    // Return JSON response
    resp := TranscriptResponse{
        Success: true,
        Message: fmt.Sprintf("Successfully processed %d segments", len(request.Segments)),
    }

    w.Header().Set("Content-Type", "application/json")
    if err := json.NewEncoder(w).Encode(resp); err != nil {
        log.Printf("Error encoding response: %v", err)
        http.Error(w, "Internal Server Error", http.StatusInternalServerError)
    }
}

// handleAudioProcess handles POST requests for audio processing
func handleAudioProcess(w http.ResponseWriter, r *http.Request) {
	// Only accept POST requests
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Get query parameters
	sampleRate := 8000 // Default sample rate
	channels := 1      // Default channels
	
	if sampleRateParam := r.URL.Query().Get("sample_rate"); sampleRateParam != "" {
		fmt.Sscanf(sampleRateParam, "%d", &sampleRate)
	}
	
	if channelsParam := r.URL.Query().Get("channels"); channelsParam != "" {
		fmt.Sscanf(channelsParam, "%d", &channels)
	}
	
	// UID is required
	uid := r.URL.Query().Get("uid")
	if uid == "" {
		log.Printf("Audio process request without UID")
		http.Error(w, "UID parameter is required", http.StatusBadRequest)
		return
	}

	// Read the request body (PCM audio data)
	audioBytes, err := io.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error reading audio data: %v", err)
		http.Error(w, "Error reading audio data", http.StatusBadRequest)
		return
	}

	// Process the audio data
	log.Printf("Received %d bytes of audio data from user %s", len(audioBytes), uid)

	// Store audio data in buffer for this UID
	hub.audioBufferMutex.Lock()
	
	// Initialize buffer for this UID if it doesn't exist
	if _, ok := hub.audioBuffers[uid]; !ok {
		hub.audioBuffers[uid] = make([]byte, 0)
	}
	
	// Append new audio data
	hub.audioBuffers[uid] = append(hub.audioBuffers[uid], audioBytes...)
	
	// Trim buffer if it exceeds max size
	if len(hub.audioBuffers[uid]) > hub.maxAudioBuffer {
		excess := len(hub.audioBuffers[uid]) - hub.maxAudioBuffer
		hub.audioBuffers[uid] = hub.audioBuffers[uid][excess:]
	}
	
	// Get total buffer size for this UID
	totalBufferSize := len(hub.audioBuffers[uid])
	
	hub.audioBufferMutex.Unlock()

	// Calculate audio statistics
	var peakValue int16 = 0
	var sumSquares float64 = 0
	
	// Process as int16 PCM data
	if len(audioBytes) >= 2 {
		// Convert bytes to int16 samples
		samples := make([]int16, len(audioBytes)/2)
		for i := 0; i < len(audioBytes); i += 2 {
			if i+1 < len(audioBytes) {
				// Convert two bytes to one int16 sample (little endian)
				sample := int16(audioBytes[i]) | (int16(audioBytes[i+1]) << 8)
				samples[i/2] = sample
				
				// Update peak value
				if sample < 0 {
					sample = -sample
				}
				if sample > peakValue {
					peakValue = sample
				}
				
				// Update sum of squares for RMS calculation
				sumSquares += float64(sample) * float64(sample)
			}
		}
		
		// Calculate RMS value
		rmsValue := 0.0
		if len(samples) > 0 {
			rmsValue = math.Sqrt(sumSquares / float64(len(samples)))
		}
		
		// Calculate buffer duration in seconds
		bufferDuration := float64(totalBufferSize) / float64(sampleRate * channels * 2)
		
		// Create audio stats
		stats := map[string]interface{}{
			"sample_rate": sampleRate,
			"channels":    channels,
			"peak_value":  peakValue,
			"rms_value":   rmsValue,
			"byte_count":  len(audioBytes),
			"uid":         uid,
			"timestamp":   time.Now().UnixMilli(),
			"total_buffer_size": totalBufferSize,
			"buffer_duration": bufferDuration,
		}
		
		// Broadcast audio data to WebSocket clients with the specified UID
		go func() {
			hub.audioBroadcast <- struct {
				data []byte
				uid  string
			}{
				data: audioBytes,
				uid:  uid,
			}
			
			hub.audioStats <- struct {
				stats map[string]interface{}
				uid   string
			}{
				stats: stats,
				uid:   uid,
			}
		}()
	}

	// Return success response
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Audio data processed successfully"))
}
