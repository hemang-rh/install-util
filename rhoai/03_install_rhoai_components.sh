#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

logbanner "Begin RHOAI Component Installation"

create_datascience_cluster(){
    loginfo "Create datascience cluster"
    oc create -f $SCRIPT_DIR/components/rh-openshift-ai/rhods-operator-dsc.yaml
}

create_datascience_cluster

logbanner "End RHOAI Component Installation"