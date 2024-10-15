#!/bin/bash

echo "\nInstalling Prometheus Operator 👷\n"
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
sleep 3
echo "\nInstalling MariaDB Operator 👷\n"
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n poc-mariadb-maxscale-external --create-namespace
sleep 3
helm install mariadb-operator mariadb-operator/mariadb-operator -n poc-mariadb-maxscale-external

echo "\nWaiting 90s for pods to stabilize ⚠️\n"
sleep 90

# Edit the following variable based on your local setup
# NB: don't end the path with "/"
export FOLDER_PATH="/Users/alessandro/skytv/projects/mariadb"

echo "Applying manifests 👷\n"

kubectl apply -f $FOLDER_PATH/mariadb-operator/00-local/user-secrets.yaml
sleep 1
kubectl apply -f $FOLDER_PATH/mariadb-operator/00-local/configmaps/
sleep 3
kubectl apply -f $FOLDER_PATH/mariadb-operator/00-local/servers/
sleep 1
kubectl apply -f $FOLDER_PATH/mariadb-operator/00-local/app-deployment.yaml
sleep 10
kubectl apply -f $FOLDER_PATH/mariadb-operator/00-local/maxscale.yaml
sleep 3

echo "\nUse the following password for \"maxscale-admin\" in the GUI 🖥️\n"
kubectl get secret maxscale-admin -n poc-mariadb-maxscale-external --template={{.data.password}} | base64 -d

echo "\n\nInstallation complete ✅\n"
