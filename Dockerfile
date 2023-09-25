FROM ruby:3.1-slim

WORKDIR /jekyll

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

ENTRYPOINT ["bundle", "exec", "jekyll"]
