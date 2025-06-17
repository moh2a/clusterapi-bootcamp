# ==========================================
# Construct KinD cluster
# ==========================================

resource "docker_network" "kind_network" {
  name   = "kind-fixed-subnet"
  driver = "bridge"

  ipam_config {
    subnet  = "172.18.0.0/16"
    gateway = "172.18.0.1"
  }
}
resource "kind_cluster" "this" {
  kubeconfig_path = var.kubeconfig_path
  name            = "master"
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    networking {
      api_server_address  = "172.18.0.103"
      disable_default_cni = true
      pod_subnet          = "10.10.0.0/16"
      service_subnet      = "10.11.0.0/16"
    }
    node {
      role = "control-plane"
      extra_mounts {
        host_path      = "/var/lib/docker"
        container_path = "/var/lib/docker"
      }
      extra_mounts {
        host_path      = "/var/run/docker.sock"
        container_path = "/var/run/docker.sock"
      }
    }
    node {
      role = "worker"
      extra_mounts {
        host_path      = "/var/lib/docker"
        container_path = "/var/lib/docker"
      }
      extra_mounts {
        host_path      = "/var/run/docker.sock"
        container_path = "/var/run/docker.sock"
      }
    }
  }
}

# ==========================================
# Add deploy key to GitHub repository
# ==========================================

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = var.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

# ==========================================
# Bootstrap KinD cluster
# ==========================================

resource "helm_release" "cilium" {
  depends_on = [kind_cluster.this]
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.17.0"
  namespace  = "kube-system"
  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this, kind_cluster.this]

  embedded_manifests = true
  path               = "gitops/clusters/master"
}
