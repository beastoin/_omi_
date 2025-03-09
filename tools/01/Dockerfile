FROM golang:1.20-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum files (if they exist)
COPY go.mod go.sum* ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o transcript-processor .

# Use a smaller image for the final container
FROM alpine:latest

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/transcript-processor .

# Copy templates and static files
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/static ./static

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["./transcript-processor"]
