# Step 1 — Linux and shell from the driver’s seat

Do this on Linux or WSL2 after `00-setup`. Every output shown below was captured on the course machine; PIDs, usernames, timestamps, and process lists will differ on yours.

## 1. List processes and read the useful columns

Time: 3 minutes. Interview question: **How would you find the process listening on a port?**

Working directory: repository root.

```sh
ps
```

Real output:

```text
    PID TTY          TIME CMD
      1 ?        00:00:00 codex
      2 ?        00:00:00 bash
      9 ?        00:00:00 ps
```

Working directory: repository root.

```sh
ps -ef | head -n 1
```

Real output:

```text
UID          PID    PPID  C STIME TTY          TIME CMD
```

Working directory: repository root.

```sh
ps -eo pid,ppid,user,stat,%cpu,%mem,etime,comm --sort=-%cpu | head
```

Real output:

```text
    PID    PPID USER     STAT %CPU %MEM     ELAPSED COMMAND
      1       0 user     Ss    0.0  0.1       00:00 codex
      2       1 user     S     0.0  0.0       00:00 bash
     12       2 user     R     0.0  0.0       00:00 ps
```

Why: PID identifies the process, PPID its parent, USER its owner, STAT its state, CPU and memory its current cost, ELAPSED its age, and COMMAND what is running.

## 2. Find a port owner and terminate it by PID

Time: 4 minutes. Interview question: **How would you find the process listening on a port?**

Working directory: repository root.

```sh
python3 -m http.server 8765 --bind 127.0.0.1 >/tmp/handbook-port.log 2>&1 & echo $! >/tmp/handbook-port.pid
```

Working directory: repository root.

```sh
ss -ltnp | grep ':8765'
```

Real output:

```text
LISTEN 0      5           127.0.0.1:8765       0.0.0.0:*    users:(("python3",pid=6775,fd=3))
```

Working directory: repository root.

```sh
kill "$(cat /tmp/handbook-port.pid)"
```

Why: `ss` connects the listening socket to its process and PID; `kill PID` sends TERM to that exact process.

## 3. Set and inspect permissions and ownership

Time: 4 minutes. Interview question: **How do permissions and ownership work?**

Working directory: repository root.

```sh
mkdir -p /tmp/handbook-shell && printf '%s\n' 'owned by me' > /tmp/handbook-shell/owned.txt
```

Working directory: repository root.

```sh
ls -l /tmp/handbook-shell/owned.txt
```

Real output:

```text
-rw-r--r-- 1 user user 12 Oct 19 19:19 /tmp/handbook-shell/owned.txt
```

Working directory: repository root.

```sh
chmod 640 /tmp/handbook-shell/owned.txt
```

Working directory: repository root.

```sh
chown "$(id -un):$(id -gn)" /tmp/handbook-shell/owned.txt
```

Working directory: repository root.

```sh
stat -c '%a %U %G %n' /tmp/handbook-shell/owned.txt
```

Real output:

```text
640 user user /tmp/handbook-shell/owned.txt
```

Why: the numeric mode gives the owner read/write, the group read, and everyone else no access; ownership determines which class applies.

## 4. Observe success and failure exit codes

Time: 2 minutes. Interview question: **What are stdout, stderr, pipes, signals, and shell exit codes?**

Working directory: repository root.

```sh
true; printf 'exit=%s\n' "$?"
```

Real output:

```text
exit=0
```

Working directory: repository root.

```sh
false; printf 'exit=%s\n' "$?"
```

Real output:

```text
exit=1
```

Why: zero reports success; a non-zero status reports failure and lets callers make decisions.

## 5. Separate stdout from stderr

Time: 3 minutes. Interview question: **What are stdout, stderr, pipes, signals, and shell exit codes?**

Working directory: repository root.

```sh
sh -c 'printf "%s\n" "out: visible"; printf "%s\n" "err: visible" >&2' >/tmp/handbook-shell/stdout.txt 2>/tmp/handbook-shell/stderr.txt
```

Working directory: repository root.

```sh
printf 'stdout=<%s> stderr=<%s>\n' "$(cat /tmp/handbook-shell/stdout.txt)" "$(cat /tmp/handbook-shell/stderr.txt)"
```

Real output:

```text
stdout=<out: visible> stderr=<err: visible>
```

Why: file descriptor 1 and file descriptor 2 are independent streams, so automation can keep data separate from diagnostics.

## 6. Chain pipes and filters on real process output

Time: 3 minutes. Interview question: **What are stdout, stderr, pipes, signals, and shell exit codes?**

Working directory: repository root.

```sh
ps -eo user= | grep -v '^$' | sort | uniq -c | sort -nr | head
```

Real output:

```text
      8 user
```

Working directory: repository root.

```sh
ps -eo comm= | grep -E 'sh|python' | sort | head | wc -l
```

Real output:

```text
5
```

Why: each program transforms the previous program’s real output; `grep` selects, `sort` orders, `head` limits, and `wc -l` counts.

## 7. Send TERM to a background process and prove it is gone

Time: 3 minutes. Interview question: **What are stdout, stderr, pipes, signals, and shell exit codes?**

Working directory: repository root.

```sh
sleep 300 & signal_pid=$!; kill -TERM "$signal_pid"; wait "$signal_pid" 2>/dev/null || true; ps -p "$signal_pid" >/dev/null 2>&1; printf 'ps exit=%s (non-zero means gone)\n' "$?"
```

Real output:

```text
ps exit=1 (non-zero means gone)
```

Why: TERM asks a process to shut down; waiting reaps it, and the final lookup proves the PID is no longer present.

## 8. Write a strict-mode script with a rejected branch

Time: 5 minutes. Interview question: **Why use `set -eu`?**

Working directory: repository root.

```sh
printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' 'case "${1:-}" in' '  deploy) printf "%s\n" "deploy allowed" ;;' '  *) printf "%s\n" "branch rejected" >&2; exit 64 ;;' 'esac' > /tmp/handbook-shell/strict.sh
```

Working directory: repository root.

```sh
bash /tmp/handbook-shell/strict.sh deploy
```

Real output:

```text
deploy allowed
```

Working directory: repository root.

```sh
bash /tmp/handbook-shell/strict.sh reject; printf 'exit=%s\n' "$?"
```

Real output:

```text
branch rejected
exit=64
```

Why: `-e` stops on unhandled command failure, `-u` rejects unset variables, `pipefail` exposes failure anywhere in a pipeline, and the named reject branch deliberately returns non-zero.

## 9. Grade only what you made

Time: 1 minute. Interview question: **How do permissions and ownership work?**

Working directory: `handbook/01-shell`.

```sh
sh ./check.sh
```

Why: the grader inspects the mode and owner, strict-mode script behavior, and separated stream files without creating or repairing learner artifacts.
