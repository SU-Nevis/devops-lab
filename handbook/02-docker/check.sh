#!/bin/sh
# Inspection only: this script queries Docker and HTTP; it never changes state.
set -u
failures=0; total=10
site=${HOME:?HOME is not set}/devops-lab/02-docker/site
pass() { printf 'PASS %-20s %s\n' "$1" "$2"; }
fail() { printf 'FAIL %-20s %s | Inspect: %s\n' "$1" "$2" "$3"; failures=$((failures + 1)); }
inspect_value() { docker inspect handbook-web --format "$1" 2>/dev/null; }
printf 'Docker grader (inspection only)\n\n'
if [ "$(inspect_value '{{.State.Running}}')" = true ]; then pass 'container.running' 'handbook-web is running'; else fail 'container.running' 'run handbook-web' 'docker ps -a --filter name=handbook-web'; fi
if [ "$(inspect_value '{{index .Config.Labels "devops.handbook"}}')" = 02-docker ]; then pass 'container.label' 'lab label is present'; else fail 'container.label' 'add devops.handbook=02-docker' "docker inspect handbook-web --format '{{json .Config.Labels}}'"; fi
if docker port handbook-web 80/tcp 2>/dev/null | grep -qx '127.0.0.1:8088'; then pass 'port.loopback' '80/tcp is published only on 127.0.0.1:8088'; else fail 'port.loopback' 'publish 127.0.0.1:8088:80' 'docker port handbook-web'; fi
if [ "$(inspect_value '{{json .Config.ExposedPorts}}')" = '{"80/tcp":{}}' ]; then pass 'image.expose' 'image metadata exposes 80/tcp'; else fail 'image.expose' 'use an image exposing 80/tcp' "docker inspect handbook-web --format '{{json .Config.ExposedPorts}}'"; fi
if [ "$(inspect_value '{{range .Mounts}}{{if eq .Type "bind"}}{{.Source}} -> {{.Destination}}{{end}}{{end}}')" = "$site -> /usr/share/nginx/html" ]; then pass 'mount.bind' 'bind mount serves the host directory'; else fail 'mount.bind' 'mount ~/devops-lab/02-docker/site at nginx document root' "docker inspect handbook-web --format '{{json .Mounts}}'"; fi
if [ "$(inspect_value '{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}} -> {{.Destination}}{{end}}{{end}}')" = 'handbook-data -> /var/cache/nginx' ]; then pass 'mount.volume' 'named volume is attached'; else fail 'mount.volume' 'attach handbook-data at /var/cache/nginx' "docker inspect handbook-web --format '{{json .Mounts}}'"; fi
if [ "$(inspect_value '{{if .Config.Healthcheck}}configured{{end}}')" = configured ] && [ "$(inspect_value '{{.State.Health.Status}}')" = healthy ]; then pass 'health.healthy' 'health check is configured and healthy'; else fail 'health.healthy' 'configure the health check and wait for healthy' "docker inspect handbook-web --format '{{json .State.Health}}'"; fi
if [ "$(inspect_value '{{if index .NetworkSettings.Networks "handbook-net"}}attached{{end}}')" = attached ]; then pass 'network.attached' 'container is attached to handbook-net'; else fail 'network.attached' 'attach handbook-web to handbook-net' "docker inspect handbook-web --format '{{json .NetworkSettings.Networks}}'"; fi
if curl --fail --silent http://127.0.0.1:8088/ 2>/dev/null | grep -Fq 'I built this by hand.'; then pass 'http.content' 'HTTP serves the bind-mounted page'; else fail 'http.content' 'repair the service or mounted page' 'curl --fail --show-error http://127.0.0.1:8088/'; fi
notes=${HOME:?HOME is not set}/devops-lab/02-docker/notes.md
if [ -s "$notes" ]; then pass 'notes.written' 'notes.md exists and is not empty'; else fail 'notes.written' 'write three lines in ~/devops-lab/02-docker/notes.md' "ls -l '$notes'"; fi
printf '\nResult: %s passed, %s failed\n' "$((total - failures))" "$failures"
if [ "$failures" -gt 0 ]; then printf 'Next: fix the first FAIL, then run ./check.sh again.\n'; else printf 'Done: the handbook road ends here for now.\n'; fi
[ "$failures" -eq 0 ]
