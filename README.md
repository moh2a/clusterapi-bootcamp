# Pré-requis

## Outils

Avoir un environnement linux avec docker
Installer les programmes suivants

- kubectl
- terraform

## Augmenter les paramètres inotify

```sh
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
```

## Configuration Github

### Fork

Faire un fork de ce repository

### Personal Access Token

Créer un ([PAT](https://github.com/settings/personal-access-tokens)) sur votre fork avec les droits admin (Read and Write).

# Installation

## Bootstrap

Pour lancer le cluster maître, lancer les commandes suivantes :

```sh
cd bootsrap
terraform init
terraform apply -var "github_org=<orgname>" -var "github_token=<pat>"
```

# Kubezen (premier cluster avec clusterapi)

## Création

Pour créer kubezen, executer la commande :

```sh
kubectl apply -f samples/clusters/kubezen.yaml
```

## Récupérer le kubeconfig

Pour récupérer le kubeconfig, executer les commandes :

```sh
KUBEZEN_SERVER=localhost:$(docker inspect -f '{{ (index (index .NetworkSettings.Ports "6443/tcp") 0).HostPort }}' kubezen-lb)
kubectl get secret -n kubezen kubezen-kubeconfig -o jsonpath="{.data.value}" | base64 -d | sed "s/kubezen-lb:6443/${KUBEZEN_SERVER}/g" > kubezen-config
```

## Tester

Executer la commande :

```
kubectl get no -o wide --kubeconfig=kubezen-config
```

Deux nodes doivent être à l'état Ready.
