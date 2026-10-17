#!/bin/sh
# Inspection only: no install, pull, run, start, repair, or cleanup commands.
set -u

failures=0
pass() { printf 'PASS %-18s %s\n' "$1" "$2"; }
fail() { printf 'FAIL %-18s %s\n' "$1" "$2"; failures=$((failures + 1)); }
check_command() {
  if command -v "$2" >/dev/null 2>&1; then pass "$1" "$2 found"; else fail "$1" "install $2"; fi
}

printf 'Setup grader (inspection only)\n\n'
check_command 'tool.docker' docker
check_command 'tool.make' make
check_command 'tool.curl' curl
check_command 'tool.git' git
if docker info >/dev/null 2>&1; then pass 'docker.engine' 'Docker server responds'; else fail 'docker.engine' 'start Docker and check socket access'; fi
if docker image inspect hello-world:latest >/dev/null 2>&1; then pass 'docker.hello-world' 'hello-world image records a successful smoke-test pull'; else fail 'docker.hello-world' 'run docker run --rm hello-world'; fi

printf '\nResult: %s passed, %s failed\n' "$((6 - failures))" "$failures"
[ "$failures" -eq 0 ]
