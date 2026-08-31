# Root config, included by every unit under live/.
# Generates a local backend so each unit gets its own state file next to it.
# For a personal single-VM setup this is fine — no need for remote state
# infrastructure. If you later want remote state, OCI Object Storage has an
# S3-compatible endpoint you can point Terraform's "s3" backend at.

remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
