#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
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

echo "-------- Running 01_create_cluster_admin.sh ----------------"
source "$SCRIPT_DIR/01_create_cluster_admin.sh" user1 redhat1
sleep 15

echo "-------- 02_install_rhoai_operator.sh ----------------"
source "$SCRIPT_DIR/02_install_rhoai_operator.sh"
sleep 15

echo "-------- Running 03_install_rhoai_components ----------------"
source "$SCRIPT_DIR/03_install_rhoai_components.sh"
sleep 15

echo "-------- Running 04_install_servicemesh_operator ----------------"
source "$SCRIPT_DIR/04_install_servicemesh_operator.sh"
sleep 15

echo "-------- Running 05_install_serverless_operator ----------------"
source "$SCRIPT_DIR/05_install_serverless_operator.sh"
sleep 15

echo "-------- Running 06_create_servicemesh_member ----------------"
source "$SCRIPT_DIR/06_create_servicemesh_member.sh"
sleep 15

echo "-------- Running 07_install_knativeserving ----------------"
source "$SCRIPT_DIR/07_install_knativeserving.sh"
