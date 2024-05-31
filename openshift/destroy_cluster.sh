#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

help() {
    loginfo "This script destroys an existing openshift cluster in an AWS environment"
    loginfo "Usage: $(basename $0) [-h] [-c CLUSTERNAME]"
    loginfo "Options:"
    loginfo " -h, --help            Show usage"
    loginfo " -c, --clustername     Cluster name to destroy"
    exit 0
}

while getopts ":hc:" opt; do
  case $opt in
    h) help ;;
    c) CLUSTERNAME=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&1; exit 1 ;;
  esac
done

logbanner "Begin OpenShift Destroy Cluster"

destroy_cluster(){
    if [ -z "$CLUSTERNAME" ]; then
        logerror "Please provide a cluster name"
        exit 1
    fi

    if [ ! -d "$CLUSTERNAME" ]; then
        logerror "Directory for cluster '$CLUSTERNAME' does not exist"
        exit 1
    fi

    loginfo "Destroy cluster '$CLUSTERNAME'"
    openshift-install destroy cluster --dir=$CLUSTERNAME --log-level=info
}

destroy_cluster
loginfo "Wait for 60 seconds for resources to be deleted"
sleep 60
rm -rfd "$CLUSTERNAME"

logbanner "End OpenShift Destroy Cluster"