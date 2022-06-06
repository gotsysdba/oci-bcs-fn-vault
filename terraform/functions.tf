# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_functions_application" "object_vault" {
  compartment_id = local.compartment_ocid
  display_name   = var.appl_name
  subnet_ids     = [oci_core_subnet.subnet_private.id]
  trace_config {
    is_enabled = "false"
  }
}

resource "oci_functions_function" "object_vault" {
  application_id     = oci_functions_application.object_vault.id
  display_name       = var.appl_name
  image              = "${local.oci_container_repository}/${local.oci_namespace}/${var.appl_name}:0.0.1"
  memory_in_mbs      = "256"
  timeout_in_seconds = "30"
  trace_config {
    is_enabled = "false"
  }
  depends_on = [ null_resource.PushFunction ]
}
