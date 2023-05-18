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

EXPOSE 3000

ENTRYPOINT ["lib/entrypoint.sh"]
CMD ["foreman", "start"]
