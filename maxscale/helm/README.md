# Cluster setup

## K3D

$ k3d cluster create skytest --servers 1 --agents 3
$ k3d kubeconfig get skytest > config
$ export KUBECONFIG=config

## Installation

$ helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
$ helm install mariadb-operator-maxscale-helm $HOME/skytv/projects/mariadb/mariadb-operator/maxscale/helm -n poc-mariadb-maxscale-helm --create-namespace

## Credentials

- Maxscale GUI: admin:mariadb

## Cleanup

$ helm uninstall mariadb-operator-maxscale-helm $HOME/skytv/projects/mariadb/mariadb-operator/maxscale/helm -n poc-mariadb-maxscale-helm
$ k delete ns poc-mariadb-maxscale-helm

## Notes

I due servizi che vengono creati dal Chart, ma che non si vedono dichiarati in questa repo sembrano essere questi:

- <https://github.com/appuio/charts/blob/master/appuio/maxscale/templates/service-masteronly.yaml>
- <https://github.com/appuio/charts/blob/master/appuio/maxscale/templates/service-rwsplit.yaml>
