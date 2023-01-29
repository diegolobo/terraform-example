terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-22-04-x64"
  name   = "jenkins"
  region = var.region
  size   = "s-2vcpu-2gb"
}

data "digitalocean_ssh_key" "lobo" {
  name = var.ssh_key_name
}

resource "digitalocean_droplet" "conversor" {
  image    = "ubuntu-18-04-x64"
  name     = "conversor"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.lobo.id]
}

resource "digitalocean_kubernetes_cluster" "k8s-dev" {
  name   = "k8s-dev"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.25.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 1
  }
}

variable "do_token" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

variable "region" {
  default = ""
}

output "jenkins_ip" {
  value = digitalocean_droplet.conversor.ipv4_address
}