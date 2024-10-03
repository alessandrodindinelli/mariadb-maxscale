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
$ helm install mariadb-operator mariadb-operator/mariadb-operator --set metrics.enabled=true -n poc-mariadb-maxscale-internal --create-namespace
$ k apply -f $PATH_TO_FOLDER/maxscale/replication-enabled/user-secrets.yaml
$ k apply -f $PATH_TO_FOLDER/maxscale/replication-enabled/mariadb.yaml
$ k apply -f $PATH_TO_FOLDER/maxscale/replication-enabled/users/
$ k apply -f $PATH_TO_FOLDER/maxscale/replication-enabled/maxscale.yaml

**NB**: You can check on the logs for MariaDB that the semisync replication is enabled, you should see similar lines:
$ k logs mariadb-0 -n poc-mariadb-maxscale-internal
_2024-06-27 9:50:29 24 [Note] Semi-sync replication initialized for transactions._
_2024-06-27 9:50:29 24 [Note] Semi-sync replication enabled on the master._

## Login to Grafana dashboard

$ k port-forward service/prometheus-grafana -n monitoring 8000:80

- <http://localhost:8000>
  - admin
  - prom-operator

## Login to Maxscale GUI

$ k port-forward service/maxscale-gui -n poc-mariadb-maxscale-internal 8989

- <http://localhost:8989>
  - maxscale-admin
    $ k get secret maxscale-admin -n poc-mariadb-maxscale-internal --template={{.data.password}} | base64 -d

## Login to Maxscale CLI

$ k exec -ti -n poc-mariadb-maxscale-internal maxscale-0 -- /bin/bash
$ maxctrl --user=maxscale-admin --password='PASSWORD_VALUE'
$ k get secret maxscale-admin -n poc-mariadb-maxscale-internal --template={{.data.password}} | base64 -d

## Queries to test the configuration

$ for INDEX in 0 1; do echo INSTANCE $INDEX:; k exec -tin poc-mariadb-maxscale-internal mariadb-$INDEX-0 -- bash -c 'echo "SELECT @@rpl_semi_sync_master_enabled;" | mysql -uroot -p${MARIADB_ROOT_PASSWORD}'; done

Other useful queries are the following:

- SHOW MASTER STATUS\G;
- SHOW SLAVE STATUS\G;
- SELECT @@rpl_semi_sync_master_enabled;
- SELECT @@rpl_semi_sync_slave_enabled;

## Cleanup

$ k delete -f $PATH_TO_FOLDER/maxscale/replication-enabled/user-secrets.yaml
$ k delete -f $PATH_TO_FOLDER/maxscale/replication-enabled/mariadb.yaml
$ k delete -f $PATH_TO_FOLDER/maxscale/replication-enabled/users/
$ k delete -f $PATH_TO_FOLDER/maxscale/replication-enabled/maxscale.yaml
$ k delete ns poc-mariadb-maxscale-internal
