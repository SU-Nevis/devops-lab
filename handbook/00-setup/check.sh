#!/bin/sh
# Inspection only: no install, pull, run, start, repair, or cleanup commands.
set -u
failures=0; total=7
pass() { printf 'PASS %-18s %s\n' "$1" "$2"; }
fail() { printf 'FAIL %-18s %s | Inspect: %s\n' "$1" "$2" "$3"; failures=$((failures + 1)); }
check_command() { if command -v "$2" >/dev/null 2>&1; then pass "$1" "$2 found"; else fail "$1" "install $2" "command -v $2"; fi; }
printf 'Setup grader (inspection only)\n\n'
check_command 'tool.docker' docker
check_command 'tool.make' make
check_command 'tool.curl' curl
check_command 'tool.git' git
if docker info >/dev/null 2>&1; then pass 'docker.engine' 'Docker server responds'; else fail 'docker.engine' 'start Docker and check socket access' 'docker info'; fi
if docker image inspect hello-world:latest >/dev/null 2>&1; then pass 'docker.hello-world' 'hello-world image records a successful smoke-test pull'; else fail 'docker.hello-world' 'run docker run --rm hello-world' 'docker image inspect hello-world:latest'; fi
notes=${HOME:?HOME is not set}/devops-lab/00-setup/notes.md
if [ -s "$notes" ]; then pass 'notes.written' 'notes.md exists and is not empty'; else fail 'notes.written' 'write three lines in ~/devops-lab/00-setup/notes.md' "ls -l '$notes'"; fi
printf '\nResult: %s passed, %s failed\n' "$((total - failures))" "$failures"
if [ "$failures" -gt 0 ]; then printf 'Next: fix the first FAIL, then run ./check.sh again.\n'; else printf 'Done: continue to 01-shell.\n'; fi
[ "$failures" -eq 0 ]
