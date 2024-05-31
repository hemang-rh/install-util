#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

logbanner "Begin installing serverless"
log "Log file: '$LOG_FILE'"

create_subscription(){
    loginfo "Create openshift-serverless subscription"
    oc create -f $SCRIPT_DIR/operators/rh-serverless/serverless-subscription.yaml 2>&1 | tee -a $LOG_FILE
}

verify_csv(){
    loginfo "Verify cluster service version"
    oc get csv 2>&1 | tee -a $LOG_FILE
}

create_subscription
verify_csv

logbanner "End installing serverless"