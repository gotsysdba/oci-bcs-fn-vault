# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "oci_regions" {}

data "oci_objectstorage_namespace" "objectstorage_namespace" {
  compartment_id = local.compartment_ocid
}

data "oci_identity_compartment" "identity_compartment" {
  id = local.compartment_ocid
}

data "oci_identity_compartments" "identity_compartments" {
  compartment_id            = var.tenancy_ocid
  access_level              = "ACCESSIBLE"
  name                      = data.oci_identity_compartment.identity_compartment.name
  compartment_id_in_subtree = true
}

data "oci_core_services" "core_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.tenancy_ocid
}

data "oci_database_db_nodes" "database_db_nodes" {
  count          = var.database_demo ? 1 : 0
  compartment_id = local.compartment_ocid
  db_system_id   = oci_database_db_system.database_db_system[0].id
}

# Filter on private IP address and Subnet OCID
data "oci_core_private_ips" "core_private_ips" {
  count     = var.database_demo ? 1 : 0
  subnet_id = oci_core_subnet.subnet_private.id
  vnic_id   = data.oci_database_db_nodes.database_db_nodes[0].db_nodes[0].vnic_id
}

# data "oci_identity_users" "identity_user" {
#   compartment_id = var.tenancy_ocid
#   filter {
#     name   = "name"
#     values = [var.iam_user_name]
#   }
# }

data "oci_identity_user" "identity_user" {
  user_id = var.current_user_ocid
}