#!/usr/bin/env sh
set -eu

# Replace with an observable check for the lab.
docker compose ps --status running --quiet | grep -q .
printf '%s\n' 'Verification passed: at least one service is running.'
