#!/bin/bash

echo "\nInstalling MariaDB Operator 👷\n"
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n poc-maxscale --create-namespace
sleep 3
helm install mariadb-operator mariadb-operator/mariadb-operator -n poc-maxscale

echo "\nWaiting 90s for pods to stabilize ⚠️\n"
sleep 90

echo "Applying manifests 👷\n"

kubectl apply -k /Users/alessandro/skytv/projects/mariadb/mariadb-operator/01-emulation/ -n poc-maxscale
sleep 5

echo "\nUse the following password for \"maxscale-admin\" in the GUI 🖥️\n"
kubectl get secret maxscale-admin -n poc-maxscale --template={{.data.password}} | base64 -d

echo "\n\nInstallation complete ✅\n"
