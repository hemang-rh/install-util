#!/bin/bash

retry(){
    echo "Running:" "${@}"
    echo "Retry times: 12"
    echo "Delay: 20 sec"
    local n=1
    local max=12
    local delay=20
    # until "${@}" 1>&2
    until "${@}"
    do
        if [[ $n -lt $max ]]; then
            ((n++))
            echo "Retry after $delay sec"
            sleep $delay
        else
            echo "Failed after $n attempts."
            return 1
        fi
    done
    echo "[OK]"
}

apply_kustomize(){
    if [ ! -f "$1/kustomization.yaml" ]; then
        echo "'kustomization.yaml' not found in $1"
        return 1
    fi

    retry oc apply -k "$1" 2>/dev/null
}

retry_new(){
    max_attempts=12
    attempt_num=1
    success=false
    delay=20

    while [ $success = false ] && [ $attempt_num -le $max_attempts ]; do
    echo "Running:" "$1"
    $1 | grep $2
    count=$($1 | grep $2 | grep $3 | wc -l)
    echo "count: $count"
    if [ $? -eq 0 ] && [ $count -eq 1 ]; then
        success=true
    else
        echo "Attempt $attempt_num failed. Retry after $delay seconds..."
        attempt_num=$(( attempt_num + 1 ))
        sleep $delay
    fi
    done

    if [ $success = true ]; then
    echo "[PASS]"
    else
    echo "[FAIL]"
    fi
}