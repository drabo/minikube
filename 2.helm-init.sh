#!/bin/bash

helm init

vartime=30
echo "Wait $vartime sec while tiller is deployed"
sleep $vartime

kubectl -n kube-system get svc tiller-deploy
