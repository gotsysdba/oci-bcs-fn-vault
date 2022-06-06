# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "PodmanLogin" {
  depends_on = [time_sleep.policy_sleep]
  provisioner "local-exec" {
    command = "podman login ${local.oci_podman_repository} --username ${local.oci_namespace}/${local.oci_username} --password-stdin <<< '${oci_identity_auth_token.auth_token.token}'"
  }
  
  provisioner "local-exec" {
    command     = "image=$(podman images ${var.appl_name} -q) ; podman rmi -f $image &> /dev/null ; echo $image"
    working_dir = "${local.project_path}/../fn/${var.appl_name}"
  }
}

resource "null_resource" "BuildFunction" {
  count      = var.scratch_build ? 1 : 0
  depends_on = [null_resource.PodmanLogin]

  provisioner "local-exec" {
    command     = "fn build --verbose"
    working_dir = "${local.project_path}/../fn/${var.appl_name}"
  }
}

resource "null_resource" "LoadFunction" {
  count      = var.scratch_build ? 0 : 1
  depends_on = [null_resource.PodmanLogin]

  provisioner "local-exec" {
    command     = "podman load -i ${var.appl_name}.tar.gz"
    working_dir = "${local.project_path}/../fn"
  }
}

resource "null_resource" "PushFunction" {
  depends_on = [null_resource.BuildFunction, null_resource.LoadFunction]
  provisioner "local-exec" {
    command = "image=$(podman images ${var.appl_name}:0.0.1 -q); podman tag $image ${local.oci_podman_repository}/${local.oci_namespace}/${var.appl_name}:0.0.1"
  }

  provisioner "local-exec" {
    command = "podman push ${local.oci_podman_repository}/${local.oci_namespace}/${var.appl_name}:0.0.1"
  }
}