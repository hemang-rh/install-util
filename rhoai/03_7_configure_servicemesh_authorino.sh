#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

logbanner "Begin configuring service mesh to use authorino"
log "Log file: '$LOG_FILE'"

patch_smcp() {
    loginfo "Patch ServiceMeshControlPlane"
    oc patch smcp minimal --type merge -n istio-system --patch-file $SCRIPT_DIR/operators/rh-authorino/servicemesh-smcp-patch.yaml 2>&1 | tee -a $LOG_FILE
}

inspect_configmap() {
    loginfo "Inspect configmap"
    oc get configmap istio-minimal -n istio-system --output=jsonpath={.data.mesh} 2>&1 | tee -a $LOG_FILE
}

patch_smcp
inspect_configmap

logbanner "End configuring service mesh to use authorino"