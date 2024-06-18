#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_DIR="${SCRIPT_DIR%/*}"
source ${PARENT_DIR}/common/logging.sh
source ${PARENT_DIR}/common/util.sh

LOG_FILE=$1

logbanner "Begin creating secure gateways for knative serving"
log "Log file: '$LOG_FILE'"

set_environment_variables(){
    loginfo "Setting environment variables BASE_DIR, BASE_CERT_DIR, COMMON_NAME, DOMAIN_NAME"
    export BASE_DIR=/tmp/kserve
    export BASE_CERT_DIR=${BASE_DIR}/certs

    export COMMON_NAME=$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}' | awk -F'.' '{print $(NF-1)"."$NF}')
    export DOMAIN_NAME=$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}')

    loginfo "BASE_DIR=$BASE_DIR"
    loginfo "BASE_CERT_DIR=$BASE_CERT_DIR"
    loginfo "COMMON_NAME=$COMMON_NAME"
    loginfo "DOMAIN_NAME=$DOMAIN_NAME"
}

create_base_directory(){
    loginfo "Creating BASE_DIR and BASE_CERT_DIR directory"
    mkdir ${BASE_DIR}
    mkdir ${BASE_CERT_DIR}
}

creat_ssl_config() {
    loginfo "Creating ssl config"
    echo "
    [ req ]
    distinguished_name = req
    [ san ]
    subjectAltName = DNS:*.$DOMAIN_NAME" >> $BASE_DIR/openssl-san.config
}

generate_root_certificate(){
    loginfo "Generating root certificate"
    openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 \
    -subj "/O=Example Inc./CN=$COMMON_NAME" \
    -keyout $BASE_DIR/root.key \
    -out $BASE_DIR/root.crt
}


generate_wildcard_certificate(){
    loginfo "Generating wildcard certificate"
    loginfo "BASE_DIR=$BASE_DIR"
    loginfo "BASE_CERT_DIR=$BASE_CERT_DIR"
    loginfo "COMMON_NAME=$COMMON_NAME"
    loginfo "DOMAIN_NAME=$DOMAIN_NAME"

    openssl req -x509 -newkey rsa:2048 \
    -sha256 -days 3560 -nodes \
    -subj "/CN=$COMMON_NAME/O=Example Inc." \
    -extensions san -config $BASE_DIR/openssl-san.config \
    -CA $BASE_DIR/root.crt \
    -CAkey $BASE_DIR/root.key \
    -keyout $BASE_DIR/wildcard.key  \
    -out $BASE_DIR/wildcard.crt

    openssl x509 -in $BASE_DIR/wildcard.crt -text
}

verify_wildcard_certificate(){
    loginfo "Verifying wildcard certificate"
    openssl verify -CAfile $BASE_DIR/root.crt $BASE_DIR/wildcard.crt
}

set_certificate_environment_variables() {
    loginfo "Setting environment variables TARGET_CUSTOM_CERT, TARGET_CUSTOM_KEY"
    cp $BASE_DIR/wildcard.crt $BASE_CERT_DIR/wildcard.crt
    cp $BASE_DIR/wildcard.key $BASE_CERT_DIR/wildcard.key
    export TARGET_CUSTOM_CERT="$BASE_CERT_DIR/wildcard.crt"
    export TARGET_CUSTOM_KEY="$BASE_CERT_DIR/wildcard.key"

    loginfo "TARGET_CUSTOM_CERT=$TARGET_CUSTOM_CERT"
    loginfo "TARGET_CUSTOM_KEY=$TARGET_CUSTOM_KEY"
}

create_tls_secret(){
    loginfo "Creating TLS secret"
    oc create secret tls wildcard-certs --cert=$TARGET_CUSTOM_CERT --key=$TARGET_CUSTOM_KEY -n istio-system 2>&1 | tee -a $LOG_FILE
}

create_gateways(){
    loginfo "Creating gateways"
    oc apply -f $SCRIPT_DIR/components/kserve/gateways.yaml 2>&1 | tee -a $LOG_FILE

    # Expected output
    # service/knative-local-gateway created
    # gateway.networking.istio.io/knative-ingress-gateway created
    # gateway.networking.istio.io/knative-local-gateway created
}

verify_gateways() {
    loginfo "Verifying gateways"
    oc get gateway --all-namespaces 2>&1 | tee -a $LOG_FILE

    # Expected output
    # NAMESPACE         	NAME                      	AGE
    # knative-serving   	knative-ingress-gateway   	69s
    # knative-serving     knative-local-gateway     	2m
}

set_environment_variables
create_base_directory
creat_ssl_config
generate_root_certificate
generate_wildcard_certificate
verify_wildcard_certificate
set_certificate_environment_variables
create_tls_secret
create_gateways
loginfo "Wait for 90 seconds"
sleep 90
verify_gateways

loginfo "End creating secure gateways for knative serving"
