# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_events_rule" "events_rule" {
  actions {
    actions {
      action_type = "FAAS"
      description = "Create/Update Vaulted Objects"
      function_id = oci_functions_function.functions_function.id
      is_enabled  = "true"
    }
  }
  compartment_id = local.compartment_ocid
  condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\",\"com.oraclecloud.objectstorage.updateobject\"],\"data\":{\"resourceName\":[\"file_chunk/*VAULT*\",\"sbt_catalog/*VAULT*\"],\"additionalDetails\":{\"bucketName\":[\"RMAN_BCS\"]}}}"
  display_name   = format("%s-events-rule", lower(var.appl_name))
  is_enabled     = "true"
}