# Environment variables
TAILSCALE_DOMAIN ?= beastoinx-1.tailc94d.ts.net:11199

# Run the Flutter app
.PHONY: run-app
run-app:
	cd tools/02/app && flutter run -d macos

# Run the backend server
.PHONY: run-backend
run-backend:
	cd tools/01 && docker compose build && docker compose up

# Wire the host with the backend using Caddy
.PHONY: wire-host
wire-host:
	caddy reverse-proxy --from $(TAILSCALE_DOMAIN) --to localhost:8099

# Run all services
.PHONY: run-all
run-all:
	@echo "Starting backend server..."
	@make run-backend &
	@echo "Wiring host with backend..."
	@make wire-host &
	@echo "Starting Flutter app..."
	@make run-app

# Help command
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make run-app       - Run the Flutter app"
	@echo "  make run-backend   - Run the backend server"
	@echo "  make wire-host     - Wire the host with the backend"
	@echo "  make run-all       - Run all services"
	@echo ""
	@echo "Environment variables:"
	@echo "  TAILSCALE_DOMAIN   - Tailscale domain (default: $(TAILSCALE_DOMAIN))"
