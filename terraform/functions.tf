# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_functions_application" "functions_application" {
  compartment_id = local.compartment_ocid
  display_name   = format("%s-application", lower(var.appl_name))
  subnet_ids     = [oci_core_subnet.subnet_private.id]
  trace_config {
    is_enabled = "false"
  }
}

resource "oci_functions_function" "functions_function" {
  application_id     = oci_functions_application.functions_application.id
  display_name       = format("%s-function", lower(var.appl_name))
  image              = "${local.oci_container_repository}/${local.oci_namespace}/${var.appl_name}:0.0.1"
  memory_in_mbs      = "128"
  timeout_in_seconds = "30"
  trace_config {
    is_enabled = "false"
  }
  depends_on = [null_resource.PushFunction]
}