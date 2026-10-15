#!/usr/bin/env sh
set -eu

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

APP_PORT="${APP_PORT:-8080}"
body="$(curl --fail --silent --show-error "http://127.0.0.1:${APP_PORT}/")"
printf '%s' "$body" | grep -q 'DevOps lab is running'
printf '%s\n' "Verification passed: http://127.0.0.1:${APP_PORT}/ returned the expected page."
