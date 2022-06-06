# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "bastion_ssh_cmd" {
  value = local.ssh_cmd
}

// Output the bastion session ssh command, replace <privateKey> with local_file.private_key and remove derefs
output "bastion_tunnel_cmd" {
  value = local.bastion_tunnel
}