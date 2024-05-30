#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

CLUSTERNAME=$1
BASEDOMAIN=$2
GPU="${3:-gpu}"
REGION="${4:-west}"

logbanner "Begin OpenShift Cluster Installation"

setup() {
    loginfo "Setup - configure install-config.yaml"
    loginfo "Basedomain=${BASEDOMAIN}"
    loginfo "GPU=${GPU}"
    loginfo "Region=${REGION}"
    # NUM="${BASEDOMAIN//[!0-9]/}"
    # CLUSTERNAME="${CLUSTERNAME}-${NUM}"
    loginfo "Cluster Name: $CLUSTERNAME"

    if [ $GPU = "gpu" ]
    then
        if [ $REGION = "west" ]; then
            INSTALLFILE=$SCRIPT_DIR/config/gpu-install-config-west2.yaml
        else
            INSTALLFILE=$SCRIPT_DIR/config/gpu-install-config-east2.yaml
        fi
    else
        if [ $REGION = "west" ]; then
            INSTALLFILE=$SCRIPT_DIR/config/nogpu-install-config-west2.yaml
        else
            INSTALLFILE=$SCRIPT_DIR/config/nogpu-install-config-east2.yaml
        fi
    fi

    loginfo "Insall file path: $INSTALLFILE"
    mkdir $CLUSTERNAME
    sed "s/CLUSTERNAME/${CLUSTERNAME}/; s/BASEDOMAIN/${BASEDOMAIN}/" $INSTALLFILE >> $CLUSTERNAME/install-config.yaml
}

copy_install_config() {
    loginfo "Copying install-config.yaml to install-config.yaml.bak"
    cp ${CLUSTERNAME}/install-config.yaml ${CLUSTERNAME}/install-config.yaml.bak
}

install_cluster() {
    loginfo "Installing OpenShift Cluster"
    openshift-install create cluster --dir=${CLUSTERNAME} --log-level=info >> ${CLUSTERNAME}/${CLUSTERNAME}.log
}

setup
copy_install_config
install_cluster

logbanner "End OpenShift Cluster Installation"
