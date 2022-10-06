# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

// Basic Hidden
variable "tenancy_ocid" {}
variable "compartment_ocid" {
  default = ""
}
variable "iam_user_name" {
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
  default     = "bcs1"
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
  default     = true
}

// VCN Configurations Variables - Avoid Shrinking as Fn requires a few
variable "vcn_cidr" {
  default = "10.0.100.0/28"
}

variable "vcn_is_ipv6enabled" {
  default = false
}
