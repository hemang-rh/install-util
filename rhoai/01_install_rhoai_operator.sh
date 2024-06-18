#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1
SUCCESS=true

logbanner "Begin installing rhoai operator"
log "Log file: '$LOG_FILE'"

create_namespace() {
    loginfo "Create redhat-ods-operator namespace"
    oc create -f $SCRIPT_DIR/operators/rh-openshift-ai/rhods-operator-namespace.yaml 2>&1 | tee -a $LOG_FILE
}

create_operator_group() {
    loginfo "Create rhods-operator operator group"
    oc create -f $SCRIPT_DIR/operators/rh-openshift-ai/rhods-operator-group.yaml 2>&1 | tee -a $LOG_FILE
}

create_subscription() {
    loginfo "Create rhods-operator subscription"
    oc create -f $SCRIPT_DIR/operators/rh-openshift-ai/rhods-operator-subscription.yaml 2>&1 | tee -a $LOG_FILE
}

verify_installation() {
    loginfo "Verify rhods-operator installation"
    retry_new "oc get csv -n openshift-operators" "rhods-operator" "Succeeded" 
}

verify_projects() {
    # Projects
    oc get projects | grep -i redhat-ods
    if [ $(oc get projects | grep -i redhat-ods | wc -l) -eq 3 ]
    then
        loginfo "3 redhat-ods projects installed"
    else
        logerror "redhat-ods projects not installed"
    fi
}

create_namespace
create_operator_group
create_subscription
verify_installation
verify_projects

logbanner "End installing rhoai operator"