locals {
  compartment_ocid         = var.compartment_ocid != "" ? var.compartment_ocid : var.tenancy_ocid
  oci_container_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  oci_namespace            = lookup(data.oci_objectstorage_namespace.namespace, "namespace")
  oci_username             = data.oci_identity_user.identity_user.name
  project_path             = abspath(path.root)
  availability_domain      = data.oci_identity_availability_domains.availability_domains.availability_domains[0]["name"]
  bastion_tunnel = var.database_demo ? format("%s > /dev/null 2>&1 &", replace(replace(
    replace(oci_bastion_session.bastion_service_ssh[0].ssh_metadata.command,
    "<privateKey>", "${abspath(path.module)}/bastion_key"), "\"", "'"),
  "<localPort>", "8091")) : "Demo DBCS Disabled"
  ssh_cmd = var.database_demo ? "ssh -i ${abspath(path.module)}/bastion_key opc@localhost -p 8091 -o StrictHostKeyChecking=no" : "Demo Disabled"
}