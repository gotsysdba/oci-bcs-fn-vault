# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_artifacts_container_repository" "container_repository" {
  compartment_id = local.compartment_ocid
  display_name   = var.appl_name
  is_immutable   = false
  is_public      = false
}