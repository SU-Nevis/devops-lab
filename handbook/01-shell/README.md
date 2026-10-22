# Step 1 — inspect and control Linux

## What you will build

You will build a small workspace in `~/devops-lab/01-shell/` containing a protected file, separated output streams, and a strict Bash script. A read-only grader proves the artifacts behave as intended.

## Why this matters

Shell commands connect build, deployment, diagnosis, and teardown work. Here you learn to see processes and ports, control permissions and signals, and make failures visible before you automate them.

## Before you start

Finish step 0 first. Use Linux or WSL2 with Ubuntu and allow about 30 minutes. PIDs, usernames, and timestamps differ on every machine.

## What you will be able to answer

- **How do permissions and ownership work?**
- **How would you find the process listening on a port?**
- **What are stdout, stderr, pipes, signals, and shell exit codes?**
- **Why use `set -eu`?**

## 1. Read a process table

Time: 3 minutes. **Foundation for:** How would you find the process listening on a port?

```sh
ps -eo pid,ppid,user,stat,%cpu,%mem,etime,comm | grep -E 'PID|bash|dockerd|systemd' | head
```

Real output from an Ubuntu terminal:

```text
    PID    PPID USER     STAT %CPU %MEM     ELAPSED COMMAND
      1       0 root     Ss    0.0  0.0    01:52:51 systemd
      2       1 root     Sl+   0.0  0.0    01:52:51 init-systemd(Ub
     46       1 root     S<s   0.0  0.1    01:52:51 systemd-journal
     80       1 systemd+ Ss    0.0  0.0    01:52:50 systemd-resolve
     84       1 root     Ss    0.0  0.0    01:52:50 systemd-udevd
    218       1 root     Ss    0.0  0.0    01:52:49 systemd-logind
    383       1 root     Ssl   0.0  0.5    01:52:49 dockerd
    674     666 user     Ss    0.0  0.0    01:52:48 bash
    739       1 user     Ss    0.0  0.0    01:52:48 systemd
```

**Why:** PID identifies a process, PPID its parent, USER its owner, STAT its state, and the remaining columns show cost, age, and command.

**If it fails:** If `ps` is missing, run `sudo apt-get update && sudo apt-get install -y procps`.

## 2. Find a port owner and stop it

Time: 4 minutes. **Interview question:** How would you find the process listening on a port?

```sh
mkdir -p ~/devops-lab/01-shell && cd ~/devops-lab/01-shell
```

```sh
python3 -m http.server 8765 --bind 127.0.0.1 >port.log 2>&1 & echo $! >port.pid
```

```sh
ss -ltnp | grep ':8765'
```

Real output:

```text
LISTEN 0      5           127.0.0.1:8765       0.0.0.0:*    users:(("python3",pid=25142,fd=3))
```

```sh
kill "$(cat port.pid)"
```

**Why:** `ss` connects a listening socket to its process. `kill PID` sends TERM to that exact process.

**If it fails:** If the port is busy, run `ss -ltnp | grep ':8765'`, stop the listed PID with `kill PID`, and start the server again.

## 3. Set permissions and ownership

Time: 4 minutes. **Interview question:** How do permissions and ownership work?

Stay in `~/devops-lab/01-shell`.

```sh
printf '%s\n' 'owned by me' > owned.txt && chmod 640 owned.txt && chown "$(id -un):$(id -gn)" owned.txt
```

```sh
stat -c '%a %U %G %n' owned.txt
```

Real output:

```text
640 user user owned.txt
```

**Why:** Mode `640` gives the owner read/write, the group read, and everyone else no access. Ownership determines which permission class applies.

**If it fails:** If `chown` reports an invalid group, run `id -un; id -gn`, then repeat the command exactly as shown.

## 4. Observe exit codes and separate streams

Time: 5 minutes. **Interview question:** What are stdout, stderr, pipes, signals, and shell exit codes?

```sh
true; printf 'exit=%s\n' "$?"; false; printf 'exit=%s\n' "$?"
```

Real output:

```text
exit=0
exit=1
```

```sh
sh -c 'printf "%s\n" "out: visible"; printf "%s\n" "err: visible" >&2' >stdout.txt 2>stderr.txt
```

```sh
printf 'stdout=<%s> stderr=<%s>\n' "$(cat stdout.txt)" "$(cat stderr.txt)"
```

Real output:

```text
stdout=<out: visible> stderr=<err: visible>
```

**Why:** Zero means success and non-zero means failure. File descriptors 1 and 2 keep program data separate from diagnostics.

**If it fails:** If both messages land in one file, remove `stdout.txt` and `stderr.txt`, then repeat the redirections in the shown order.

## 5. Use pipes and signals

Time: 4 minutes. **Interview question:** What are stdout, stderr, pipes, signals, and shell exit codes?

```sh
ps -eo user= | grep -v '^$' | sort | uniq -c | sort -nr | head
```

Real output:

```text
     39 user
     21 root
      2 _chrony
      1 systemd-resolve
      1 syslog
      1 ollama
      1 messagebus
```

```sh
sleep 300 & signal_pid=$!; kill -TERM "$signal_pid"; wait "$signal_pid" 2>/dev/null || true; ps -p "$signal_pid" >/dev/null 2>&1; printf 'ps exit=%s (non-zero means gone)\n' "$?"
```

Real output:

```text
ps exit=1 (non-zero means gone)
```

**Why:** Each pipeline command transforms real process data. TERM asks a process to stop; the final lookup proves it is gone.

**If it fails:** If `ps exit=0`, run `kill -TERM "$signal_pid"` once more and repeat `ps -p "$signal_pid"`.

## 6. Write a strict-mode script

Time: 5 minutes. **Interview question:** Why use `set -eu`?

```sh
printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' 'case "${1:-}" in' '  deploy) printf "%s\n" "deploy allowed" ;;' '  *) printf "%s\n" "branch rejected" >&2; exit 64 ;;' 'esac' > strict.sh
```

```sh
bash strict.sh deploy; bash strict.sh reject; printf 'exit=%s\n' "$?"
```

Real output:

```text
deploy allowed
branch rejected
exit=64
```

**Why:** `-e` stops on unhandled failure, `-u` rejects unset variables, and `pipefail` exposes a failed pipeline stage.

**If it fails:** If Bash reports a syntax error, run `bash -n strict.sh`, compare the reported line with the command above, and recreate the file.

## Grade your work

From `handbook/01-shell`, run:

```sh
./check.sh
```

A full PASS proves the file mode and owner, strict-script behavior, separated streams, and notes. The grader changes nothing.

## Write your notes

Write three lines: what the PASS proves, the one command you will not forget, and the one thing that broke.

```sh
printf '%s\n' 'PASS proves: ...' 'Command: ...' 'Broke: ...' > ~/devops-lab/01-shell/notes.md
```

Run `./check.sh` again.

## Clean up

Stop the temporary server if it is still running, then remove every artifact from this step:

```sh
test ! -f ~/devops-lab/01-shell/port.pid || kill "$(cat ~/devops-lab/01-shell/port.pid)" 2>/dev/null || true
```

```sh
rm -rf ~/devops-lab/01-shell
```

After cleanup, the notes criterion will FAIL; that is expected because cleanup removes `notes.md`.
