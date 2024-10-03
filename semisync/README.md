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
$ helm install mariadb-operator-semisync mariadb-operator/mariadb-operator --set metrics.enabled=false -n poc-mariadb-semisync
$ k apply -f $PATH_TO_FOLDER/semisync/semisync.yaml

## Queries to test the configuration

$ for INDEX in 0 1 2; do echo Instance $INDEX:; k exec -tin maxscale-operator-test mariadb-semisync-$INDEX -- bash -c 'echo "SELECT @@rpl_semi_sync_master_enabled;" | mysql -uroot -p${MARIADB_ROOT_PASSWORD}'; done

Other useful queries are the following:

- SHOW MASTER STATUS\G;
- SHOW SLAVE STATUS\G;
- SELECT @@rpl_semi_sync_master_enabled;
- SELECT @@rpl_semi_sync_slave_enabled;

## Cleanup

$ k delete -f $PATH_TO_FOLDER/semisync/semisync.yaml
$ k delete ns maxscale-operator-test
