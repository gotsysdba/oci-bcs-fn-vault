# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_auth_token" "auth_token" {
    description = var.appl_name
    user_id     = var.current_user_ocid
}