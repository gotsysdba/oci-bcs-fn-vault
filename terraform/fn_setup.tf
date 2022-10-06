# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "RepoLogin" {
  depends_on = [time_sleep.policy_sleep, oci_identity_policy.bcs_policy]
  provisioner "local-exec" {
    command = "${var.container_engine} login ${local.oci_container_repository} --username ${local.oci_namespace}/${local.oci_username} --password-stdin <<< \"${oci_identity_auth_token.identity_auth_token.token}\""
  }

  provisioner "local-exec" {
    command     = "image=$(${var.container_engine} images ${var.appl_name} -q) ; ${var.container_engine} rmi -f $image &> /dev/null ; echo $image"
    working_dir = "${local.project_path}/../fn/${var.appl_name}"
  }
}

resource "null_resource" "BuildFunction" {
  count      = var.scratch_build ? 1 : 0
  depends_on = [null_resource.RepoLogin]

  provisioner "local-exec" {
    command     = "fn build --verbose"
    working_dir = "${local.project_path}/../fn/${var.appl_name}"
  }
}

resource "null_resource" "LoadFunction" {
  count      = var.scratch_build ? 0 : 1
  depends_on = [null_resource.RepoLogin]

  provisioner "local-exec" {
    command     = "${var.container_engine} load -i ${var.appl_name}.tar.gz"
    working_dir = "${local.project_path}/../fn"
  }
}

resource "null_resource" "PushFunction" {
  depends_on = [null_resource.BuildFunction, null_resource.LoadFunction, oci_artifacts_container_repository.container_repository]
  provisioner "local-exec" {
    command = "image=$(${var.container_engine} images ${var.appl_name}:0.0.1 -q); ${var.container_engine} tag $image ${local.oci_container_repository}/${local.oci_namespace}/${var.appl_name}:0.0.1"
  }

  provisioner "local-exec" {
    command = "${var.container_engine} push ${local.oci_container_repository}/${local.oci_namespace}/${var.appl_name}:0.0.1"
  }
}
