#!/bin/bash

# Installazione di Prometheus Operator
echo -e "\nInstalling Prometheus Operator 👷\n"
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
sleep 3

# Installazione di MariaDB Operator
echo -e "\nInstalling MariaDB Operator 👷\n"
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n poc-mariadb-maxscale-external --create-namespace
sleep 3
helm install mariadb-operator mariadb-operator/mariadb-operator -n poc-mariadb-maxscale-external
sleep 3

# Attendere 90 secondi per permettere la stabilizzazione dei pod
echo -e "\nWaiting 90s for pods to stabilize ⚠️\n"
for i in {1..90}; do
  echo "Seconds passed: $i"
  sleep 1
done

# Applicazione dei manifesti YAML per i segreti, gli utenti e i server MariaDB
echo -e "\nApplying manifests 👷\n"
kubectl apply -f ./external-servers/user-secrets.yaml
sleep 3

for INDEX in 0 1 2; do
  echo -e "\nApplying user configuration for user-$INDEX 👷\n"
  kubectl apply -f ./external-servers/users-$INDEX/
  sleep 3
done

for INDEX in 0 1 2; do
  echo -e "\nApplying MariaDB server configuration for mariadb-$INDEX 👷\n"
  kubectl apply -f ./external-servers/servers/mariadb-$INDEX.yaml
  sleep 3
done

# Applicazione della configurazione di MaxScale
echo -e "\nApplying MaxScale configuration 👷\n"
kubectl apply -f ./external-servers/maxscale.yaml
sleep 3

# Deploy dell'applicazione
echo -e "\nDeploying application 👷\n"
kubectl apply -f ./external-servers/app-deployment.yaml
sleep 3

# Recuperare la password di MaxScale
echo -e "\nRetrieving MaxScale admin password ⚠️\n"
kubectl get secret maxscale-admin -n poc-mariadb-maxscale-external --template={{.data.password}} | base64 -d
echo -e "\n\nInstallation complete ✅\n"
