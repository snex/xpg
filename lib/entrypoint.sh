#!/bin/sh

set -e

bin/rails db:create
bin/rails db:migrate

exec "$@"
