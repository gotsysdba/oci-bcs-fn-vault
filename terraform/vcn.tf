# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn" {
  compartment_id = local.compartment_ocid
  display_name   = format("%s-vcn", lower(var.res_prefix))
  cidr_block     = var.vcn_cidr
  is_ipv6enabled = var.vcn_is_ipv6enabled
  dns_label      = replace(lower(var.res_prefix), "-", "")
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s-nat-gateway", lower(var.res_prefix))
}

resource "oci_core_route_table" "route_table_nat_gw" {
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s-route-table-nat-gw", lower(var.res_prefix))
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_subnet" "subnet_private" {
  compartment_id             = local.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = format("%s-subnet-private", lower(var.res_prefix))
  cidr_block                 = var.vcn_cidr
  route_table_id             = oci_core_route_table.route_table_nat_gw.id
  dhcp_options_id            = oci_core_vcn.vcn.default_dhcp_options_id
  dns_label                  = "priv"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_default_security_list" "default_security_list" {
  compartment_id = var.compartment_ocid
  display_name = "Default Security List for bcs1-vcn"
  egress_security_rules {
    description      = "Access to Object Storage for Backup Cloud Service"
    destination      = "134.70.0.0/16"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    description      = "Access to Bastion Tunnel for SSH Access"
    destination      = var.vcn_cidr
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id
}