# Approach 01

## Scope

This case is used only as a test environment where the MariaDB servers are created with a custom deployment with the official Docker image.
It's not meant to be used for production purposes.

## Prerequisites

In the cluster you're planning on deploying the Maxscale solution, there should already be the following:

- Prometheus Operator
  - `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`
  - `helm repo update`
  - `helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace`

## Install

- Add the Helm repository
  - `helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator`
  - `helm repo update`

- Install the operator crds
  - `helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n poc-maxscale --create-namespace`
  - `helm install mariadb-operator mariadb-operator/mariadb-operator -n poc-maxscale`

## Deploy

- Use the following approach to deploy all files:
  - manual with Kustomize
    - `kubectl apply -k $PATH/01-emulation/`

## Notes

- The server "mariadb-0" has in it's configuration the parameter `max_connections=10` to be able to test the failover of the server.
