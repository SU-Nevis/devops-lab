#!/bin/sh
# Read-only inspection: this script never creates, repairs, or removes artifacts.
set -u
lab=${HOME:?HOME is not set}/devops-lab/01-shell
failures=0; total=7
pass() { printf 'PASS %-20s %s\n' "$1" "$2"; }
fail() { printf 'FAIL %-20s %s | Inspect: %s\n' "$1" "$2" "$3"; failures=$((failures + 1)); }
printf 'Linux and shell grader (inspection only)\n\n'
owner=$(id -un)
if [ -f "$lab/owned.txt" ]; then pass 'file.exists' 'owned.txt exists'; else fail 'file.exists' 'create ~/devops-lab/01-shell/owned.txt' "ls -la '$lab'"; fi
if [ "$(stat -c '%a %U' "$lab/owned.txt" 2>/dev/null)" = "640 $owner" ]; then pass 'file.mode-owner' "owned.txt is mode 640 and owned by $owner"; else fail 'file.mode-owner' "set owned.txt to mode 640 and owner $owner" "stat -c '%a %U %G %n' '$lab/owned.txt'"; fi
if [ -f "$lab/strict.sh" ] && grep -Fxq 'set -euo pipefail' "$lab/strict.sh" 2>/dev/null; then pass 'script.strict-mode' 'strict.sh enables set -euo pipefail'; else fail 'script.strict-mode' 'write strict.sh with set -euo pipefail' "sed -n '1,8p' '$lab/strict.sh'"; fi
if [ -f "$lab/strict.sh" ]; then bash "$lab/strict.sh" reject >/dev/null 2>&1; status=$?; if [ "$status" -eq 64 ]; then pass 'script.rejects' 'strict.sh reject exits 64'; else fail 'script.rejects' "strict.sh reject exits $status instead of 64" "bash '$lab/strict.sh' reject"; fi; else fail 'script.rejects' 'write strict.sh before testing reject' "ls -l '$lab/strict.sh'"; fi
if [ "$(cat "$lab/stdout.txt" 2>/dev/null)" = 'out: visible' ]; then pass 'redirect.stdout' 'stdout.txt contains only stdout'; else fail 'redirect.stdout' 'capture out: visible in stdout.txt' "sed -n '1,5p' '$lab/stdout.txt'"; fi
if [ "$(cat "$lab/stderr.txt" 2>/dev/null)" = 'err: visible' ]; then pass 'redirect.stderr' 'stderr.txt contains only stderr'; else fail 'redirect.stderr' 'capture err: visible in stderr.txt' "sed -n '1,5p' '$lab/stderr.txt'"; fi
if [ -s "$lab/notes.md" ]; then pass 'notes.written' 'notes.md exists and is not empty'; else fail 'notes.written' 'write three lines in ~/devops-lab/01-shell/notes.md' "ls -l '$lab/notes.md'"; fi
printf '\nResult: %s passed, %s failed\n' "$((total - failures))" "$failures"
printf 'Next: fix the first FAIL, then run ./check.sh again.\n'
[ "$failures" -eq 0 ]
