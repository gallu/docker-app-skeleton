.PHONY: up down clean all-clean disintegrate

up:
	docker compose up -d --build

down:
	docker compose down

# プロジェクト専用クリーン（最も安全）
clean:
	docker compose down --rmi local --volumes

# Docker 全域の軽めクリーン
all-clean:
	docker system prune -f

# Docker 全域の完全破壊
disintegrate:
	docker system prune -a --volumes -f

