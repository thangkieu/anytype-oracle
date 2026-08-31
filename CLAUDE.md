# CLAUDE.md

Context for Claude Code (or any AI assistant) working in this repository.

## What this repo is

Terragrunt-wrapped Terraform that provisions a single Oracle Cloud (OCI)
Always Free Ampere A1 VM running `any-sync-bundle` (self-hosted Anytype
sync server, all-in-one variant with embedded BadgerDB — no external
Mongo/Redis). Cloud-init bootstraps Docker and starts the container on
first boot, so `terragrunt apply` alone gets to a running server.

Personal single-user infra — not built for multi-tenant or HA use.

## Structure

```
terragrunt.hcl                          # root: generates local backend only
modules/oci-anytype/                    # the actual Terraform module
  versions.tf      # provider requirements + provider block
  variables.tf      # all inputs, incl. auth vars (populated via TF_VAR_*)
  network.tf         # VCN, subnet, IGW, route table, security list
  instance.tf         # data sources (AD, Ubuntu ARM image) + the instance
  outputs.tf          # public IP, ssh command, client-config fetch command
  cloud-init.yaml.tpl  # installs Docker, ufw rules, runs any-sync-bundle
live/singapore/anytype-server/
  terragrunt.hcl       # non-secret inputs for this specific unit
```

Adding another VM/environment = new folder under `live/` pointing `source`
at the same module. Don't duplicate the module's `.tf` files.

## Auth — never put secrets in files

`tenancy_ocid`, `user_ocid`, `fingerprint`, `private_key_path`,
`compartment_ocid` are declared as variables but intentionally **not** set
in any `terragrunt.hcl` or `.tfvars` file. They're expected as `TF_VAR_*`
environment variables (see README.md § 2). If asked to add these values to
a committed file, push back — that's a deliberate choice, not an oversight.

## Resource constraints to respect

- Ampere A1 (ARM) Always Free pool is **2 OCPU / 12GB RAM total**,
  tenancy-wide (Oracle halved this from 4/24 in June 2026, enforced Aug 18
  2026). Current default here is 1 OCPU / 6GB — leaves headroom for a
  second instance later. Don't bump sizing without flagging the tenancy-wide
  cap.
- Ports: 22/tcp (SSH), 33010/tcp and 33020/udp (any-sync-bundle). These are
  opened in *two* places that must stay in sync: `network.tf`'s
  `oci_core_security_list` (OCI-level firewall) and `cloud-init.yaml.tpl`'s
  `ufw` rules (VM-level firewall). Changing one without the other breaks
  connectivity.
- `ssh_allowed_cidr` defaults to `0.0.0.0/0` in the example inputs — should
  be narrowed to the user's own IP for real use, not left open.

## Known operational quirks

- **"Out of host capacity" errors are common** for Ampere A1 in some
  regions/ADs and are not retried by Terraform/Terragrunt automatically.
  The documented workaround is a shell loop around `apply`, not HCL-level
  retry logic — don't try to solve this with `retryable_errors` blocks or
  similar unless specifically asked to change the approach.
- The instance's public IP is discovered **at boot time inside cloud-init**
  via `curl ifconfig.me`, not passed in from Terraform — this sidesteps
  the chicken-and-egg problem of not knowing the IP before the instance
  exists. If any-sync-bundle's `ANY_SYNC_BUNDLE_INIT_EXTERNAL_ADDRS` looks
  wrong, check this step first, not the Terraform outputs.
- State is local (`terraform.tfstate` next to each `live/` unit), not
  remote. This is intentional for a single-user setup. If asked to add
  remote state, OCI Object Storage has an S3-compatible endpoint that
  Terraform's `s3` backend can target — mentioned as a future option in
  the README, not currently wired up.

## Common commands

```bash
cd live/singapore/anytype-server
terragrunt init
terragrunt plan
terragrunt apply          # or the retry-loop version from README § 4
terragrunt output instance_public_ip
terragrunt destroy
```

## Related context (not in this repo)

- Obsidian vault syncs via a separate self-hosted CouchDB + Self-hosted
  LiveSync setup — unrelated infra, don't conflate the two when discussing
  "sync" in this project.
- This VM replaces running any-sync-bundle manually on a laptop, which was
  the original pain point (had to open devices one-by-one to sync).
