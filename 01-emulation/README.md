# Approach 01

## Install

- Add the Helm repository
  - helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator
  - helm repo update

- Install the operator crds
  - helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n poc-maxscale --create-namespace
  - helm install mariadb-operator mariadb-operator/mariadb-operator -n poc-maxscale

## Deploy

- Use Kustomize to deploy all of the files
  - k apply -k $PATH/01-emulation/
