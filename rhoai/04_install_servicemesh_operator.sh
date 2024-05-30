#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

logbanner "Begin Servicemesh Operator Installation"

create_istio_namespace(){
    loginfo "Create istio-system namespace"
    oc create -f $SCRIPT_DIR/operators/rh-servicemesh/namespace.yaml
}

create_subscription(){
    loginfo "Create servicemeshoperator subscription"
    oc create -f $SCRIPT_DIR/operators/rh-servicemesh/subscription.yaml
}

create_control_plane(){
    loginfo "Create control plane"
    oc create -f $SCRIPT_DIR/components/rh-servicemesh/smcp.yaml
}

verify_pods(){
    loginfo "Verify service mesh pods are running"
    oc get pods -n istio-system
}

create_istio_namespace
create_subscription
create_control_plane
loginfo "Wait for 90 seconds for pods to be created"
sleep 90
verify_pods

logbanner "End Servicemesh Operator Installation"