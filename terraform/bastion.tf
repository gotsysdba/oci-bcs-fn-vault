# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_bastion_bastion" "bastion" {
  count                        = var.database_demo ? 1 : 0
  compartment_id               = local.compartment_ocid
  name                         = format("%s-bastion", lower(var.res_prefix))
  bastion_type                 = "STANDARD"
  target_subnet_id             = oci_core_subnet.subnet_private.id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  max_session_ttl_in_seconds   = "10800"
}

resource "oci_bastion_session" "bastion_service_ssh" {
  count      = var.database_demo ? 1 : 0
  bastion_id = oci_bastion_bastion.bastion[0].id

  key_details {
    public_key_content = tls_private_key.ssh_keys[0].public_key_openssh
  }

  target_resource_details {
    session_type                       = "PORT_FORWARDING"
    target_resource_port               = 22
    target_resource_private_ip_address = data.oci_core_private_ips.dbcs_private_ip[0].private_ips[0].ip_address
  }

  display_name           = format("%s-bastion-service-ssh", lower(var.res_prefix))
  key_type               = "PUB"
  session_ttl_in_seconds = 10800
}