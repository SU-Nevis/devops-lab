# Hands-on DevOps handbook

This is a road you drive, not a button you press. Allow about 80 minutes for all three steps.

For each step, type the commands and inspect the real output. Practise without the recipe, run `./break.sh`, diagnose and fix the fault, then run `./check.sh`. Finish by writing the three requested notes. The grader is read-only: it proves your work without doing it for you.

1. [`00-setup/`](00-setup/) — install and verify Docker Engine, GNU Make, `curl`, and Git.
2. [`01-shell/`](01-shell/) — inspect Linux processes, ports, permissions, streams, pipes, signals, and exit codes by hand.
3. [`02-docker/`](02-docker/) — run and inspect nginx by hand; prove ports, mounts, volumes, health checks, and networks.

The existing `make up`, `make verify`, and `make down` targets remain answer keys for the existing labs. They are not the learner path here.
