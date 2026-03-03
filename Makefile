# =========================
# Docker Workspace Makefile
# =========================

# Use docker compose v2
DC=docker compose

# Main service names
API_APP=starline-api-app
API_NGINX=starline-api-nginx
MYSQL=mysql
REDIS=redis
MEILI=meilisearch
MAILHOG=mailhog

# Frontend service names
ADMIN_UI=admin-ui
ADMIN_UI_MASTER=admin-ui-master
ORDER_DEV=ordering-portal-develop
ORDER_MASTER=ordering-portal-master

# -------------------------
# Basic Docker controls
# -------------------------
up:
	$(DC) up -d

build:
	$(DC) up -d --build

down:
	$(DC) down

restart:
	$(DC) restart

stop:
	$(DC) stop

ps:
	$(DC) ps

logs:
	$(DC) logs -f

logs-api:
	$(DC) logs -f $(API_APP) $(API_NGINX)

logs-front:
	$(DC) logs -f $(ADMIN_UI) $(ADMIN_UI_MASTER) $(ORDER_DEV) $(ORDER_MASTER)

logs-db:
	$(DC) logs -f $(MYSQL) $(REDIS) $(MEILI) $(MAILHOG)

# -------------------------
# Shell access
# -------------------------
bash-api:
	$(DC) exec $(API_APP) sh

bash-admin:
	$(DC) exec $(ADMIN_UI) sh

bash-admin-master:
	$(DC) exec $(ADMIN_UI_MASTER) sh

bash-order-dev:
	$(DC) exec $(ORDER_DEV) sh

bash-order-master:
	$(DC) exec $(ORDER_MASTER) sh

bash-mysql:
	$(DC) exec $(MYSQL) sh

# -------------------------
# Laravel helpers
# -------------------------
composer-install:
	$(DC) exec $(API_APP) composer install

artisan:
	$(DC) exec $(API_APP) php artisan

keygen:
	$(DC) exec $(API_APP) php artisan key:generate

migrate:
	$(DC) exec $(API_APP) php artisan migrate

migrate-fresh:
	$(DC) exec $(API_APP) php artisan migrate:fresh --seed

seed:
	$(DC) exec $(API_APP) php artisan db:seed

optimize-clear:
	$(DC) exec $(API_APP) php artisan optimize:clear

cache-clear:
	$(DC) exec $(API_APP) php artisan cache:clear

config-clear:
	$(DC) exec $(API_APP) php artisan config:clear

route-clear:
	$(DC) exec $(API_APP) php artisan route:clear

queue-work:
	$(DC) exec $(API_APP) php artisan queue:work

# -------------------------
# Scout / Meilisearch helpers
# -------------------------
scout-import:
	@if [ -z "$(MODEL)" ]; then \
		echo "Usage: make scout-import MODEL='App\\Models\\Product'"; \
		exit 1; \
	fi
	$(DC) exec $(API_APP) php artisan scout:import "$(MODEL)"

scout-flush:
	@if [ -z "$(MODEL)" ]; then \
		echo "Usage: make scout-flush MODEL='App\\Models\\Product'"; \
		exit 1; \
	fi
	$(DC) exec $(API_APP) php artisan scout:flush "$(MODEL)"

# -------------------------
# NPM helpers (Laravel app, if needed)
# -------------------------
npm-install-api:
	$(DC) exec $(API_APP) sh -lc "if command -v npm >/dev/null 2>&1; then npm install; else echo 'npm is not installed in API container'; fi"

# -------------------------
# Frontend helpers
# -------------------------
npm-admin:
	$(DC) exec $(ADMIN_UI) sh

npm-admin-master:
	$(DC) exec $(ADMIN_UI_MASTER) sh

npm-order-dev:
	$(DC) exec $(ORDER_DEV) sh

npm-order-master:
	$(DC) exec $(ORDER_MASTER) sh

# -------------------------
# Database / service checks
# -------------------------
mysql-cli:
	$(DC) exec $(MYSQL) mysql -u$$MYSQL_USER -p$$MYSQL_PASSWORD $$MYSQL_DATABASE

redis-ping:
	$(DC) exec $(REDIS) redis-cli ping

meili-health:
	$(DC) exec $(API_APP) sh -lc "php -r 'echo file_get_contents(\"http://meilisearch:7700/health\");' || true"

xdebug-check:
	$(DC) exec $(API_APP) php -v
	$(DC) exec $(API_APP) php -m | grep xdebug || true

redis-check:
	$(DC) exec $(API_APP) php -m | grep redis || true

# -------------------------
# Cleanup
# -------------------------
clean:
	$(DC) down --remove-orphans

clean-volumes:
	$(DC) down -v --remove-orphans

rebuild-api:
	$(DC) up -d --build $(API_APP) $(API_NGINX)

rebuild-front:
	$(DC) up -d --build $(ADMIN_UI) $(ADMIN_UI_MASTER) $(ORDER_DEV) $(ORDER_MASTER)

rebuild-admin-master:
	$(DC) up -d --build $(ADMIN_UI_MASTER)

# -------------------------
# First-time setup (Laravel)
# -------------------------
setup-laravel:
	$(DC) up -d --build
	$(DC) exec $(API_APP) composer install
	$(DC) exec $(API_APP) php artisan key:generate
	$(DC) exec $(API_APP) php artisan migrate

# -------------------------
# Help
# -------------------------
help:
	@echo "Available commands:"
	@echo "  make up                   - Start containers"
	@echo "  make build                - Build and start containers"
	@echo "  make down                 - Stop and remove containers"
	@echo "  make logs                 - Tail all logs"
	@echo "  make logs-api             - Tail Laravel/Nginx logs"
	@echo "  make logs-front           - Tail frontend logs (incl admin-ui-master)"
	@echo "  make bash-api             - Shell into Laravel PHP container"
	@echo "  make bash-admin           - Shell into admin-ui"
	@echo "  make bash-admin-master    - Shell into admin-ui-master"
	@echo "  make composer-install     - Run composer install in Laravel"
	@echo "  make artisan              - Run php artisan"
	@echo "  make migrate              - Run migrations"
	@echo "  make optimize-clear       - Clear Laravel caches"
	@echo "  make redis-ping           - Ping Redis"
	@echo "  make meili-health         - Check Meilisearch health"
	@echo "  make xdebug-check         - Verify Xdebug is loaded"
	@echo "  make scout-import MODEL='App\\Models\\Product'"