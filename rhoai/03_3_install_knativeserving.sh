#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

logbanner "Begin installing knative serving"
log "Log file: '$LOG_FILE'"

create_namespace() {
    loginfo "Create knative-serving namespace"
    oc create ns knative-serving 2>&1 | tee -a $LOG_FILE
}

create_servicemesh_member() {
    loginfo "Create service mesh member"
    oc apply -f $SCRIPT_DIR/components/kserve/default-smm.yaml 2>&1 | tee -a $LOG_FILE
}

create_knativeserving(){
    loginfo "Create knative-serving subscription"
    oc create -f $SCRIPT_DIR/components/kserve/knativeserving-istio.yaml 2>&1 | tee -a $LOG_FILE
}

review_servicemeshmemberroll() {
    loginfo "Review service mesh member roll"
    oc describe smmr default -n istio-system 2>&1 | tee -a $LOG_FILE
    oc get smmr default -n istio-system -o jsonpath='{.status.memberStatuses}' 2>&1 | tee -a $LOG_FILE
}

verify_pods(){
    loginfo "Verify pods are created"
    oc get pods -n knative-serving 2>&1 | tee -a $LOG_FILE
}

create_namespace
create_servicemesh_member
create_knativeserving
loginfo "Wait for 180 seconds"
sleep 180
review_servicemeshmemberroll
loginfo "Wait for 90 seconds for pods to be created"
sleep 90
verify_pods

logbanner "End installing knative serving"