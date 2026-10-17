#!/bin/sh
set -eu
docker network disconnect handbook-net handbook-web >/dev/null
