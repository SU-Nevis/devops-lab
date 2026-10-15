#!/usr/bin/env sh
set -eu

# Read the Compose project name from compose.yaml, then sanitise it: drop a
# trailing comment, surrounding quotes and whitespace. A name that survives
# that but is not a legal Compose project name is rejected, so the label
# checks below can never silently match nothing.
project="$(sed -n 's/^name:[[:space:]]*//p' compose.yaml | head -n 1)"
project="${project%%#*}"
project="$(printf '%s' "$project" | tr -d "\"' 	")"
case "$project" in
  '')
    printf '%s\n' 'compose.yaml needs a name: key' >&2
    exit 1
    ;;
  *[!a-z0-9_-]*)
    printf 'compose.yaml has an unusable name: value (%s)\n' "$project" >&2
    exit 1
    ;;
esac
docker compose down --volumes --remove-orphans

# Names, not IDs, so a leak report says what leaked.
containers="$(docker ps --all --filter "label=com.docker.compose.project=${project}" --format '{{.Names}}')"
networks="$(docker network ls --filter "label=com.docker.compose.project=${project}" --format '{{.Name}}')"
volumes="$(docker volume ls --filter "label=com.docker.compose.project=${project}" --format '{{.Name}}')"

if [ -n "$containers" ] || [ -n "$networks" ] || [ -n "$volumes" ]; then
  printf '%s\n' 'Teardown failed: lab Docker resources remain.' >&2
  if [ -n "$containers" ]; then
    printf 'containers: %s\n' "$containers" >&2
  fi
  if [ -n "$networks" ]; then
    printf 'networks: %s\n' "$networks" >&2
  fi
  if [ -n "$volumes" ]; then
    printf 'volumes: %s\n' "$volumes" >&2
  fi
  exit 1
fi

printf '%s\n' 'Teardown verified: no lab containers, networks, or volumes remain.'
