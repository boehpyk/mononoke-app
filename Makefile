.PHONY: help up down restart logs prod.up prod.down prod.restart prod.logs clean

# Colors
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[93m
RED := \033[31m
BLUE := \033[34m
MAGENTA := \033[35m
RESET := \033[0m
BOLD := \033[1m

help:
	@echo "$(BOLD)$(CYAN)Available commands:$(RESET)"
	@echo ""
	@echo "$(BOLD)$(GREEN)Development:$(RESET)"
	@echo "  $(YELLOW)make up$(RESET)        - Start development environment"
	@echo "  $(YELLOW)make down$(RESET)      - Stop development environment"
	@echo "  $(YELLOW)make build$(RESET)     - Build containers"
	@echo "  $(YELLOW)make restart$(RESET)   - Restart development environment"
	@echo "  $(YELLOW)make logs$(RESET)      - Show development logs"
	@echo ""
	@echo "$(BOLD)$(BLUE)Production:$(RESET)"
	@echo "  $(YELLOW)make prod.up$(RESET)       - Start production environment"
	@echo "  $(YELLOW)make prod.down$(RESET)     - Stop production environment"
	@echo "  $(YELLOW)make prod.restart$(RESET)  - Restart production environment"
	@echo "  $(YELLOW)make prod.logs$(RESET)     - Show production logs"
	@echo ""
	@echo "$(BOLD)$(RED)Cleanup:$(RESET)"
	@echo "  $(YELLOW)make clean$(RESET)         - Remove all containers, volumes, and images"

# Development commands
up:
	docker compose -f docker-compose.dev.yml up -d

down:
	docker compose -f docker-compose.dev.yml down

# Build containers
build:
	docker compose -f docker-compose.dev.yml build --no-cache

restart:
	docker compose -f docker-compose.dev.yml restart mononoke

logs:
	docker compose -f docker-compose.dev.yml logs -f mononoke

# Production commands
prod.up:
	docker compose -f docker-compose.prod.yml up --build -d

prod.down:
	docker compose -f docker-compose.prod.yml down

prod.restart:
	docker compose -f docker-compose.prod.yml restart mononoke

prod.logs:
	docker compose -f docker-compose.prod.yml logs -f mononoke

# Cleanup
clean:
	docker compose -f docker-compose.dev.yml down -v --remove-orphans
	docker compose -f docker-compose.prod.yml down -v --remove-orphans
	docker system prune -f