#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

logbanner "Begin installing servicemesh"
log "Log file: '$LOG_FILE'"

create_istio_namespace(){
    loginfo "Create istio-system namespace"
    oc create -f $SCRIPT_DIR/operators/rh-servicemesh/servicemesh-namespace.yaml 2>&1 | tee -a $LOG_FILE
}

create_subscription(){
    loginfo "Create servicemeshoperator subscription"
    oc create -f $SCRIPT_DIR/operators/rh-servicemesh/servicemesh-subscription.yaml 2>&1 | tee -a $LOG_FILE
}

verify_installation() {
    loginfo "Verify servicemeshoperator installation"
    retry_new "oc get csv -n openshift-operators" "servicemeshoperator" "Succeeded" 
}

create_control_plane(){
    loginfo "Create control plane"
    oc create -f $SCRIPT_DIR/operators/rh-servicemesh/smcp.yaml 2>&1 | tee -a $LOG_FILE
}

verify_pods(){
    loginfo "Verify service mesh pods are running"
    oc get pods -n istio-system 2>&1 | tee -a $LOG_FILE
    
    #Example output
    #NAME                                          READY   STATUS   	  RESTARTS    AGE
    #istio-egressgateway-7c46668687-fzsqj          1/1     Running     0           22h
    #istio-ingressgateway-77f94d8f85-fhsp9         1/1     Running     0           22h
    #istiod-data-science-smcp-cc8cfd9b8-2rkg4      1/1     Running     0           22h
}

create_istio_namespace
create_subscription
verify_installation
create_control_plane
loginfo "Wait for 180 seconds for control plane to be created"
sleep 180
verify_pods

logbanner "End installing servicemesh"