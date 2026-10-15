# Live verification — 2026-10-15

Host: WSL2, Docker 29.1.3, Docker Compose 2.40.3.

## Example lab: devops-static-page-lab

```text
make up    -> Container devops-static-page-lab-web-1  Healthy
              0.0.0.0:8080->80/tcp
make verify-> Verification passed: http://127.0.0.1:8080/ returned the expected page.
make down  -> Container removed, Network removed
              Teardown verified: no lab containers, networks, or volumes remain.
post-check -> containers: []  networks: []  volumes: []
              nothing listening on 8080
```

## Template skeleton: devops-lab-template

```text
make up    -> Container devops-lab-template-app-1  Healthy
make verify-> Verification passed: at least one service is running.
make down  -> Teardown verified: no lab containers, networks, or volumes remain.
```

## Negative test — the teardown check can fail

A stray network carrying the project label was planted, then `make down` was run:

```text
Teardown failed: lab Docker resources remain.
networks: wil5-leak-net
exit code: 2
```

So the "nothing remains" message is earned, not printed unconditionally.

## Project-name extraction (both scripts/down.sh)

| compose.yaml line        | result                            |
| ------------------------ | --------------------------------- |
| `name: my-lab`           | `my-lab`                          |
| `name: "my-lab"`         | `my-lab`                          |
| `name: 'my-lab'`         | `my-lab`                          |
| `name: my-lab # a lab`   | `my-lab`                          |
| `name:` (empty)          | exit 1, `needs a name: key`       |
| `name: My Lab`           | exit 1, unusable name             |
| no `name:` key           | exit 1, `needs a name: key`       |

A name that cannot be a legal Compose project name is rejected, so the label
checks can never silently match nothing.
