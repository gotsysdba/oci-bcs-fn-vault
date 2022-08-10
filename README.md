# oci-bcs-fn-vault

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=gotsysdba_oci-bcs-fn-vault&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=gotsysdba_oci-bcs-fn-vault) [![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=gotsysdba_oci-bcs-fn-vault&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=gotsysdba_oci-bcs-fn-vault)  ![Verification](https://github.com/gotsysdba/oci-bcs-fn-vault/actions/workflows/push.yml/badge.svg)

## Oracle Backup Cloud Service with Serverless Fn for Vaulting

This IaC sets up a Proof-of-Concept for the Oracle Backup Cloud Service to provide "Tape Vaulting" functionality via a Serverless Fn.

## Architecture



## Assumptions

* An existing OCI tenancy (this IaC POC is not Always Free Eligible)

## Architecture Deployment

There are two main ways to deploy this Architecture:

* Cloud Shell
* Terraform Client (Advanced)

### **Cloud Shell**

Using [Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm) is, by far, the easiest way to manually install this Architecture.

1. Log into your tenancy and launch Cloud Shell
2. Clone this repository: `git clone https://github.com/gotsysdba/oci-bcs-fn-vault`
3. `cd oci-bcs-fn-vault`
4. `source ./cloud-shell.env`
5. (Recommended) To install into a specific compartment, change the TF_VAR_compartment_ocid variable (default root)
    * `export TF_VAR_compartment_ocid=ocid1.compartment....e7e5q`
6. Deploy
    * `cd terraform`
    * `terraform init`
    * `terraform apply`
7. Configure Oracle Cloud Backup Service on the DBCS
    * `cd ..`
    * `./configure-oci-bcs.sh`

### **Terraform Client**
