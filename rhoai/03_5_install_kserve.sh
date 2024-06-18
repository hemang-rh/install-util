#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

logbanner "Begin installing kserve"
log "Log file: '$LOG_FILE'"

set_servicemesh_unmanaged() {
    loginfo "Set servicemesh unmanaged"
    loginfo "TODO"
}

set_kserve_managed() {
    loginfo "Set kserve managed"
    loginfo "TODO"
}

set__serving_kserve_unmanaged() {
    loginfo "Set servicemesh unmanaged"
    loginfo "TODO"
}

logbanner "End installing kserve"