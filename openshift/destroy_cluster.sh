#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

help() {
    loginfo "This script destroys an existing openshift cluster in an AWS environment"
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

if test -d "$TMPDIR"; then
    :
elif test -d "$TMP"; then
    TMPDIR=$TMP
elif test -d "/var/tmp"; then
    TMPDIR=/var/tmp
else
    TMPDIR=/tmp
fi

logbanner "Begin OpenShift Destroy Cluster"

verify_aws_secrets() {
    loginfo "Verify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY exists"
    if ! ([ -n "$AWS_ACCESS_KEY_ID" ] || grep -q '^export AWS_ACCESS_KEY_ID=' env.config 2>/dev/null) && 
         ([ -n "$AWS_SECRET_ACCESS_KEY" ] || grep -q '^export AWS_SECRET_ACCESS_KEY=' env.config 2>/dev/null); then
        logerror "Please export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY for destroying cluster on AWS">&2;
        exit 1
    fi
}

destroy_cluster(){
    if [ -z "$CLUSTERNAME" ]; then
        logerror "Please provide a cluster name"
        exit 1
    fi

    if [ ! -d "$CLUSTERNAME" ]; then
        logerror "Directory for cluster '$CLUSTERNAME' does not exist"
        exit 1
    fi

    CLUSTERDIR=$TMPDIR/clusters/$CLUSTERNAME
    loginfo "Cluster directory: $CLUSTERDIR"

    if [ -f $SCRIPT_DIR/.env ]; then source $SCRIPT_DIR/.env; fi
    verify_aws_secrets
    loginfo "AWS_ACCESS_KEY_ID: '$AWS_ACCESS_KEY_ID'"
    loginfo "AWS_SECRET_ACCESS_KEY: '$AWS_SECRET_ACCESS_KEY'"
    loginfo "Destroy cluster '$CLUSTERNAME'"
    openshift-install destroy cluster --dir=$CLUSTERDIR --log-level=info
}

destroy_cluster
loginfo "Wait for 60 seconds for resources to be deleted"
sleep 60
rm -rfd "$CLUSTERDIR"

logbanner "End OpenShift Destroy Cluster"