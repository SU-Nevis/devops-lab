# Step 0 — install your tools

## What you will build

You will prepare a Linux workstation with Docker Engine, GNU Make, curl, and Git, run a real container smoke test, and prove the setup with a read-only grader.

## Why this matters

Every later step uses these tools. A working Docker server and ordinary command-line tools give you a dependable base instead of hiding setup problems inside later exercises.

## Before you start

You need Ubuntu or WSL2 with Ubuntu, an account that can use `sudo`, and about 20 minutes. The proof output was captured on this course machine; patch versions can differ after upgrades.

## What you will be able to answer

- **Foundation for:** How are images different from containers?
- **Foundation for:** What are stdout, stderr, pipes, signals, and shell exit codes?

## 1. Install Docker Engine

Time: 10 minutes. **Foundation for:** How are images different from containers?

Follow Docker's Ubuntu installation instructions, then prove the client and server can talk:

```sh
docker version --format 'Docker client {{.Client.Version}}; server {{.Server.Version}}'
```

Real output:

```text
Docker client 29.1.3; server 29.1.3
```

Run the smoke test:

```sh
docker run --rm hello-world
```

The real output includes:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

**Why:** The version command proves the client reaches the server. The container proves Docker can fetch an image and run it.

**If it fails:** If Docker says it cannot connect, run `sudo systemctl start docker`. If access to `/var/run/docker.sock` is denied, run `sudo usermod -aG docker "$USER"`, sign out completely, sign back in, and retry; do not loosen the socket permissions.

## 2. Install the command-line tools

Time: 5 minutes. **Foundation for:** What are stdout, stderr, pipes, signals, and shell exit codes?

```sh
sudo apt-get update && sudo apt-get install -y make curl git
```

Print one-line versions:

```sh
make --version | sed -n '1p'; curl --version | sed -n '1p'; git --version
```

Real output:

```text
GNU Make 4.4.1
curl 8.18.0 (x86_64-pc-linux-gnu) libcurl/8.18.0 OpenSSL/3.5.5 zlib/1.3.1 brotli/1.2.0 zstd/1.5.7 libidn2/2.3.8 libpsl/0.21.2 libssh2/1.11.1 nghttp2/1.68.0 librtmp/2.3 mit-krb5/1.22.1 OpenLDAP/2.6.10
git version 2.53.0
```

**Why:** Make runs repeatable lab commands, curl checks HTTP services, and Git records changes.

**If it fails:** If `apt-get` cannot find a package, run `sudo apt-get update` and repeat the install command.

## Grade your work

From `handbook/00-setup`, run:

```sh
./check.sh
```

If you ever see `Permission denied`, the file lost its executable bit. Fix it with `chmod +x check.sh` and look at the change with `ls -l check.sh`. Step 1 explains why.

A full PASS proves all four commands exist, the Docker server responds, the smoke-test image is present, and you wrote your notes. The grader only inspects state.

## Write your notes

Write three lines: what the PASS proves, the one command you will not forget, and the one thing that broke.

```sh
mkdir -p ~/devops-lab/00-setup && printf '%s\n' 'PASS proves: ...' 'Command: ...' 'Broke: ...' > ~/devops-lab/00-setup/notes.md
```

Run `./check.sh` again.

## Clean up

Keep the installed tools for the next steps. Remove only the notes made by this step:

```sh
rm -rf ~/devops-lab/00-setup
```
