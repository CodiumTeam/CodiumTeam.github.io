DOCKER_COMMAND = docker run --rm -v ${PWD}:/srv/jekyll -v ${PWD}/vendor/bundle:/usr/local/bundle

build:
	$(DOCKER_COMMAND) jekyll/jekyll:3.8 jekyll build

run:
	$(DOCKER_COMMAND) -p 4000:4000 jekyll/jekyll:3.8 jekyll serve --future --livereload