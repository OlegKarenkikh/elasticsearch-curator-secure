IMAGE_NAME  := elasticsearch-curator-secure
IMAGE_TAG   := $(shell git rev-parse --short HEAD 2>/dev/null || echo "local")
FULL_IMAGE  := $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: build scan scan-critical scan-json clean help

help: ## Показать справку
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Собрать Docker-образ
	docker buildx build --load -t $(FULL_IMAGE) .
	@echo "Built: $(FULL_IMAGE)"

scan: build ## Сканировать Trivy (все severity)
	trivy image \
		--ignorefile .trivyignore \
		--ignore-unfixed \
		--severity CRITICAL,HIGH,MEDIUM \
		$(FULL_IMAGE)

scan-critical: build ## Сканировать только CRITICAL/HIGH (gate)
	trivy image \
		--ignorefile .trivyignore \
		--ignore-unfixed \
		--severity CRITICAL,HIGH \
		--exit-code 1 \
		$(FULL_IMAGE)

scan-json: build ## Сохранить отчёт Trivy в JSON
	trivy image \
		--ignorefile .trivyignore \
		--ignore-unfixed \
		--format json \
		--output trivy-results.json \
		$(FULL_IMAGE)
	@echo "Report saved: trivy-results.json"

clean: ## Удалить локальный образ
	docker rmi $(FULL_IMAGE) 2>/dev/null || true
