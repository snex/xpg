FROM ruby:3.2.1-alpine

RUN apk add --update \
      build-base \
      curl \
      git \
      monero \
      nodejs \
      postgresql-client \
      postgresql-dev \
      tzdata \
      && rm -rf /var/cache/apk/*

WORKDIR /app

RUN gem install foreman
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD bin/rails db:create && bin/rails db:migrate && foreman start
