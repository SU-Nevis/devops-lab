# Speaking notes

- Goal: declare a small, observable Docker service with Terraform without a cloud account or bill.
- Terraform decides the dependency order: pull the image first, then create the container that refers to its image ID.
- Verification checks formatting and configuration, then follows Terraform's URL output and asserts the live HTTP response.
- Destroy is a test: after Terraform removes its state-managed objects, an independent Docker label query proves no lab container remains.
