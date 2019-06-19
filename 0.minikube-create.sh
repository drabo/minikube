#!/bin/bash

USE_REPO=1

REPO_IP=192.168.56.156

if [[ $USE_REPO -eq 1 ]]; then
    REPO_OPT="--insecure-registry $REPO_IP/32"
fi

minikube start \
    --cpus 2 \
    --memory 6144 \
    --disk-size 30g \
    $REPO_OPT
