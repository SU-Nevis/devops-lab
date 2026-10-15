#!/usr/bin/env sh
set -eu

terraform fmt -check
terraform validate

url="$(terraform output -raw url)"
body="$(curl --fail --silent --show-error "$url")"
printf '%s' "$body" | grep -Fq 'Terraform made this container.'
printf 'Verification passed: %s served the expected page.\n' "$url"
