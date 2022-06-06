# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

// Basic Hidden
variable "tenancy_ocid" {}
variable "compartment_ocid" {
  default = ""
}
variable "region" {}

// Extra Hidden
variable "current_user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

// General Configuration
variable "res_prefix" {
  description = "Prefix to all OCI Resources created with this code"
  default     = "bcs"
}

variable "appl_name" {
  default = "vault-objectstore"
}

variable "container_engine" {
  description = "Container Engine to be Used (Docker/Podman)"
  default     = "podman"
}

variable "scratch_build" {
  description = "Build the Function from Scratch"
  default     = false
}

variable "database_demo" {
  description = "Provision DBCS database for Demo"
  default     = false
}

// VCN Configurations Variables
variable "vcn_cidr" {
  default = "10.0.0.0/29"
}

variable "vcn_is_ipv6enabled" {
  default = false
}

locals {
  compartment_ocid      = var.compartment_ocid != "" ? var.compartment_ocid : var.tenancy_ocid
  oci_container_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  oci_namespace         = lookup(data.oci_objectstorage_namespace.namespace, "namespace")
  oci_username          = data.oci_identity_user.identity_user.name
  project_path          = abspath(path.root)
  availability_domain   = data.oci_identity_availability_domains.availability_domains.availability_domains[0]["name"]
  bastion_tunnel        = var.database_demo ? format("%s > /dev/null 2>&1 &", replace(replace(
                              replace(oci_bastion_session.bastion_service_ssh[0].ssh_metadata.command, 
                                      "<privateKey>","${abspath(path.module)}/bastion_key"),"\"","'"),
                                      "<localPort>","8091")) : "Demo Disabled"
  ssh_cmd               = var.database_demo ? "ssh -i ${abspath(path.module)}/bastion_key opc@localhost -p 8091 -o StrictHostKeyChecking=no" : "Demo Disabled"
}
