# ==========================================
# Construct KinD cluster
# ==========================================

resource "kind_cluster" "this" {
  kubeconfig_path = var.kubeconfig_path
  name            = "bootstrap"
  kind_config {

    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
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

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this, kind_cluster.this]

  embedded_manifests = true
  path               = "gitops/clusters/master"
}
