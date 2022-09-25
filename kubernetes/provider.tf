terraform {
  required_version = ">=1.1.2"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}