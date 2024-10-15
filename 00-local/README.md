# Local setup

## K3D

```Bash
k3d cluster create skytest --servers 1 --agents 3
k3d kubeconfig get skytest > config
export KUBECONFIG=config
```

## Installation

For local setup the bash scripts present in the directory were used to download and install.
The commands are the followig:

```Bash
chmod +x setup-$NAME.sh
sh setup-$NAME.sh
```

## Forward services

- Grafana
  - `kubectl port-forward service/prometheus-grafana -n monitoring 3000:80`
    - <http://localhost:8000>
      - admin
      - prom-operator

- Prometheus
  - `kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090`
    - <http://localhost:9090>

- Maxscale Exporter
  - `kubectl port-forward service/maxscale-metrics -n poc-mariadb-maxscale-external 9105`
    - <http://localhost:9105/metrics>

- Maxscale
  - `k port-forward service/maxscale-gui -n poc-mariadb-maxscale-external 8989`
    - <http://localhost:8989>
      - maxscale-admin
      - ey%3UP^68NdKQV
