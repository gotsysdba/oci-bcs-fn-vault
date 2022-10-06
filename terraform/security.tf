# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_dynamic_group" "dynamic_group" {
  provider       = oci.homeregion
  compartment_id = var.tenancy_ocid
  name           = "OBCS_Functions"
  description    = "Function Dynamic Group"
  matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${local.compartment_ocid}'}"
}

# Assign the resource to this compartments parent
# These policies allow the function to manage objects and to enable lifecycle on the vault
resource "oci_identity_policy" "bcs_policy" {
  provider       = oci.homeregion
  compartment_id = data.oci_identity_compartments.identity_compartments.compartments.*.compartment_id[0]
  description    = "Oracle Backup Cloud Service Object Storage Policies"
  name           = "OBCS_Object_Store"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.dynamic_group.id} to manage objects in compartment id ${local.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.dynamic_group.id} to manage buckets in compartment id ${local.compartment_ocid}",
    "Allow service objectstorage-${var.region} to manage object-family in compartment id ${local.compartment_ocid}"
  ]
}

# Policies can take some time to become effective, have a nap
resource "time_sleep" "policy_sleep" {
  depends_on      = [oci_identity_policy.bcs_policy]
  create_duration = "120s"
}