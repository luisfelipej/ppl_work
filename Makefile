.PHONY: help db-up db-down db-restart db-logs db-reset db-shell setup test clean

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)PplWork - Makefile Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

db-up: ## Start PostgreSQL container
	@echo "$(BLUE)Starting PostgreSQL...$(NC)"
	docker-compose --env-file .env.docker up -d
	@echo "$(GREEN)PostgreSQL is starting up. Waiting for it to be ready...$(NC)"
	@sleep 3
	@docker-compose exec postgres pg_isready -U postgres || echo "$(YELLOW)PostgreSQL is still starting...$(NC)"

db-down: ## Stop PostgreSQL container
	@echo "$(BLUE)Stopping PostgreSQL...$(NC)"
	docker-compose down
	@echo "$(GREEN)PostgreSQL stopped$(NC)"

db-restart: ## Restart PostgreSQL container
	@echo "$(BLUE)Restarting PostgreSQL...$(NC)"
	docker-compose restart
	@echo "$(GREEN)PostgreSQL restarted$(NC)"

db-logs: ## Show PostgreSQL logs
	docker-compose logs -f postgres

db-reset: ## Reset database (WARNING: destroys all data)
	@echo "$(YELLOW)WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(BLUE)Stopping and removing database...$(NC)"; \
		docker-compose down -v; \
		echo "$(BLUE)Starting fresh database...$(NC)"; \
		docker-compose --env-file .env.docker up -d; \
		sleep 3; \
		echo "$(GREEN)Database reset complete!$(NC)"; \
	else \
		echo "$(GREEN)Cancelled$(NC)"; \
	fi

db-shell: ## Open PostgreSQL shell
	@echo "$(BLUE)Opening PostgreSQL shell...$(NC)"
	docker-compose exec postgres psql -U postgres -d ppl_work_dev

setup: db-up ## Setup project (start DB, install deps, create and migrate DB)
	@echo "$(BLUE)Installing dependencies...$(NC)"
	mix deps.get
	@echo "$(BLUE)Creating database...$(NC)"
	mix ecto.create
	@echo "$(BLUE)Running migrations...$(NC)"
	mix ecto.migrate
	@echo "$(GREEN)Setup complete! Run 'mix phx.server' to start the app$(NC)"

test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	mix test

clean: ## Clean build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	mix clean
	rm -rf _build deps
	@echo "$(GREEN)Clean complete$(NC)"

server: ## Start Phoenix server
	@echo "$(BLUE)Starting Phoenix server...$(NC)"
	mix phx.server

iex: ## Start Phoenix server in IEx
	@echo "$(BLUE)Starting Phoenix server in IEx...$(NC)"
	iex -S mix phx.server
