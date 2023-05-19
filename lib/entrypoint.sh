#!/bin/sh

set -e

if [ -z "$XPG_HOST" ]; then
	echo "Container failed to start. Missing required variable XPG_HOST"
	echo "Please see .env.docker.example."
	exit 1
fi

if [ -z "$MONERO_DAEMON" ]; then
	echo "Container failed to start. Missing required variable MONERO_DAEMON"
	echo "Please see .env.docker.example."
	exit 1
fi

if [ -z "$MONERO_DAEMON_PORT" ]; then
	echo "Container failed to start. Missing required variable MONERO_DAEMON_PORT"
	echo "Please see .env.docker.example."
	exit 1
fi

if [ -z "$SECRET_KEY_BASE" ]; then
	echo "Container failed to start. Missing required variable SECRET_KEY_BASE"
	echo "Please see .env.docker.example."
	exit 1
fi

if [ -z "$ENCRYPTION_PRIMARY_KEY" ]; then
	echo "Container failed to start. Missing required variable ENCRYPTION_PRIMARY_KEY"
	echo "Please see .env.docker.example."
	exit 1
fi

if [ -z "$ENCRYPTION_DETERMINISTIC_KEY" ]; then
	echo "Container failed to start. Missing required variable ENCRYPTION_DETERMINISTIC_KEY"
	echo "Please see .env.docker.example."
	exit 1
fi

if [ -z "$ENCRYPTION_KEY_DERIVATION_SALT" ]; then
	echo "Container failed to start. Missing required variable ENCRYPTION_KEY_DERIVATION_SALT"
	echo "Please see .env.docker.example."
	exit 1
fi

bin/rails db:create
bin/rails db:migrate
bin/rails assets:precompile

exec "$@"
