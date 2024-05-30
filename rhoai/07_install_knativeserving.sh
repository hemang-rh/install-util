#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

logbanner "Begin KnativeServing Creation"

create_knativeserving(){
    loginfo "Create knative-serving subscription"
    oc create -f $SCRIPT_DIR/components/rh-servicemesh/knativeserving-istio.yaml
}

verify_pods(){
    loginfo "Verify pods are created"
    oc get pods -n knative-serving
}

create_knativeserving
loginfo "Wait for 90 seconds for pods to be created"
sleep 90
verify_pods

logbanner "End KnativeServing Creation"