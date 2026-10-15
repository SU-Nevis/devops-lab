#!/usr/bin/env sh
set -eu

terraform init -input=false
terraform apply -input=false -auto-approve

url="$(terraform output -raw url)"
attempt=1
while [ "$attempt" -le 30 ]; do
  if curl --fail --silent --show-error "$url" >/dev/null 2>&1; then
    printf 'Lab is serving at %s\n' "$url"
    exit 0
  fi
  sleep 1
  attempt=$((attempt + 1))
done

printf 'Terraform applied, but the lab did not serve HTTP at %s\n' "$url" >&2
exit 1
