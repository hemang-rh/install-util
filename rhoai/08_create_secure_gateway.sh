#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/util.sh

set_environment_variables(){
    export BASE_DIR=/tmp/kserve
    export BASE_CERT_DIR=${BASE_DIR}/certs
    export COMMON_NAME=$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}' | awk -F'.' '{print $(NF-1)"."$NF}')
    export DOMAIN_NAME=$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}')
}

create_base_directory(){
    mkdir ${BASE_DIR}
    mkdir ${BASE_CERT_DIR}
}

# create_openssl_config(){
#     cat > ${BASE_DIR}/openssl-san.config << EOF
#     [ req ]
#     distinguished_name = req
#     [ san ]
#     subjectAltName = DNS:*.${DOMAIN_NAME}
#     EOF
# }

create_test(){
    echo '[req ]
    distinguished_name = req
    [ san ]
    subjectAltName = DNS:*.${DOMAIN_NAME}' > foo.conf
}

create_test
