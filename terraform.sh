#!/usr/bin/env bash

initialize() {
    printf "Deleting the .terraform directory...\\n"
    rm -rf .terraform

    printf "Initializing Terraform...\\n"
    terraform get
    terraform init
}

execute() {
    set -o pipefail
    terraform $COMMAND $AUTO_APPROVE | \
    tee -a "deployment.log"
}

help() {
    printf "Available Commands:\\n apply\\n destroy \\n plan\\n\\n"
}

COMMAND=$1
AUTO_APPROVE=$2

if [[ -z ${COMMAND} ]]; then
    help
    exit 1
fi

initialize
execute
