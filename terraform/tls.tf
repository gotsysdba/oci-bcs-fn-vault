# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "tls_private_key" "ssh_keys" {
  count     = var.database_demo ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "4096"
}

// Create a file called bastion_key with the private key used for the bastion in terraform
resource "local_file" "private_key" {
  count           = var.database_demo ? 1 : 0
  content         = tls_private_key.ssh_keys[0].private_key_openssh
  filename        = "${path.module}/bastion_key"
  file_permission = 0600
}