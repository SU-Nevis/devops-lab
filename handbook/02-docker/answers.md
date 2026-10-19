# Docker answers

The main drive in `README.md` is already the complete by-hand construction path. The planted drill fault detaches `handbook-web` from its user-defined network.

Inspect the attachment:

```sh
docker inspect handbook-web --format '{{json .NetworkSettings.Networks}}'
```

Repair it:

```sh
docker network connect handbook-net handbook-web
```

Grade from `handbook/02-docker`:

```sh
sh ./check.sh
```

For comparison only, the existing repository lab still offers its automated answer-key lifecycle with `make up`, `make verify`, and `make down`; do not use that lifecycle for this handbook step.
