#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh
source $SCRIPT_DIR/config/env.config


logbanner "Begin shutdown cluster"


shutdown_cluster() {
    worker_nodes=$(oc get nodes | grep -i worker | wc -l)
    controlplane_nodes=$(oc get nodes | grep -i control-plane | wc -l)
    loginfo "Shutting down $controlplane_nodes control-plane nodes"
    loginfo "Shutting down $worker_nodes worker nodes"
    for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}'); do oc debug node/${node} -- chroot /host shutdown -h 1; done
}

shutdown_cluster

logbanner "End shutdown cluster"