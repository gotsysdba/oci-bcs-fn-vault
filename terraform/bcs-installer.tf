# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data template_file "bcs_installer" {
  count    = var.database_demo ? 1 : 0
  template = file("${path.module}/templates/bcs-installer.tmpl")

  vars = {
    bastion_key           = "${abspath(path.module)}/bastion_key"
    bastion_tunnel        = local.bastion_tunnel
    oci_priv_key_path     = var.private_key_path
    oci_region            = var.region
    oci_fingerprint       = var.fingerprint
    oci_tenancy_ocid      = var.tenancy_ocid
    oci_user_ocid         = var.user_ocid
    oci_compartment_ocid  = var.compartment_ocid
  }
}

resource "local_file" "bcs_installer" {
  count           = var.database_demo ? 1 : 0
  content         = "${data.template_file.bcs_installer[0].rendered}"
  filename        = "${path.module}/../bcs-installer.ksh"
  file_permission = 0700
}