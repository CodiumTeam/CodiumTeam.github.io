# Codium blog 

Welcome to the codium blog repository

## Writing a post

Run the local server with `make run` and open http://localhost:4000

You can create new posts under `_drafts/` folder, any draft will not be published even if you push it to master.

### Publishing

Move your draft to `_posts/` and make sure to set a date field on the post with a date in the past, if the date is in
the future (even for a few minutes) the post will be ignored until the next run of the pipeline.


## Custom jekyll container

There is a custom jekyll Dockerfile in this repo to enable the `mark_lines` option in the code blocks. This feature
is expected to land in jekyll 4.4.0 but is already merged into master. This container builds from a specific commit
in the master branch which already has the feature merged in.

The image is built and published by a pipeline.

To rebuild it locally if you make any change, run `make container`