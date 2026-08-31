data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Latest Ubuntu 24.04 ARM (aarch64) image for this region
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order                = "DESC"
}

resource "oci_core_instance" "anytype_server" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = var.instance_display_name
  shape                = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.anytype_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data            = base64encode(templatefile("${path.module}/cloud-init.yaml.tpl", {
      any_sync_bundle_version       = var.any_sync_bundle_version
      any_sync_bundle_external_addr = var.any_sync_bundle_external_addr
    }))
  }

  # Retry note: Ampere A1 capacity errors happen at the OCI backend level.
  # Terraform will just fail the apply when this happens — see README for
  # the retry-loop workaround instead of trying to solve it in HCL.

}
