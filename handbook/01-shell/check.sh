#!/bin/sh
# Read-only inspection: this script never creates, repairs, or removes artifacts.
set -u

lab=/tmp/handbook-shell
failures=0
pass() { printf 'PASS %-20s %s\n' "$1" "$2"; }
fail() { printf 'FAIL %-20s %s\n' "$1" "$2"; failures=$((failures + 1)); }

printf 'Linux and shell grader (inspection only)\n\n'

owner=$(id -un)
if [ -f "$lab/owned.txt" ]; then pass 'file.exists' 'owned.txt exists'; else fail 'file.exists' 'create /tmp/handbook-shell/owned.txt'; fi
if [ "$(stat -c '%a %U' "$lab/owned.txt" 2>/dev/null)" = "640 $owner" ]; then pass 'file.mode-owner' "owned.txt is mode 640 and owned by $owner"; else fail 'file.mode-owner' "set owned.txt to mode 640 and owner $owner"; fi
if [ -f "$lab/strict.sh" ] && grep -Fxq 'set -euo pipefail' "$lab/strict.sh" 2>/dev/null; then pass 'script.strict-mode' 'strict.sh enables set -euo pipefail'; else fail 'script.strict-mode' 'write strict.sh with set -euo pipefail'; fi
if [ -f "$lab/strict.sh" ] && bash "$lab/strict.sh" reject >/dev/null 2>&1; then fail 'script.rejects' 'strict.sh reject must exit non-zero'; else
  if [ -f "$lab/strict.sh" ]; then pass 'script.rejects' 'strict.sh reject exits non-zero'; else fail 'script.rejects' 'write strict.sh before testing reject'; fi
fi
if [ "$(cat "$lab/stdout.txt" 2>/dev/null)" = 'out: visible' ]; then pass 'redirect.stdout' 'stdout.txt contains only stdout'; else fail 'redirect.stdout' 'capture out: visible in stdout.txt'; fi
if [ "$(cat "$lab/stderr.txt" 2>/dev/null)" = 'err: visible' ]; then pass 'redirect.stderr' 'stderr.txt contains only stderr'; else fail 'redirect.stderr' 'capture err: visible in stderr.txt'; fi

printf '\nResult: %s passed, %s failed\n' "$((6 - failures))" "$failures"
[ "$failures" -eq 0 ]
