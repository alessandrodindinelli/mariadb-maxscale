## Cluster setup

## K3D

$ k3d cluster create skytest --servers 1 --agents 3
$ k3d kubeconfig get skytest > config
$ export KUBECONFIG=config

## Installation

$ helm repo add prometheus-community <https://prometheus-community.github.io/helm-charts>
$ helm repo add mariadb-operator <https://helm.mariadb.com/mariadb-operator>
$ helm repo update
$ helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
$ helm install mariadb-operator mariadb-operator/mariadb-operator --set metrics.enabled=true -n maxscale-operator-test --create-namespace
$ k apply -f $PATH_TO_FOLDER/maxscale/user-secrets.yaml
$ k apply -f $PATH_TO_FOLDER/maxscale/mariadb-0.yaml
$ k apply -f $PATH_TO_FOLDER/maxscale/mariadb-1.yaml
$ k apply -f $PATH_TO_FOLDER/maxscale/users-0/
$ k apply -f $PATH_TO_FOLDER/maxscale/users-1/
$ k apply -f $PATH_TO_FOLDER/maxscale/maxscale.yaml

## Login to Grafana dashboard

$ k port-forward service/prometheus-grafana -n monitoring 8000:80

- <http://localhost:8000>
  - admin
  - prom-operator

## Login to Maxscale GUI

$ k port-forward service/maxscale-gui -n maxscale-operator-test 8989

- <http://localhost:8989>
  - maxscale-admin
    $ k get secret maxscale-admin -n maxscale-operator-test --template={{.data.password}} | base64 -d

## Login to Maxscale CLI

$ k exec -ti -n maxscale-operator-test maxscale-0 -- /bin/bash
$ maxctrl --user=maxscale-admin --password='PASSWORD_VALUE'
$ k get secret maxscale-admin -n maxscale-operator-test --template={{.data.password}} | base64 -d

## Queries to test the configuration

$ for INDEX in 0 1; do echo INSTANCE $INDEX:; k exec -tin maxscale-operator-test mariadb-$INDEX-0 -- bash -c 'echo "SELECT @@rpl_semi_sync_master_enabled;" | mysql -uroot -p${MARIADB_ROOT_PASSWORD}'; done

Other useful queries are the following:

- SHOW MASTER STATUS\G;
- SHOW SLAVE STATUS\G;
- SELECT @@rpl_semi_sync_master_enabled;
- SELECT @@rpl_semi_sync_slave_enabled;

## Cleanup

$ k delete -f $PATH_TO_FOLDER/maxscale/mariadb-0.yaml
$ k delete -f $PATH_TO_FOLDER/maxscale/mariadb-1.yaml
$ k delete -f $PATH_TO_FOLDER/maxscale/maxscale.yaml
$ k delete -f $PATH_TO_FOLDER/maxscale/users-0/
$ k delete -f $PATH_TO_FOLDER/maxscale/users-1/
$ k delete -f $PATH_TO_FOLDER/maxscale/user-secrets.yaml
$ k delete ns maxscale-operator-test
