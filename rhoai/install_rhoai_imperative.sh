#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

help() {
    loginfo "This script installs RHOAI and other dependencies"
    loginfo "Usage: $(basename $0)"
    loginfo "Options:"
    loginfo " -h, --help            Show usage"
    exit 0
}

while getopts ":h" opt; do
  case $opt in
    h) help ;;
    \?) echo "Invalid option: -$OPTARG" >&1; exit 1 ;;
  esac
done

USER="admin1"
PASSWORD="openshift1"
WAIT_TIME=10

LOG_FILE="rhoai_install_imperative_$(date +"%Y%m%d:%H%M").log"
echo "Log file: $LOG_FILE"
touch $LOG_FILE

loginfo "Setup RHOAI Console Banner Text"
apply_kustomize $SCRIPT_DIR/demos/rhoai-only

loginfo "-------- Running 00_add_admin_user.sh ----------------"
source "$SCRIPT_DIR/00_add_admin_user.sh" $USER $PASSWORD $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- 01_install_rhoai_operator.sh ----------------"
source "$SCRIPT_DIR/01_install_rhoai_operator.sh" $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 02_install_rhoai_components ----------------"
source "$SCRIPT_DIR/02_install_rhoai_components.sh" $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 03_1_install_serverless ----------------"
source "$SCRIPT_DIR/03_1_install_serverless.sh" $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 03_2_install_servicemesh ----------------"
source "$SCRIPT_DIR/03_2_install_servicemesh.sh" $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 03_3_install_knativeserving ----------------"
source "$SCRIPT_DIR/03_3_install_knativeserving.sh" $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 03_4_create_secure_gateways ----------------"
source "$SCRIPT_DIR/03_4_create_secure_gateways.sh"  $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 03_5_install_kserve ----------------"
source "$SCRIPT_DIR/03_5_install_kserve.sh" $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 03_6_add_authorization_provider ----------------"
source "$SCRIPT_DIR/03_6_add_authorization_provider.sh" $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 03_7_configure_servicemesh_authorino ----------------"
source "$SCRIPT_DIR/03_7_configure_servicemesh_authorino.sh" $LOG_FILE
sleep $WAIT_TIME

loginfo "-------- Running 03_8_configure_authorization_kserve ----------------"
source "$SCRIPT_DIR/03_8_configure_authorization_kserve.sh" $LOG_FILE
