# ==========================================
# Construct KinD cluster
# ==========================================

resource "kind_cluster" "this" {
  name           = "master"
  wait_for_ready = true
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    networking {
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

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]

  embedded_manifests = true
  path               = "gitops/clusters/master"
  lifecycle {
    replace_triggered_by = [kind_cluster.this]
  }
}
