locals {
  compartment_ocid         = var.compartment_ocid != "" ? var.compartment_ocid : var.tenancy_ocid
  oci_container_repository = join("", [lower(local.prov_region_key), ".ocir.io"])
  oci_namespace            = lookup(data.oci_objectstorage_namespace.objectstorage_namespace, "namespace")
  oci_username             = data.oci_identity_user.identity_user.name
  project_path             = abspath(path.root)
  availability_domain      = data.oci_identity_availability_domains.availability_domains.availability_domains[0]["name"]
  home_region_key          = data.oci_identity_tenancy.tenancy.home_region_key
  home_region_name         = element([for x in data.oci_identity_regions.oci_regions.regions : x.name if x.key == local.home_region_key], 0)
  prov_region_key          = element([for x in data.oci_identity_regions.oci_regions.regions : x.key if x.name == var.region], 0)
}

// Below are used in the output.tf
locals {
  bastion_tunnel = var.database_demo ? format("%s -o 'StrictHostKeyChecking no' > /dev/null 2>&1 &", replace(replace(
    replace(oci_bastion_session.bastion_session[0].ssh_metadata.command,
    "<privateKey>", "${abspath(path.module)}/bastion_key"), "\"", "'"),
  "<localPort>", "8091")) : "Demo DBCS Disabled"
  ssh_cmd = var.database_demo ? "ssh -i ${abspath(path.module)}/bastion_key opc@localhost -p 8091 -o 'StrictHostKeyChecking no'" : "Demo Disabled"
}