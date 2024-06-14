#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

USERNAME=$1
PASSWORD=$2
LOG_FILE=$3

RESOURCE_FILE="$SCRIPT_DIR/htpasswd/htpass-cr.yaml"
PWD_FILENAME="users.htpasswd"
SECRET_NAME="htpass-secret"


logbanner "Begin adding administrative user"
log "Log file: '$LOG_FILE'"

create_htpasswd_file() {
    loginfo "Create htpasswd file for user $USERNAME"
    htpasswd -c -B -b $PWD_FILENAME $USERNAME $PASSWORD 2>&1 | tee -a $LOG_FILE
}

create_secret(){
    if oc get secrets -A | grep $SECRET_NAME; then
        logwarning "Secret $SECRET_NAME already exists, update secret"
        oc create secret generic $SECRET_NAME --from-file=htpasswd=$PWD_FILENAME --dry-run=client -o yaml -n openshift-config | oc replace -f - 2>&1 | tee -a $LOG_FILE
    else
        loginfo "Create secret ${SECRET_NAME}"
        oc create secret generic $SECRET_NAME --from-file=htpasswd=$PWD_FILENAME -n openshift-config 2>&1 | tee -a $LOG_FILE
    fi
}

apply_htpasswd_provider(){
    loginfo "Add htpasswd provider"
    oc apply -f $RESOURCE_FILE 2>&1 | tee -a $LOG_FILE
}

apply_cluster_admin(){
    loginfo "Add cluster-admin to user $USERNAME"
    oc adm policy add-cluster-role-to-user cluster-admin $USERNAME 2>&1 | tee -a $LOG_FILE
}

notify_user_creation(){
    logwarning "User won't be created till you run 'oc login -u <username>'" 
}

validate_user(){
    loginfo "Validate user $USERNAME"
    if oc get user | grep $USERNAME; then
        loginfo "$USERNAME created successfully"
    else
        logerror "User $USERNAME not created"
    fi
}

create_htpasswd_file
create_secret
apply_htpasswd_provider
apply_cluster_admin
loginfo "Wait for 30 seconds for resources to be created before you can login as user ${USERNAME}"
sleep 30
notify_user_creation

logbanner "End adding administrative user"
