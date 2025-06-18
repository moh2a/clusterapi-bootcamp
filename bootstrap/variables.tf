variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
  default     = "clusterapi-bootcamp"
}

variable "kubeconfig_path" {
  type        = string
  default     = "./master-config"
  description = "Kubeconfig file path where kind cluster should save it."
}
