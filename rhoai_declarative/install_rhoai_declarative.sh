#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

GPU="false"

help() {
    loginfo "This script installs RedHat Openshift AI on an AWS OpenShift cluster"
    loginfo "Prequisite: AWS OpenShift cluster is already created"
    loginfo "Prequisite: User is logged into console using 'oc' and has cluster admin rights"
    loginfo "Usage: $(basename $0) [-h] [-g GPU]"
    loginfo "Options:"
    loginfo " -h, --help            Show usage"
    loginfo " -g, --gpu             Configure GPU autoscale (true/false), default is false"
    exit 0
}

while getopts ":hc:b:r:g:" opt; do
  case $opt in
    h) help ;;
    g) GPU=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&4; exit 1 ;;
  esac
done

LOG_FILE="rhoai_install_declarative_$(date +"%Y%m%d:%H%M").log"
echo "Log file: $LOG_FILE"
touch $LOG_FILE

logbanner "Install RedHat OpenShift AI"

setup() {
    loginfo "GPU: '$GPU'"
    loginfo "Setup RHOAI"
    loginfo "> RedHat OpenShift AI"
    loginfo "> RedHat OpenShift Serverless"
    loginfo "> RedHat OpenShift Service Mesh"
    loginfo "> RedHat OpenShift Pipelines"
    loginfo "> RedHat Authorino"

    if [ $GPU = "true" ]; then
        loginfo "Setup GPU Autoscale"
        loginfo "> NVIDIA GPU Operator"
        loginfo "> Node Feature Discovery Autoscale"
        apply_kustomize $SCRIPT_DIR/demos/rhoai-nvidia-gpu-autoscale
    else
        apply_kustomize $SCRIPT_DIR/demos/rhoai-only
    fi
}

setup

logbanner "End Install RedHat OpenShift AI"