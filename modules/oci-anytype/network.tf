resource "oci_core_vcn" "anytype_vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "anytype-vcn"
  dns_label      = "anytypevcn"
}

resource "oci_core_internet_gateway" "anytype_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.anytype_vcn.id
  display_name   = "anytype-igw"
  enabled        = true
}

resource "oci_core_route_table" "anytype_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.anytype_vcn.id
  display_name   = "anytype-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.anytype_igw.id
  }
}

resource "oci_core_security_list" "anytype_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.anytype_vcn.id
  display_name   = "anytype-sl"

  # SSH - restrict via ssh_allowed_cidr, default is open (change this for real use)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.ssh_allowed_cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  # any-sync-bundle TCP
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 33010
      max = 33010
    }
  }

  # any-sync-bundle UDP
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    udp_options {
      min = 33020
      max = 33020
    }
  }

  # Allow all outbound
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "anytype_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.anytype_vcn.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "anytype-subnet"
  dns_label                  = "anytypesub"
  route_table_id             = oci_core_route_table.anytype_rt.id
  security_list_ids          = [oci_core_security_list.anytype_sl.id]
  prohibit_public_ip_on_vnic = false
}
