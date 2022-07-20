#!/bin/bash

K8S_VERSION=v1.20.15

USE_REPO=1
REPO_IP=192.168.56.156

if [[ $USE_REPO -eq 1 ]]; then
    REPO_OPT="--insecure-registry $REPO_IP/32"
fi

minikube start \
    --kubernetes-version $K8S_VERSION \
    --driver virtualbox \
    --cpus 4 \
    --memory 16gb \
    --disk-size 40gb \
    --cni flannel \
    $REPO_OPT
