# Step 1 — Docker from the driver’s seat

Do this on Linux or WSL2 after `00-setup`. Every command below was run on the course machine. Container IDs and elapsed times will differ on your machine.

## 1. Create the inputs and run nginx

Time: 4 minutes. Interview question: **How are images different from containers?**

Working directory: repository root.

```sh
mkdir -p /tmp/handbook-bind && printf '%s\n' '<!doctype html><h1>I built this by hand.</h1>' > /tmp/handbook-bind/index.html
```

```sh
docker network create handbook-net
```

Real output:

```text
6a2ac3dac4bc9b1ba8fac0aff8a5dfe836a0cde82f328056604c2fe1e7a073d6
```

```sh
docker run -d --name handbook-web -p 127.0.0.1:8088:80 --label devops.handbook=01-docker --network handbook-net --mount type=bind,src=/tmp/handbook-bind,dst=/usr/share/nginx/html,readonly --mount type=volume,src=handbook-data,dst=/var/cache/nginx --health-cmd='wget -q -O - http://127.0.0.1/ >/dev/null 2>&1 || exit 1' --health-interval=2s --health-timeout=2s --health-retries=3 --health-start-period=8s nginx:1.27.5-alpine
```

Real output:

```text
be44f5dd37d2b390ad78766e526219d81952263869a4735651f3e24129482860
```

Why: an image is immutable input; `docker run` creates a distinct container with runtime state, a loopback-only published port, a label, mounts, a network, and a health check.

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

## 6. Inspect the bind mount and named volume

Time: 3 minutes. Interview question: **How do health checks, bind mounts, volumes, and container networks work?**

Working directory: repository root.

```sh
docker inspect handbook-web --format '{{range .Mounts}}{{println .Type .Name .Source "->" .Destination}}{{end}}'
```

Real output:

```text
bind  /tmp/handbook-bind -> /usr/share/nginx/html
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
stat -c '%A %s %n' /tmp/handbook-bind/index.html
```

```sh
docker volume inspect handbook-data --format '{{.Name}} still exists'
```

Real output:

```text
-rw-r--r-- 46 /tmp/handbook-bind/index.html
handbook-data still exists
```

Recreate the container:

```sh
docker run -d --name handbook-web -p 127.0.0.1:8088:80 --label devops.handbook=01-docker --network handbook-net --mount type=bind,src=/tmp/handbook-bind,dst=/usr/share/nginx/html,readonly --mount type=volume,src=handbook-data,dst=/var/cache/nginx --health-cmd='wget -q -O - http://127.0.0.1/ >/dev/null 2>&1 || exit 1' --health-interval=2s --health-timeout=2s --health-retries=3 --health-start-period=8s nginx:1.27.5-alpine
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
docker run -d --name handbook-web -p 127.0.0.1:8088:80 --label devops.handbook=01-docker --network handbook-net --mount type=bind,src=/tmp/handbook-bind,dst=/usr/share/nginx/html,readonly --mount type=volume,src=handbook-data,dst=/var/cache/nginx --health-cmd='wget -q -O - http://127.0.0.1/ >/dev/null 2>&1 || exit 1' --health-interval=2s --health-timeout=2s --health-retries=3 --health-start-period=8s nginx:1.27.5-alpine
```

Why: containers are disposable runtime objects, while the unchanged image layers, network, and volume remain independently listed and reusable.

## 10. Grade, tear down by hand, and prove absence

Time: 3 minutes. Interview question: **How do health checks, bind mounts, volumes, and container networks work?**

Working directory: `handbook/01-docker`.

```sh
sh ./check.sh
```

The final line of the real passing output is:

```text
Result: 9 passed, 0 failed
```

Working directory: repository root.

```sh
docker stop handbook-web
```

```sh
docker rm handbook-web
```

```sh
docker network rm handbook-net
```

```sh
docker volume rm handbook-data
```

Real output:

```text
handbook-web
handbook-web
handbook-net
handbook-data
```

```sh
docker ps -a --filter label=devops.handbook=01-docker --format '{{.Names}}'
```

Real output: no lines.

Why: hand teardown removes each runtime object, and the label query proves no lab container remains.
