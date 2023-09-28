DOCKER_COMMAND = docker run --rm -v ${PWD}:/jekyll
JEKYLL_IMAGE = ghcr.io/codiumteam/jekyll:latest

.PHONY: default
default: run

.PHONY: build
build:
	$(DOCKER_COMMAND) -e JEKYLL_ENV $(JEKYLL_IMAGE) build

.PHONY: run
run:
	$(DOCKER_COMMAND) -p 4000:4000 -p 35729:35729 $(JEKYLL_IMAGE) serve --host=0.0.0.0 --future --drafts --livereload

.PHONY: bundle-update
bundle-update:
	docker build -t codiumteam/jekyll:builder --target=builder .
	$(DOCKER_COMMAND) --entrypoint bundle codiumteam/jekyll:builder update

.PHONY: container
container:
	docker build -t ghcr.io/codiumteam/jekyll:latest .
