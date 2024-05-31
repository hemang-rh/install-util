#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

# Default values
REGION="east"
GPU="true"

help() {
    loginfo "This script creates an openshift cluster on an AWS environment for a given base domain"
    loginfo "Usage: $(basename $0) [-h] [-c CLUSTERNAME] [-b BASEDOMAIN] [-r REGION] [-g GPU]"
    loginfo "Options:"
    loginfo " -h, --help            Show usage"
    loginfo " -c, --clustername     Set cluster name"
    loginfo " -b, --basedomain      Set base domain"
    loginfo " -r, --region          Set region (east/west), default is east"
    loginfo " -g, --gpu             Set GPU type (true/false), default is true"
    exit 0
}

while getopts ":hc:b:r:g:" opt; do
  case $opt in
    h) help ;;
    c) CLUSTERNAME=$OPTARG ;;
    b) BASEDOMAIN=$OPTARG ;;
    r) REGION=$OPTARG ;;
    b) GPU=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&4; exit 1 ;;
  esac
done

logbanner "Begin OpenShift Cluster Installation"

setup() {
    loginfo "Setup - configure install-config.yaml"

    if [ -z "$CLUSTERNAME" ]; then
        logerror "Please provide a cluster name"
        exit 1
    fi

    if [ -z "$BASEDOMAIN" ]; then
        logerror "Please provide a base domain"
        exit 1
    fi

    if [ $GPU = "true" ]; then
        INSTANCETYPE="g4dn.4xlarge"
    else
        INSTANCETYPE="m5.4xlarge"
    fi

    if [ $REGION = "west" ]; then
        ZONE1="us-west-2a"
        ZONE2="us-west-2b"
        ZONE3="us-west-2c"
        REGION="us-west-2"
    elif [ $REGION = "east" ]; then
        ZONE1="us-east-2a"
        ZONE2="us-east-2b"
        ZONE3="us-east-2c"
        REGION="us-east-2"
    else
        logerror "Invalid region. Set region (east/west)"
        exit 1
    fi

    loginfo "Cluster Name = $CLUSTERNAME"
    loginfo "Base Domain = $BASEDOMAIN"
    loginfo "Region = $REGION"
    loginfo "GPU = $GPU"
    loginfo "Instance Type = $INSTANCETYPE"
     
    INSTALLFILE=$SCRIPT_DIR/config/install-config.yaml
    loginfo "Insall file path: $INSTALLFILE"
    loginfo "Create a directory to store assets for cluster '$CLUSTERNAME'"
    mkdir $CLUSTERNAME

    if [ -f "$CLUSTERNAME/install-config.yaml" ]; then
        rm -f "$CLUSTERNAME/install-config.yaml"
    fi

    sed "s/CLUSTERNAME/$CLUSTERNAME/; 
    s/BASEDOMAIN/$BASEDOMAIN/; 
    s/INSTANCETYPE/$INSTANCETYPE/; 
    s/ZONE1/$ZONE1/; 
    s/ZONE2/$ZONE2/; 
    s/ZONE3/$ZONE3/; 
    s/REGION/$REGION/" $INSTALLFILE >> $CLUSTERNAME/install-config.yaml
}

copy_install_config() {
    loginfo "Copying install-config.yaml to install-config.yaml.bak"
    cp $CLUSTERNAME/install-config.yaml $CLUSTERNAME/install-config.yaml.bak
}

install_cluster() {
    loginfo "Installing OpenShift Cluster"
    openshift-install create cluster --dir=$CLUSTERNAME --log-level=info
}

setup
copy_install_config
install_cluster

logbanner "End OpenShift Cluster Installation"
