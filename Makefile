.PHONY: up up-mysql up-pg down clean exec-php exec-mysql exec-pg ps logs all-clean disintegrate

up:
	docker compose --profile mysql --profile postgres up -d --build --remove-orphans

up-mysql:
	-docker compose --profile postgres stop postgres
	docker compose --profile mysql up -d --build --remove-orphans

up-pg:
	-docker compose --profile mysql stop mysql
	docker compose --profile postgres up -d --build --remove-orphans

down:
	docker compose --profile mysql --profile postgres down

# プロジェクト専用クリーン（最も安全）
clean:
	docker compose --profile mysql --profile postgres down --rmi local --volumes

# Exec into app container
exec-php:
	docker compose exec php bash

# Exec into mysql container
exec-mysql:
	docker compose exec mysql bash

# Exec into postgres container
exec-pg:
	docker compose exec postgres bash

# Show container process list
ps:
	docker compose --profile mysql --profile postgres ps

# Tail logs for all services
logs:
	docker compose --profile mysql --profile postgres logs -f

# Docker 全域の軽めクリーン
all-clean:
	docker system prune -f

# Docker 全域の完全破壊
disintegrate:
	docker system prune -a --volumes -f
