FROM ruby:3.2.1-alpine

WORKDIR /app
COPY . .

RUN apk add --update \
      build-base \
      curl \
      git \
      monero \
      nodejs \
      postgresql-client \
      postgresql-dev \
      tzdata \
    && gem install foreman \
    && BUNDLER_WITHOUT="development:test" bundle install \
    && apk --purge del \
      apk-tools \
      build-base \
      postgresql-dev \
    && rm -rf /etc/apk/cache

EXPOSE 3000

ENTRYPOINT ["lib/entrypoint.sh"]
CMD ["foreman", "start"]
