
# [Fn Project](https://fnproject.io/) - Serverless platform

This directory contains the raw source of the serverless function to copy objects from one OCI bucket to another.

```text
vault-objectstore
 |- func.py          : serverless function python code
 |- func.yaml        : metadata about the function
 |- requirements.txt : required python modules
```

More information about these file can be found [here](https://fnproject.io/tutorials/python/intro/#Understandfunc.yaml)

## Pre-Built Image

A pre-built image vault-objectstore.tar.gz is provided for convenience.  The image can be built from source during Terraform provisioning by updating the terraform/[vars.tf](../terraform/vars.tf) file:

```text
< 
variable "scratch_build" {
  description = "Build the Function from Scratch"
  default     = false
}

>
variable "scratch_build" {
  description = "Build the Function from Scratch"
  default     = true 
}
```

The image can also be manually created and staged.

### Manually Recreating Pre-Built Image

Currently the image must be built on an x86 machine (i.e. not on ARM).  Substitute podman for docker if applicable.

1. Install Podman/Docker and the Fn Project software
2. Copy the `func.py`, `funct.yaml`, and `requirements.txt` files
3. Run `fn build --verbose`
4. Save the image: `docker image save -o vault-objectstore.tar vault-objectstore:0.0.1`
5. Compress the image: `gzip -f vault-objectstore.tar`
6. Clean-up: `docker rmi vault-objectstore:0.0.1`
7. Stage the image to `fn/vault-objectstore.tar.gz`
