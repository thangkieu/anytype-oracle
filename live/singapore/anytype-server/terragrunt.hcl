include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_terragrunt_dir()}/../../../modules/oci-anytype"
}

# Non-secret settings only. Auth (tenancy_ocid, user_ocid, fingerprint,
# private_key_path) is deliberately NOT set here — export those as
# TF_VAR_ environment variables instead so nothing sensitive ends up
# in a file you might commit. See README.md.
inputs = {
  region                   = "ap-singapore-2"
  instance_display_name    = "anytype-server"
  instance_ocpus           = 1
  instance_memory_gb       = 1
  any_sync_bundle_version       = "1.6.0-2026-08-18"
  any_sync_bundle_external_addr = "anytype.purrspective.uk"

  ssh_public_key_path = "~/.ssh/oracle_anytype.pub"

  # Restrict this to your own IP before applying for real, e.g. "203.0.113.42/32"
  ssh_allowed_cidr = "8.29.230.19/32"
  availability_domain_index = 0
}
