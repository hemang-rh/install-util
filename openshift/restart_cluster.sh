#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh
source $SCRIPT_DIR/config/env.config

help() {
    loginfo "This script restarts an existing openshift cluster in an AWS environment"
    loginfo "Usage: $(basename $0) [-h] [-c CLUSTERNAME]"
    loginfo "Options:"
    loginfo " -h, --help            Show usage"
    loginfo " -c, --clustername     Cluster name to destroy (required)"
    exit 0
}

while getopts ":hc:" opt; do
  case $opt in
    h) help ;;
    c) CLUSTERNAME=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&1; exit 1 ;;
  esac
done

logbanner "Begin restart cluster"


restart_cluster() {
    if [ -z "$CLUSTERNAME" ]; then
        logerror "Please provide a cluster name"
        exit 1
    fi

    if [ ! -d "$CLUSTERNAME" ]; then
        logerror "Directory for cluster '$CLUSTERNAME' does not exist"
        exit 1
    fi
    
    filters="Name=tag:Name,Values=$CLUSTERNAME-*"
    instance_ids=$(aws ec2 describe-instances --filters $filters --output text --query 'Reservations[].Instances[].InstanceId')
    for val in $instance_ids; do
        loginfo "InstanceId: $val"
    done
}

restart_cluster

logbanner "End restart cluster"