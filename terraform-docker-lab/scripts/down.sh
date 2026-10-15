#!/usr/bin/env sh
set -eu

# Read the evaluated variable rather than duplicating or parsing its default.
lab_name="$(printf 'var.lab_name\n' | terraform console | sed -n 's/^"\(.*\)"$/\1/p')"
case "$lab_name" in
  '')
    printf '%s\n' 'Terraform variable lab_name must not be empty.' >&2
    exit 1
    ;;
  *[!a-z0-9_-]* )
    printf 'Terraform variable lab_name is unusable for a label query (%s).\n' "$lab_name" >&2
    exit 1
    ;;
esac

terraform destroy -input=false -auto-approve

# Names, not IDs, so a failure says exactly what leaked.
containers="$(docker ps --all --filter "label=devops.lab=${lab_name}" --format '{{.Names}}')"
if [ -n "$containers" ]; then
  printf 'Teardown failed: lab Docker resources remain.\ncontainers: %s\n' "$containers" >&2
  exit 1
fi

printf 'Teardown verified: no Docker resources labeled devops.lab=%s remain.\n' "$lab_name"
