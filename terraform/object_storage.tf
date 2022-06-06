# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_objectstorage_bucket" "filesystem" {
  access_type           = "NoPublicAccess"
  auto_tiering          = "Disabled"
  compartment_id        = var.compartment_ocid
  name                  = "FILESYSTEM"
  namespace             = data.oci_objectstorage_namespace.namespace.namespace
  object_events_enabled = "false"
  storage_tier          = "Standard"
  versioning            = "Enabled"
}

resource "oci_objectstorage_bucket" "rman_bcs" {
  access_type           = "NoPublicAccess"
  auto_tiering          = "Disabled"
  compartment_id        = var.compartment_ocid
  name                  = "RMAN_BCS"
  namespace             = data.oci_objectstorage_namespace.namespace.namespace
  object_events_enabled = "true"
  storage_tier          = "Standard"
  versioning            = "Disabled"
}

resource "oci_objectstorage_bucket" "rman_bcs_vault" {
  access_type           = "NoPublicAccess"
  auto_tiering          = "Disabled"
  compartment_id        = var.compartment_ocid
  name                  = "RMAN_BCS_VAULT"
  namespace             = data.oci_objectstorage_namespace.namespace.namespace
  object_events_enabled = "false"
  retention_rules {
    display_name = "30_DAY_RETENTION"
    duration {
      time_amount = "30"
      time_unit   = "DAYS"
    }
  }
  storage_tier = "Standard"
  versioning   = "Disabled"
  depends_on   = [ oci_identity_policy.bcs_policy ]
}

resource "oci_objectstorage_object_lifecycle_policy" "rman_bcs_vault" {
  bucket    = oci_objectstorage_bucket.rman_bcs_vault.name
  namespace = oci_objectstorage_bucket.rman_bcs_vault.namespace
  rules {
    action      = "DELETE"
    is_enabled  = "true"
    name        = "31_DAY_LIFECYCLE"
    target      = "objects"
    time_amount = "31"
    time_unit   = "DAYS"
  }
}