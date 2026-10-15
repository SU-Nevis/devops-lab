.PHONY: up verify down

up:
	docker compose up -d --wait

verify:
	@echo "Intentional CI proof failure: verify must fail before teardown"
	@exit 42

down:
	sh ./scripts/down.sh
