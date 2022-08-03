#!/bin/env bash
## Copyright © 2022, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Globals
declare -r ORATAB_FILE="/etc/oratab"
declare -r ORAENV_FILE="/usr/local/bin/oraenv"
declare -r RMAN_SCRIPTS_DIR="/home/oracle/rman"

# Inputs
declare -r DB_SID=$1
declare -r RMAN_SCRIPT=$2

# Check Inputs
if [[ -z ${DB_SID} ]] || [[ -z ${RMAN_SCRIPT} ]]; then
    echo "Usage: $0 <db_sid> <rman_script>"
    exit 1
fi

# Check DB_SID exists to set env
echo "Looking for ${DB_SID} in ${ORATAB_FILE}"
if (( $(grep -ic -- ^${DB_SID}:.*$ ${ORATAB_FILE}) == 0 )); then
    echo "SID ${DB_SID} not found in ${ORATAB_FILE}"
    exit 1
fi

# Set the Environment
export ORAENV_ASK=NO
export ORACLE_SID=${DB_SID}
if [[ -x ${ORAENV_FILE} ]]; then
    export PATH=${PATH}:${ORAENV_FILE%\/*}
    . oraenv
fi

# Check RMAN_SCRIPT
if [[ ! -f ${RMAN_SCRIPTS_DIR}/${RMAN_SCRIPT} ]]; then
    echo "${RMAN_SCRIPTS_DIR}/${RMAN_SCRIPT} not found."
    exit 1
fi

# Run RMAN_SCRIPT against DB_SID
echo "Starting Backup at $(date)"
${ORACLE_HOME}/bin/rman <<-EORMAN
    @${RMAN_SCRIPTS_DIR}/${RMAN_SCRIPT}
EORMAN
declare -i rman_exit=$?
echo "Finished Backup at $(date)"
exit $rman_exit