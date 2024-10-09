#!/bin/bash
echo -e "\nInstalling Prometheus Operator 👷\n"
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
sleep 3

echo -e "\nInstalling MariaDB Operator 👷\n"
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n poc-mariadb-maxscale-external --create-namespace
sleep 3
helm install mariadb-operator mariadb-operator/mariadb-operator -n poc-mariadb-maxscale-external

echo -e "\nWaiting 90s for pods to stabilize ⚠️\n"
for i in {1..90}; do
  echo "Seconds passed: $i"
  sleep 1
done

kubectl apply -f ./mock-servers/user-secrets.yaml
sleep 3
kubectl apply -f ./mock-servers/configmaps/
sleep 3
kubectl apply -f ./mock-servers/servers/
sleep 3
kubectl apply -f ./mock-servers/app-deployment.yaml
sleep 3
kubectl apply -f ./mock-servers/maxscale.yaml
sleep 3

# Recuperare la password di MaxScale
echo -e "\nRetrieving MaxScale admin password ⚠️\n"
kubectl get secret maxscale-admin -n poc-mariadb-maxscale-external --template={{.data.password}} | base64 -d
echo -e "\n\nInstallation complete ✅\n"
# kubectl port-forward service/maxscale-gui -n poc-mariadb-maxscale-external 8989