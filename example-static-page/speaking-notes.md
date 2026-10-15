# Speaking notes

- I built a repeatable Docker lab that serves a static page through nginx.
- The browser connects to port 8080, which maps to port 80 in the container, and the site is mounted read-only.
- I verify the HTTP response content, then `make down` removes and checks all lab resources.
