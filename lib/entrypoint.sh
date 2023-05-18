#!/bin/sh

set -e

bin/rails db:create
bin/rails db:migrate
bin/rails assets:precompile

exec "$@"
