.PHONY: build run test clean export version

IMAGE_NAME ?= alpine-latest-assisted-labs:latest
IMAGE_BASE ?= alpine-latest-assisted-labs
VOLUME_NAME ?= Alpine_Latest
VERSIONI_DIR ?= $(HOME)/Assisted-Labs-Versioni

version:
	@echo "==> Versionamento automatico..."
	@./versiona.sh

build:
	@echo "==> Building Docker image: $(IMAGE_NAME)..."
	docker build -t $(IMAGE_NAME) .

run:
	@echo "==> Starting Assisted Linux Labs interactive session..."
	docker run --rm -it --name assisted-labs -v $(VOLUME_NAME):/workspace $(IMAGE_NAME)

test:
	@echo "==> Running anti-auto-referential test suite (P1-8)..."
	@docker run --rm -v "$(CURDIR)/tests:/opt/assisted-labs/tests:ro" $(IMAGE_NAME) bash /opt/assisted-labs/tests/run-tests.sh

export:
	@echo "==> Exporting standalone image archive: assisted-labs.tar.gz..."
	docker save $(IMAGE_NAME) | gzip > assisted-labs.tar.gz
	@echo "==> Archive ready: assisted-labs.tar.gz"

clean:
	@echo "==> Cleaning local artifacts and volume..."
	docker volume rm $(VOLUME_NAME) 2>/dev/null || true
	rm -f assisted-labs.tar.gz
