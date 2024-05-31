#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

# Default values
REGION="east"
GPU="true"
CPUINSTANCETYPE="m5.4xlarge"
MASTERINSTANCETYPE="m5.4xlarge"
GPUINSTANCETYPE="g4dn.4xlarge"

help() {
    loginfo "This script creates an openshift cluster on an AWS environment for a given base domain"
    loginfo "Cluster has 3 control plane nodes and 3 worker nodes in mutlipe AZs"
    loginfo "Prequisite: Set PULLSECRET and SSHKEY in env.config"
    loginfo "Usage: $(basename $0) [-h] [-c CLUSTERNAME] [-b BASEDOMAIN] [-r REGION] [-g GPU]"
    loginfo "Options:"
    loginfo " -h, --help            Show usage"
    loginfo " -c, --clustername     Set cluster name (required)"
    loginfo " -b, --basedomain      Set base domain (required)"
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
    g) GPU=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&4; exit 1 ;;
  esac
done

logbanner "Begin OpenShift Cluster Installation"

verify_pull_secret(){
    loginfo "Verify PULL_SECRET exists"
    if ! ([ -n "$PULLSECRET" ] || grep -q '^export PULLSECRET=' $SCRIPT_DIR/.env 2>/dev/null); then
        logerror "Please export PULL_SECRET variable from https://console.redhat.com/openshift/install/platform-agnostic/user-provisioned" >&2;
        exit 1
    fi
}

verify_aws_secrets() {
    loginfo "Verify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY exists"
    if ! ([ -n "$AWS_ACCESS_KEY_ID" ] || grep -q '^export AWS_ACCESS_KEY_ID=' env.config 2>/dev/null) && 
         ([ -n "$AWS_SECRET_ACCESS_KEY" ] || grep -q '^export AWS_SECRET_ACCESS_KEY=' env.config 2>/dev/null); then
        logerror "Please export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY for creating cluster on AWS">&2;
        exit 1
    fi
}

create_ssh_key() {
    loginfo "Create SSH key for $CLUSTERNAME"
    ssh-keygen -t ed25519 -b 512 -f $CLUSTERNAME/id_ed25519 -C admin@$CLUSTERNAME.$BASEDOMAIN -N ''
}

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
    
    verify_pull_secret
    verify_aws_secrets

    if [ $GPU = "true" ]; then
        WORKERINSTANCETYPE=$GPUINSTANCETYPE
    else
        WORKERINSTANCETYPE=$CPUINSTANCETYPE
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
    loginfo "Worker Instance Type = $WORKERINSTANCETYPE"
    loginfo "Master Instance Type = $MASTERINSTANCETYPE"

    INSTALLFILE=$SCRIPT_DIR/config/install-config.yaml
    loginfo "Insall file path: $INSTALLFILE"
    loginfo "Create a directory to store assets for cluster '$CLUSTERNAME'"
    mkdir $CLUSTERNAME

    create_ssh_key

    if [ -f "$CLUSTERNAME/install-config.yaml" ]; then
        rm -f "$CLUSTERNAME/install-config.yaml"
    fi

    sed "s%CLUSTERNAME%$CLUSTERNAME%; 
    s%BASEDOMAIN%$BASEDOMAIN%; 
    s%WORKERINSTANCETYPE%$WORKERINSTANCETYPE%; 
    s%MASTERINSTANCETYPE%$MASTERINSTANCETYPE%; 
    s%ZONE1%$ZONE1%; 
    s%ZONE2%$ZONE2%; 
    s%ZONE3%$ZONE3%; 
    s%REGION%$REGION%" $INSTALLFILE >> $CLUSTERNAME/install-config.yaml

    if [ -f $SCRIPT_DIR/.env ]; then source $SCRIPT_DIR/.env; fi
    echo "pullSecret: '$PULLSECRET'" >> $CLUSTERNAME/install-config.yaml
    echo "sshKey: '$(cat $CLUSTERNAME/id_ed25519.pub)'" >> $CLUSTERNAME/install-config.yaml

}

copy_install_config() {
    loginfo "Copying install-config.yaml to install-config.yaml.bak"
    cp $CLUSTERNAME/install-config.yaml $CLUSTERNAME/install-config.yaml.bak
}

install_cluster() {
    loginfo "Installing OpenShift Cluster"
    loginfo "AWS_ACCESS_KEY_ID = $AWS_ACCESS_KEY_ID"
    loginfo "AWS_SECRET_ACCESS_KEY = $AWS_SECRET_ACCESS_KEY"
    openshift-install create cluster --dir=$CLUSTERNAME --log-level=info
}

setup
copy_install_config
install_cluster

logbanner "End OpenShift Cluster Installation"
