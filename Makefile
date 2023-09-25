DOCKER_COMMAND = docker run --rm -v ${PWD}:/jekyll
JEKYLL_IMAGE = ghcr.io/codiumteam/jekyll:latest

.PHONY: default
default: run

.PHONY: build
build:
	$(DOCKER_COMMAND) $(JEKYLL_IMAGE) build

.PHONY: run
run:
	$(DOCKER_COMMAND) -p 4000:4000 -p 35729:35729 $(JEKYLL_IMAGE) serve --host=0.0.0.0 --future --drafts --livereload

.PHONY: bundle-update
bundle-update:
	$(DOCKER_COMMAND) --entrypoint bundle $(JEKYLL_IMAGE) update

.PHONY: container
container:
	docker build -t ghcr.io/codiumteam/jekyll:latest .
