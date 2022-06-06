# Copyright © 2022, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_logging_log_group" "events" {
  compartment_id = local.compartment_ocid
  description  = "Event Logs"
  display_name = "Events"
}

resource "oci_logging_log" "invoke_log" {
  configuration {
    compartment_id = local.compartment_ocid
    source {
      category    = "invoke"
      resource    = oci_functions_application.object_vault.id
      service     = "functions"
      source_type = "OCISERVICE"
    }
  }
  display_name       = format("%s-invoke-log", lower(var.res_prefix))
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.events.id
  log_type           = "SERVICE"
  retention_duration = "30"
}

resource "oci_logging_log" "ruleexecutionlog_log" {
  configuration {
    compartment_id = local.compartment_ocid
    source {
      category    = "ruleexecutionlog"
      resource    = oci_events_rule.object_store_events_rule.id
      service     = "cloudevents"
      source_type = "OCISERVICE"
    }
  }
  display_name       = format("%s-ruleexecutionlog-log", lower(var.res_prefix))
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.events.id
  log_type           = "SERVICE"
  retention_duration = "30"
}