#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

CLUSTERNAME=$1

logbanner "Begin OpenShift Destroy Cluster"

destroy_cluster(){
    loginfo "Destroy cluster ${CLUSTERNAME}"
    openshift-install destroy cluster --dir=${CLUSTERNAME} --log-level=info
}

destroy_cluster
loginfo "Wait for 60 seconds for resources to be deleted"
sleep 60
rm -rfd "${CLUSTERNAME}"

logbanner "End OpenShift Destroy Cluster"