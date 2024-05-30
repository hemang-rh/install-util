#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

loginfo "Begin Servicemesh Member Creation"

create_member(){
    loginfo "Create default subscription"
    oc create -f $SCRIPT_DIR/components/rh-servicemesh/default-smm.yaml
}

create_member

logbanner "End Servicemesh Member Creation"