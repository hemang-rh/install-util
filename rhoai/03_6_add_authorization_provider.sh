#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

logbanner "Begin adding authorization provider"
log "Log file: '$LOG_FILE'"

create_authorino_subscription(){
    loginfo "Create authorino subscription"
    oc create -f $SCRIPT_DIR/operators/rh-authorino/authorino-subscription.yaml 2>&1 | tee -a $LOG_FILE
}

create_namespace(){
    loginfo "Create authorino namespace"
    oc create -f $SCRIPT_DIR/operators/rh-authorino/authorino-namespace.yaml 2>&1 | tee -a $LOG_FILE
}

create_servicemesh_member() {
    loginfo "Create authorino servicemeshmember"
    oc create -f $SCRIPT_DIR/operators/rh-authorino/authorino-smm.yaml 2>&1 | tee -a $LOG_FILE
}

create_instance(){
    loginfo "Create authorino instance"
    oc create -f $SCRIPT_DIR/operators/rh-authorino/authorino-instance.yaml 2>&1 | tee -a $LOG_FILE
}

patch_deployment(){
    loginfo "Patch authorino deployment"
    oc patch deployment authorino -n redhat-ods-applications-auth-provider -p '{"spec": {"template":{"metadata":{"labels":{"sidecar.istio.io/inject":"true"}}}} }' 2>&1 | tee -a $LOG_FILE
}

verify_authorino_instance(){
    loginfo "Verify authorino instance"
    oc get pods -n redhat-ods-applications-auth-provider -o="custom-columns=NAME:.metadata.name,STATUS:.status.phase,CONTAINERS:.spec.containers[*].name" 2>&1 | tee -a $LOG_FILE

    # Expected output
    # NAME                         STATUS    CONTAINERS
    # authorino-6bc64bd667-kn28z   Running   authorino,istio-proxy
}

create_authorino_subscription
create_servicemesh_member
create_instance
patch_deployment

logbanner "End installing authorization provider"
