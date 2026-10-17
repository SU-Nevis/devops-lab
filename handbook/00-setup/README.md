# Step 0 — install the tools for lab 1

Use Ubuntu or WSL2 with Ubuntu. The proof output below was captured on the course machine; patch-level output can differ after an upgrade.

## 1. Docker Engine

Working directory: any directory. Time: 8 minutes.

```sh
sudo apt-get update && sudo apt-get install -y ca-certificates curl && sudo install -m 0755 -d /etc/apt/keyrings && sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && sudo chmod a+r /etc/apt/keyrings/docker.asc
```

```sh
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null && sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Prove client and server versions:

```sh
docker version --format 'Docker client {{.Client.Version}}; server {{.Server.Version}}'
```

Real output:

```text
Docker client 29.1.3; server 29.1.3
```

Run the installation smoke test:

```sh
docker run --rm hello-world
```

The real output ends with:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## 2. GNU Make

Working directory: any directory. Time: 2 minutes.

```sh
sudo apt-get update && sudo apt-get install -y make
```

```sh
make --version | sed -n '1p'
```

Real output:

```text
GNU Make 4.4.1
```

## 3. curl

Working directory: any directory. Time: 2 minutes.

```sh
sudo apt-get update && sudo apt-get install -y curl
```

```sh
curl --version | sed -n '1p'
```

Real output:

```text
curl 8.18.0 (x86_64-pc-linux-gnu) libcurl/8.18.0 OpenSSL/3.5.5 zlib/1.3.1 brotli/1.2.0 zstd/1.5.7 libidn2/2.3.8 libpsl/0.21.2 libssh2/1.11.1 nghttp2/1.68.0 librtmp/2.3 mit-krb5/1.22.1 OpenLDAP/2.6.10
```

## 4. Git

Working directory: any directory. Time: 2 minutes.

```sh
sudo apt-get update && sudo apt-get install -y git
```

```sh
git --version
```

Real output:

```text
git version 2.53.0
```

## 5. Grade the setup

Working directory: `handbook/00-setup`. Time: 1 minute.

```sh
sh ./check.sh
```

The grader only inspects commands, the Docker server, and the already-pulled smoke-test image. It never installs or starts anything.

## Two common Docker failures

- `Cannot connect to the Docker daemon`: start it with `sudo systemctl start docker`, then retry `docker info`.
- `permission denied ... /var/run/docker.sock`: run `sudo usermod -aG docker "$USER"`, sign out completely, sign back in, and retry `docker info`. Do not loosen the socket permissions.
