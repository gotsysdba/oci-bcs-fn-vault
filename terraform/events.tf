# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_events_rule" "object_store_events_rule" {
  actions {
    actions {
      action_type = "FAAS"
      description = "Create/Update Vaulted Objects"
      function_id = oci_functions_function.object_vault.id
      is_enabled  = "true"
    }
  }
  compartment_id = var.compartment_ocid
  condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\",\"com.oraclecloud.objectstorage.updateobject\"],\"data\":{\"resourceName\":[\"file_chunk/*VAULT*\",\"sbt_catalog/*VAULT*\"],\"additionalDetails\":{\"bucketName\":[\"RMAN_BCS\"]}}}"
  display_name   = var.appl_name
  is_enabled     = "true"
}