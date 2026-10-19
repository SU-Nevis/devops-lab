# Linux and shell practice scenarios

Each scenario gives a goal and an objective success test, not a solution.

1. **Explain a busy process.** Goal: start a harmless CPU-bound process, identify its PID and read its CPU, elapsed-time, and command columns. Success test: show the process in both `ps -ef` and a CPU-sorted `ps` view, then stop it.
2. **Free a listening port.** Goal: start a temporary listener on a port of your choice, find its PID without relying on the launch message, and terminate it. Success test: `ss -ltnp` no longer lists that port.
3. **Build a private shared file.** Goal: create a file readable and writable by its owner, readable by its group, and inaccessible to others. Success test: `stat -c '%a %U %G'` reports mode `640` and the intended owner and group.
4. **Triage a mixed log.** Goal: separate normal and error records, then report the three most common normal messages. Success test: stdout and stderr are in separate files and a `sort | uniq -c | sort -nr | head` pipeline prints three rows.
5. **Defend a deployment script.** Goal: write a strict-mode Bash script that accepts `deploy` and rejects every other named branch. Success test: `deploy` exits 0, `rollback` exits non-zero, and an unset required variable also exits non-zero.
