# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_logging_log_group" "logging_log_group" {
  compartment_id = local.compartment_ocid
  description    = "Event Logs"
  display_name   = format("%s-events-log", lower(var.res_prefix))
}

resource "oci_logging_log" "logging_log_invoke" {
  configuration {
    compartment_id = local.compartment_ocid
    source {
      category    = "invoke"
      resource    = oci_functions_application.functions_application.id
      service     = "functions"
      source_type = "OCISERVICE"
    }
  }
  display_name       = format("%s-invoke-log", lower(var.res_prefix))
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.logging_log_group.id
  log_type           = "SERVICE"
  retention_duration = "30"
}

resource "oci_logging_log" "logging_log_ruleexecutionlog" {
  configuration {
    compartment_id = local.compartment_ocid
    source {
      category    = "ruleexecutionlog"
      resource    = oci_events_rule.events_rule.id
      service     = "cloudevents"
      source_type = "OCISERVICE"
    }
  }
  display_name       = format("%s-ruleexecutionlog-log", lower(var.res_prefix))
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.logging_log_group.id
  log_type           = "SERVICE"
  retention_duration = "30"
}