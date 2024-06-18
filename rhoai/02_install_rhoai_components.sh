#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

logbanner "Begin installing rhoai component"
log "Log file: '$LOG_FILE'"

create_datascience_cluster(){
    loginfo "Create datascience cluster"
    oc create -f $SCRIPT_DIR/operators/rh-openshift-ai/rhods-operator-dsc.yaml 2>&1 | tee -a $LOG_FILE
}

create_datascience_cluster
loginfo "Wait for 120 seconds"
sleep 120

logbanner "End installing rhoai component"