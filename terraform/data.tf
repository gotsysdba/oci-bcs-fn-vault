# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.compartment_ocid
}

data "oci_identity_compartment" "compartment" {
  id = var.compartment_ocid
}

data "oci_identity_compartments" "oci_identity_compartments" {
  compartment_id = var.tenancy_ocid
  access_level   = "ACCESSIBLE"
  name           = data.oci_identity_compartment.compartment.name
  compartment_id_in_subtree = true
}

data "oci_identity_regions" "oci_regions" {
  filter {
    name   = "name"
    values = [var.region]
  }
}

data "oci_identity_user" "identity_user" {
  user_id = var.user_ocid
}

data "oci_core_services" "core_services" {}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.tenancy_ocid
}

data "oci_database_db_nodes" "db_system" {
  count          = var.database_demo ? 1 : 0
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.db_system[0].id
}

# Filter on private IP address and Subnet OCID
data "oci_core_private_ips" "dbcs_private_ip" {
  count     = var.database_demo ? 1 : 0
  subnet_id = oci_core_subnet.subnet_private.id
  vnic_id   = data.oci_database_db_nodes.db_system[0].db_nodes[0].vnic_id
}