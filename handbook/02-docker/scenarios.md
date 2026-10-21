# Docker practice scenarios

Each scenario gives a goal and an objective success test, not a solution.

1. **Move the host port.** Goal: serve the same page on loopback port 8090. Success test: `curl --fail http://127.0.0.1:8090/` prints `I built this by hand.` Put the published port back to `127.0.0.1:8088:80` before you run the grader.
2. **Replace the page.** Goal: serve a second message through the bind mount without rebuilding an image. Success test: `docker exec handbook-web cat /usr/share/nginx/html/index.html` and host `cat` output match.
3. **Prove volume persistence.** Goal: store a marker in `handbook-data`, replace the container, and retrieve it. Success test: a new container reads the exact marker.
4. **Add a network peer.** Goal: start a labeled temporary container that reaches `handbook-web` by container name. Success test: its HTTP request exits zero without using the published host port.
5. **Detect an unhealthy service.** Goal: create a disposable container whose health command fails. Success test: `docker ps` reports `(unhealthy)` and `docker inspect` shows a non-zero health-check exit code.
