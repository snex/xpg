FROM ruby:3.2.1-alpine-3.18

WORKDIR /app
COPY . .

ENV BUNDLE_WITHOUT="development:test"

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
    && bundle install \
    && apk --purge del \
      apk-tools \
      build-base \
      postgresql-dev \
    && rm -rf /etc/apk/cache

EXPOSE 3000

ENTRYPOINT ["lib/entrypoint.sh"]
CMD ["foreman", "start"]
