DOCKER_COMMAND = docker run --rm -v ${PWD}:/srv/jekyll -v ${PWD}/vendor/bundle:/usr/local/bundle
JEKYLL_IMAGE = jekyll/jekyll:4.2.2

.PHONY: default
default: run

.PHONY: build
build:
	$(DOCKER_COMMAND) $(JEKYLL_IMAGE) jekyll build

.PHONY: run
run:
	$(DOCKER_COMMAND) -p 4000:4000 -p 35729:35729 $(JEKYLL_IMAGE) jekyll serve --future --drafts --livereload

.PHONY: bundle
bundle:
	$(DOCKER_COMMAND) $(JEKYLL_IMAGE) bundle update jekyll