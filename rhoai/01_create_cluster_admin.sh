#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

USERNAME=$1
PASSWORD=$2

RESOURCE_FILE="$SCRIPT_DIR/htpasswd/htpass-cr.yaml"
PWD_FILENAME="users.htpasswd"
SECRET_NAME="htpass-secret"

logbanner "Begin cluster admin user creation"

create_htpasswd_file() {
    loginfo "Create htpasswd file for user $USERNAME"
    htpasswd -c -B -b $PWD_FILENAME $USERNAME $PASSWORD
}

create_secret(){
    if oc get secrets -A | grep $SECRET_NAME; then
        logwarning "Secret $SECRET_NAME already exists, update secret"
        oc create secret generic $SECRET_NAME --from-file=htpasswd=$PWD_FILENAME --dry-run=client -o yaml -n openshift-config | oc replace -f -
    else
        loginfo "Create secret ${SECRET_NAME}"
        oc create secret generic $SECRET_NAME --from-file=htpasswd=$PWD_FILENAME -n openshift-config
    fi
}

apply_htpasswd_provider(){
    loginfo "Add htpasswd provider"
    oc apply -f $RESOURCE_FILE
}

apply_cluster_admin(){
    loginfo "Add cluster-admin to user $USERNAME"
    oc adm policy add-cluster-role-to-user cluster-admin $USERNAME
}

notify_user_creation(){
    logwarning "User won't be created till you run 'oc login -u <username>'" 
}

validate_user(){
    echo -e "${BLUE}INFO: ${NC}Validate user $USERNAME"
    if oc get user | grep $USERNAME; then
        echo -e "${BLUE}INFO: ${NC}$USERNAME created successfully"
    else
        echo -e "${BLUE}INFO: ${NC}User $USERNAME not created"
    fi
}

create_htpasswd_file
create_secret
apply_htpasswd_provider
apply_cluster_admin
loginfo "Wait for 90 seconds for resources to be created before you can login as user ${USERNAME}"
sleep 90
notify_user_creation

logbanner "End cluster admin user creation"
