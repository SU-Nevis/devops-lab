# Terraform Docker Lab

## Goal

Declare a pinned nginx container with Terraform, verify its real HTTP response, and prove that destroy leaves no labeled resource behind. The Docker provider keeps the lab local: no cloud account, credentials, or bill.

## Architecture

The editable diagram is [`architecture.mmd`](architecture.mmd): `terraform apply` calls the Docker provider, which creates the nginx container; the repository CI matrix drives the same lifecycle.

## Prerequisites

- Linux
- Docker
- Terraform 1.16.6
- GNU Make and `curl`

## Run it

```sh
make up
make verify
make down
```

`make up` initializes Terraform, applies the declaration, and waits for HTTP. `make verify` runs `terraform fmt -check`, `terraform validate`, and an assertion against the URL read from `terraform output`. `make down` destroys the managed resources and then independently queries Docker for the lab label; it fails and names any leaked container.

## One-place rename rule

Change only `lab_name`'s default in [`variables.tf`](variables.tf). The container name becomes `${lab_name}-web`, and the `devops.lab` label used by teardown becomes the same value. Terraform outputs the resulting container name; no script duplicates the default.

## State and the lock file

Local `terraform.tfstate` records the real resource identities Terraform manages and can contain sensitive values in other projects, so state and `.terraform/` are ignored. `.terraform.lock.hcl` records the selected provider checksums and is committed so every checkout installs the reviewed provider build. State is environment data; the lock file is reproducibility metadata.

The nginx image uses the explicit `1.27.5-alpine` tag. A digest is even more immutable, but a multi-platform tag keeps this learning lab usable on both amd64 and arm64 runners while preventing an accidental major/minor upgrade.

CI uses `hashicorp/setup-terraform` pinned to a full action commit. The stricter alternative is downloading the pinned Terraform release and verifying HashiCorp's published checksum; the pinned action is sufficient here because the action code and requested CLI version are both explicit and reviewable.

## Explore plans safely

`make plan` is an optional read-only view. Delete the container manually and Terraform plans to recreate the missing object (drift). Change `image_tag` temporarily and it plans to replace the container whose image changed. Revert temporary edits before applying.
