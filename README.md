# DevOps Labs

Small, reproducible labs for learning and demonstrating practical DevOps workflows. Each lab uses the same lifecycle so it can be run locally and proved again in GitHub Actions.

## Labs

- [`handbook/`](handbook/) — the hands-on learning road: start with [`01-shell/`](handbook/01-shell/), then continue to [`02-docker/`](handbook/02-docker/); type every command, practise, break/fix, and run a read-only grader.
- [`lab-template/`](lab-template/) — the reusable Docker Compose lab template.
- [`example-static-page/`](example-static-page/) — a complete static-page example built from the template.
- [`terraform-docker-lab/`](terraform-docker-lab/) — Terraform declares an nginx container, verifies its response, and proves destroy leaves nothing behind.

## Run a lab

Choose a lab directory, then run:

```sh
make up
make verify
make down
```

The root GitHub Actions workflow runs this sequence for every lab on pushes and pull requests. Teardown runs even when verification fails, and each lab rejects its own leftover Docker resources.

See [`skill-map.md`](skill-map.md) for the learning path and [`VERIFIED.md`](VERIFIED.md) for local validation evidence.
