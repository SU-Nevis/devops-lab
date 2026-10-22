# Step 2 — run and inspect a real container

## What you will build

You will run a loopback-only nginx service with a bind-mounted page, a persistent volume, a health check, a label, and a user-defined network. A read-only grader proves the complete system.

## Why this matters

Containers package an application and runtime into a repeatable unit. This step shows how the image, container, host port, storage, health, and network fit together before later CI and Kubernetes work automate them.

## Before you start

Finish steps 0 and 1 first. Use Linux or WSL2 with Ubuntu, allow about 30 minutes, and make sure Docker responds to your normal login. Container IDs, elapsed times, and timestamps differ on every machine.

## What you will be able to answer

- **How are images different from containers?**
- **What makes an image layer cacheable?**
- **What is the difference between `EXPOSE` and a published port?**
- **How do health checks, bind mounts, volumes, and container networks work?**

## 1. Create the inputs and run nginx

Time: 4 minutes. Interview question: **How are images different from containers?**

Working directory: repository root.

```sh
mkdir -p ~/devops-lab/02-docker/site && printf '%s\n' '<!doctype html><h1>I built this by hand.</h1>' > ~/devops-lab/02-docker/site/index.html
```

```sh
docker network create handbook-net
```

Real output:

```text
6a2ac3dac4bc9b1ba8fac0aff8a5dfe836a0cde82f328056604c2fe1e7a073d6
```

```sh
docker run -d --name handbook-web -p 127.0.0.1:8088:80 --label devops.handbook=02-docker --network handbook-net --mount type=bind,src="$HOME/devops-lab/02-docker/site",dst=/usr/share/nginx/html,readonly --mount type=volume,src=handbook-data,dst=/var/cache/nginx --health-cmd='wget -q -O - http://127.0.0.1/ >/dev/null 2>&1 || exit 1' --health-interval=2s --health-timeout=2s --health-retries=3 --health-start-period=8s nginx:1.27.5-alpine
```

Real output:

```text
be44f5dd37d2b390ad78766e526219d81952263869a4735651f3e24129482860
```

Why: an image is immutable input; `docker run` creates a distinct container with runtime state, a loopback-only published port, a label, mounts, a network, and a health check.

**If it fails:** If Docker cannot find the image, run `docker pull nginx:1.27.5-alpine`, then repeat the commands in this task.

## 2. List the container and read its logs

Time: 2 minutes. Interview question: **How are images different from containers?**

Working directory: repository root.

```sh
docker ps --filter name=handbook-web --format '{{.Names}} {{.Status}} {{.Ports}}'
```

Real output captured after the health check passed:

```text
handbook-web Up 39 seconds (healthy) 127.0.0.1:8088->80/tcp
```

```sh
docker logs handbook-web 2>&1 | tail -n 2
```

Real output:

```text
127.0.0.1 - - [17/Oct/2026:17:25:53 +0000] "GET / HTTP/1.1" 200 46 "-" "Wget" "-"
127.0.0.1 - - [17/Oct/2026:17:25:55 +0000] "GET / HTTP/1.1" 200 46 "-" "Wget" "-"
```

Why: `docker ps` shows current runtime state while logs expose the process output inside that container.

**If it fails:** If no row appears, run `docker ps -a --filter name=handbook-web` and inspect the container with `docker logs handbook-web`.

## 3. Read one field with `docker inspect`

Time: 1 minute. Interview question: **How are images different from containers?**

Working directory: repository root.

```sh
docker inspect handbook-web --format '{{.Config.Image}}'
```

Real output:

```text
nginx:1.27.5-alpine
```

Why: formatted inspection connects the running container to the image configuration it was created from.

**If it fails:** If Docker says there is no such object, recreate `handbook-web` with the task 1 command.

## 4. Execute a diagnostic command inside the container

Time: 1 minute. Interview question: **How are images different from containers?**

Working directory: repository root.

```sh
docker exec handbook-web nginx -v 2>&1
```

Real output:

```text
nginx version: nginx/1.27.5
```

Why: `docker exec` starts an additional process in an existing running container; it does not create an image layer.

**If it fails:** If the container is stopped, run `docker start handbook-web` and repeat the command.

## 5. Prove `EXPOSE` is not a published port

Time: 2 minutes. Interview question: **What is the difference between `EXPOSE` and a published port?**

Working directory: repository root.

```sh
docker image inspect nginx:1.27.5-alpine --format 'EXPOSE={{json .Config.ExposedPorts}}'
```

Real output:

```text
EXPOSE={"80/tcp":{}}
```

```sh
docker port handbook-web 80/tcp
```

Real output:

```text
127.0.0.1:8088
```

Why: the first command proves image metadata declares a container port; only the second proves `-p` published it on the host.

**If it fails:** If `docker port` prints nothing, recreate the container with `-p 127.0.0.1:8088:80`.

## 6. Inspect the bind mount and named volume

Time: 3 minutes. Interview question: **How do health checks, bind mounts, volumes, and container networks work?**

Working directory: repository root.

```sh
docker inspect handbook-web --format '{{range .Mounts}}{{println .Type .Name .Source "->" .Destination}}{{end}}'
```

Real output:

```text
bind  /home/learner/devops-lab/02-docker/site -> /usr/share/nginx/html
volume handbook-data /var/lib/docker/volumes/handbook-data/_data -> /var/cache/nginx
```

```sh
docker exec handbook-web sh -c 'printf volume-survives > /var/cache/nginx/handbook-marker'
```

```sh
docker exec handbook-web cat /var/cache/nginx/handbook-marker
```

Real output:

```text
volume-survives
```

Why: a bind mount points at the explicit host path while Docker owns the named volume’s storage location.

**If it fails:** If the bind source is missing, run `ls -l ~/devops-lab/02-docker/site/index.html` and recreate task 1's page before recreating the container.

## 7. Delete the container and look again

Time: 4 minutes. Interview question: **How do health checks, bind mounts, volumes, and container networks work?**

Working directory: repository root.

```sh
docker stop handbook-web
```

```sh
docker rm handbook-web
```

Real output:

```text
handbook-web
handbook-web
```

```sh
stat -c '%A %s %n' ~/devops-lab/02-docker/site/index.html
```

```sh
docker volume inspect handbook-data --format '{{.Name}} still exists'
```

Real output:

```text
-rw-r--r-- 46 /home/learner/devops-lab/02-docker/site/index.html
handbook-data still exists
```

Recreate the container:

```sh
docker run -d --name handbook-web -p 127.0.0.1:8088:80 --label devops.handbook=02-docker --network handbook-net --mount type=bind,src="$HOME/devops-lab/02-docker/site",dst=/usr/share/nginx/html,readonly --mount type=volume,src=handbook-data,dst=/var/cache/nginx --health-cmd='wget -q -O - http://127.0.0.1/ >/dev/null 2>&1 || exit 1' --health-interval=2s --health-timeout=2s --health-retries=3 --health-start-period=8s nginx:1.27.5-alpine
```

Real output:

```text
8d0fa5e26e96fe0cc562b1da0fbd4101e831faa9fcaf115289eaf554ee6dcf8f
```

Then read the volume marker:

```sh
docker exec handbook-web cat /var/cache/nginx/handbook-marker
```

Real output:

```text
volume-survives
```

Why: deleting a container deletes neither the host bind source nor the separately managed named volume.

**If it fails:** If the volume marker is missing, run `docker volume inspect handbook-data`, recreate it in the container, and read it again.

## 8. Observe `starting`, then `healthy`

Time: 1 minute. Interview question: **How do health checks, bind mounts, volumes, and container networks work?**

Working directory: repository root. Run this immediately after `docker run`:

```sh
docker ps --filter name=handbook-web --format '{{.Names}} {{.Status}} {{.Ports}}'
```

Real first output:

```text
handbook-web Up Less than a second (health: starting) 127.0.0.1:8088->80/tcp
```

Run the same command after about 10 seconds. Real output:

```text
handbook-web Up 12 seconds (healthy) 127.0.0.1:8088->80/tcp
```

Why: the configured probe moves container health from its start period into a measured healthy state.

**If it fails:** If health becomes unhealthy, run `docker inspect handbook-web --format '{{json .State.Health}}'` and repair the first reported probe error.

## 9. Inventory Docker objects and practise stop/remove

Time: 3 minutes. Interview question: **What makes an image layer cacheable?**

Working directory: repository root.

```sh
docker image ls nginx:1.27.5-alpine --format '{{.Repository}}:{{.Tag}} {{.ID}}'
```

```sh
docker network ls --filter name=handbook-net --format '{{.Name}} {{.Driver}}'
```

```sh
docker volume ls --filter name=handbook-data --format '{{.Name}} {{.Driver}}'
```

Real output:

```text
nginx:1.27.5-alpine 65645c7bb6a0
handbook-net bridge
handbook-data local
```

```sh
docker stop handbook-web
```

```sh
docker rm handbook-web
```

Real output:

```text
handbook-web
handbook-web
```

Recreate the container before task 10:

```sh
docker run -d --name handbook-web -p 127.0.0.1:8088:80 --label devops.handbook=02-docker --network handbook-net --mount type=bind,src="$HOME/devops-lab/02-docker/site",dst=/usr/share/nginx/html,readonly --mount type=volume,src=handbook-data,dst=/var/cache/nginx --health-cmd='wget -q -O - http://127.0.0.1/ >/dev/null 2>&1 || exit 1' --health-interval=2s --health-timeout=2s --health-retries=3 --health-start-period=8s nginx:1.27.5-alpine
```

Why: containers are disposable runtime objects, while the unchanged image layers, network, and volume remain independently listed and reusable.

**If it fails:** If an object is absent, use the matching task 1 command to recreate it before grading.

## Grade your work

From `handbook/02-docker`, run:

```sh
./check.sh
```

The final line of the real passing output is:

```text
Result: 10 passed, 0 failed
```

A full PASS proves all nine Docker criteria plus your notes. The grader only runs read-only Docker, HTTP, and file queries.

## Write your notes

Write three lines: what the PASS proves, the one command you will not forget, and the one thing that broke.

```sh
printf '%s\n' 'PASS proves: ...' 'Command: ...' 'Broke: ...' > ~/devops-lab/02-docker/notes.md
```

Run `./check.sh` again before cleanup.

## Clean up

Remove every object and file this step created:

```sh
docker rm -f handbook-web 2>/dev/null || true
```

```sh
docker network rm handbook-net 2>/dev/null || true
```

```sh
docker volume rm handbook-data 2>/dev/null || true
```

```sh
rm -rf ~/devops-lab/02-docker
```
