#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

logbanner "Begin Serverless Operator Installation"

create_subscription(){
    loginfo "Create openshift-serverless subscription"
    oc create -f $SCRIPT_DIR/operators/rh-serverless/subscription.yaml
}

create_subscription

logbanner "End Serverless Operator Installation"