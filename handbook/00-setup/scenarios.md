# Setup practice scenarios

Do these without copying from `answers.md`.

1. **New Ubuntu host.** Goal: install only Docker Engine, Make, curl, and Git. Success test: `./check.sh` reports 7 passed, 0 failed.
2. **Docker client only.** Goal: diagnose a working client that cannot reach a server. Success test: `docker info` exits zero without changing socket permissions.
3. **Non-root Docker.** Goal: let your normal login use Docker. Success test: `docker run --rm hello-world` succeeds without `sudo`.
4. **Version inventory.** Goal: record one-line versions for all four tools. Success test: each proof command in `README.md` exits zero.
