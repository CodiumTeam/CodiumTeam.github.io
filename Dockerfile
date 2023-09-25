FROM ruby:3.1-slim AS builder

WORKDIR /tmp

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git \
    make \
    gcc \
    g++ \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

ADD Gemfile Gemfile.lock .
RUN bundle install
RUN find /usr/local/bundle -name .git -exec rm -rf {} +
RUN rm -rf /usr/local/bundle/cache/*

FROM ruby:3.1-slim AS runtime
COPY --from=builder /usr/local/bundle /usr/local/bundle

WORKDIR /jekyll

ENTRYPOINT ["bundle", "exec", "jekyll"]
# bump: 1 (increment to force pipeline trigger when testing)