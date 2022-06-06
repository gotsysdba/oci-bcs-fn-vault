# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "random_password" "db_system_password" {
  count            = var.database_demo ? 1 : 0
  length           = 16
  min_numeric      = 2
  min_lower        = 2
  min_upper        = 2
  min_special      = 2
  override_special = "_#"
}

resource "oci_database_db_system" "db_system" {
  count                   = var.database_demo ? 1 : 0
  availability_domain     = local.availability_domain
  compartment_id          = var.compartment_ocid
  shape                   = "VM.Standard2.1"
  data_storage_size_in_gb = "256"
  database_edition        = "ENTERPRISE_EDITION"
  db_home {
    database {
      admin_password      = random_password.db_system_password[0].result
      character_set       = "AL32UTF8"
      ncharacter_set      = "AL16UTF16"
      db_name             = format("%sDB", upper(var.res_prefix))
      db_workload         = "OLTP"
      tde_wallet_password = random_password.db_system_password[0].result
      pdb_name            = "PDB1"
    }
    db_version   = "21.6.0.0"
    display_name = format("%s-dbhome", lower(var.res_prefix))
  }
  db_system_options {
    storage_management = "LVM"
  }
  disk_redundancy     = "NORMAL"
  display_name        = format("%sDBCS", upper(var.res_prefix))
  domain              = oci_core_subnet.subnet_private.subnet_domain_name
  hostname            = format("%s", lower(var.res_prefix))
  license_model       = "BRING_YOUR_OWN_LICENSE"
  node_count          = "1"
  ssh_public_keys     = [ tls_private_key.ssh_keys[0].public_key_openssh ]
  subnet_id           = oci_core_subnet.subnet_private.id
  nsg_ids             = [ ]
  time_zone           = "UTC"
  source              = null
  source_db_system_id = null
  lifecycle {
      ignore_changes = [ db_home.0.database.0.pdb_name, ssh_public_keys, db_home[0].database[0].admin_password ]
  }
}