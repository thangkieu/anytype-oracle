# ── Auth (from OCI Console → Profile → API Keys) ────────────────────────────
variable "tenancy_ocid" {
  description = "OCID of your tenancy (Profile menu → Tenancy)"
  type        = string
}

variable "user_ocid" {
  description = "OCID of your user (Profile menu → User Settings)"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API signing key you generated"
  type        = string
}

variable "private_key_path" {
  description = "Local path to the private API signing key (e.g. ~/.oci/oci_api_key.pem)"
  type        = string
}

variable "region" {
  description = "OCI region identifier"
  type        = string
  default     = "ap-singapore-2"
}

variable "compartment_ocid" {
  description = "Compartment to create resources in — use tenancy_ocid for root compartment"
  type        = string
}

# ── Instance sizing (stay within Always Free ARM pool: 2 OCPU / 12GB total) ─
variable "instance_ocpus" {
  description = "OCPUs for the Ampere A1.Flex instance"
  type        = number
  default     = 1
}

variable "instance_memory_gb" {
  description = "Memory in GB for the Ampere A1.Flex instance"
  type        = number
  default     = 6
}

variable "instance_display_name" {
  description = "Display name for the instance"
  type        = string
  default     = "anytype-server"
}

# ── SSH access ───────────────────────────────────────────────────────────────
variable "ssh_public_key_path" {
  description = "Local path to your SSH public key (e.g. ~/.ssh/oracle_anytype.pub)"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH in. Restrict this to your own IP (e.g. 1.2.3.4/32) rather than leaving it open to the internet."
  type        = string
  default     = "0.0.0.0/0"
}

# ── any-sync-bundle ──────────────────────────────────────────────────────────
variable "any_sync_bundle_version" {
  description = "Image tag for ghcr.io/grishy/any-sync-bundle"
  type        = string
  default     = "1.4.3-2026-04-21"
}

variable "availability_domain_index" {
  description = "Index of the availability domain to use (0, 1, or 2). Change if you get Out of Host Capacity errors."
  type        = number
  default     = 0
}

variable "any_sync_bundle_external_addr" {
  description = "External address advertised to clients (e.g. anytype.example.com). Defaults to auto-detected public IP if empty."
  type        = string
  default     = ""
}
