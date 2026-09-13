.PHONY: build run test test-root test-nonroot clean export version

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

# La suite completa = root + non-root. Il percorso non-root non e' un extra:
# dopo l'intro lo studente NON e' root, quindi e' la condizione reale d'uso.
# Nessuno dei due bersaglia il volume dello studente: girano sul filesystem
# effimero del container (nessun -v Alpine_Latest).
test: test-root test-nonroot

test-root:
	@echo "==> Running anti-auto-referential test suite (P1-8)..."
	@docker run --rm -v "$(CURDIR)/tests:/opt/assisted-labs/tests:ro" $(IMAGE_NAME) bash /opt/assisted-labs/tests/run-tests.sh

test-nonroot:
	@echo "==> Running non-root suite (lab 03/08 come utente normale)..."
	@docker run --rm -v "$(CURDIR)/tests:/opt/assisted-labs/tests:ro" $(IMAGE_NAME) 		bash -c 'LAB_QA_MODE=1 bash /opt/assisted-labs/tests/run-tests-nonroot.sh'

export:
	@echo "==> Exporting standalone image archive: assisted-labs.tar.gz..."
	docker save $(IMAGE_NAME) | gzip > assisted-labs.tar.gz
	@echo "==> Archive ready: assisted-labs.tar.gz"

clean:
	@echo "==> Cleaning local artifacts and volume..."
	docker volume rm $(VOLUME_NAME) 2>/dev/null || true
	rm -f assisted-labs.tar.gz
