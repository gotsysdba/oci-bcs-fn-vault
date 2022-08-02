#!/bin/env python3

# Copyright (c) 2016, 2022, Oracle and/or its affiliates.  All rights reserved.
# This software is dual-licensed to you under the Universal Permissive License (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose either license.
import oci, argparse

##############################################################################
# Local Functions
##############################################################################
## Print Header Center Bold
def print_center_bold(msg, width=80):
    print("\033[1m{}\033[0m".format(msg.center(width, "=")))

## Set Configuration Values, override defaults
def set_value(key, arg, config):
    value = arg
    if not arg:
        try:
            value = config[key]
        except KeyError:
            value = None
    return value

## Get the Object Storage Namespace - Verifies Connectivity
def get_namespace(client):
    print_center_bold("Connecting to Object Storage")
    try:
        namespace = client.get_namespace().data
        print("Namespace: {}".format(namespace))
    except Exception as e:
        raise SystemExit("\nError connecting to object storage - {}".format(e))
    return namespace

## list_object_storage
def list_object_storage(client, namespace, bucket, object_list):
    next_starts_with = None
    while True:
        try:
            response = client.list_objects(namespace, bucket, start=next_starts_with, prefix=None)
        except Exception as e:
            raise SystemExit(e.message)
        next_starts_with = response.data.next_start_with
        for object_file in response.data.objects:
            if not object_file.name.startswith('sbt_catalog'):
                continue
            object_list.append("'" + str(object_file.name).split("/")[1]+ "'")

        return object_list

##############################################################################
# MAIN
##############################################################################
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Object Store RMAN Re-catalog')
    parser.add_argument('-b', required=False, default=None, dest='bucket', help='Bucket Name')
    parser.add_argument('-c', required=False, dest='config_file', help="Config File (default=~/.oci/config)")
    parser.add_argument('-t', required=False, dest='config_profile', help='Config file section to use (DEFAULT)')
    parser.add_argument('-p', required=False, default=None, dest='proxy', help='Set Proxy (i.e. www-proxy-server.com:80) ')
    args = parser.parse_args()

    # Update Variables based on the parameters
    config_file = (args.config_file if args.config_file else oci.config.DEFAULT_LOCATION)
    config_profile = (args.config_profile if args.config_profile else oci.config.DEFAULT_PROFILE)

    try:
        config = oci.config.from_file(
            (config_file if config_file else oci.config.DEFAULT_LOCATION),
            (config_profile if config_profile else oci.config.DEFAULT_PROFILE))
    except Exception as e:
        raise SystemExit(e)

    # Test for input overrides and config values
    bucket = set_value('bucket', args.bucket, config)
    proxy  = set_value('proxy', args.proxy, config)

    if not bucket:
        raise SystemExit('-b <bucket> is required')

    # Establish the ObjStorage Client
    object_storage_client = oci.object_storage.ObjectStorageClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
    if proxy:
        object_storage_client.base_client.session.proxies = {'https': proxy}
    namespace = get_namespace(object_storage_client)

    # Get a list of files in the bucket (this also verifies the existence of bucket)
    objects = []
    objects = list_object_storage(object_storage_client, namespace, bucket, objects)

    print_center_bold("Generating Catalog Script for Backup Pieces in {} Bucket".format(bucket))
    f = open("cloud_catalog_vault.rman", "w")
    f.write('catalog device type \'sbt_tape\' backuppiece ' + ','.join(objects) + ';')
    f.close()
    print("Catalog Script Generated; run 'rman target / @cloud_catalog_vault.rman'")