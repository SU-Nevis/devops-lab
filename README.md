# DevOps Labs

Small, reproducible labs for learning and demonstrating practical DevOps workflows. Each lab uses the same lifecycle so it can be run locally and proved again in GitHub Actions.

## Labs

- [`lab-template/`](lab-template/) — the reusable Docker Compose lab template.
- [`example-static-page/`](example-static-page/) — a complete static-page example built from the template.

## Run a lab

Choose a lab directory, then run:

```sh
make up
make verify
make down
```

The root GitHub Actions workflow runs this sequence for both labs on every push and pull request. Teardown runs even when verification fails, and it rejects leftover Compose-labeled containers, networks, or volumes.

See [`skill-map.md`](skill-map.md) for the learning path and [`VERIFIED.md`](VERIFIED.md) for local validation evidence.
