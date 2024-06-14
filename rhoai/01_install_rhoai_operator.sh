#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

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
    loginfo "Verify installation"
    # Operator
    if oc get operators | grep rhods-operator.redhat-ods.operator; then
        loginfo "rhods-operator.redhat-ods.operator installed"
    else
        logerror "rhods-operator.redhat-ods.operator not installed"
    fi
    loginfo "Wait for 120 seconds for projects to be created"
    sleep 120
    
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

logbanner "End installing rhoai operator"