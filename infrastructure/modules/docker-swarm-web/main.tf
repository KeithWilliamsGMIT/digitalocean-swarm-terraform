resource "digitalocean_droplet" "swarm-manager-node" {
  count              = var.number_of_managers
  ssh_keys           = [26301808]
  image              = var.ubuntu
  region             = var.do_fra1
  size               = "s-1vcpu-1gb"
  name               = "swarm-manager-node"
  private_networking = true
  tags = [
    digitalocean_tag.docker_swarm_manager.name,
  ]

  provisioner "remote-exec" {
    script = "${path.module}/provision.sh"
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      private_key = file("~/.ssh/id_rsa")
      user        = "root"
      timeout     = "2m"
    }
  }
}

resource "digitalocean_droplet" "swarm-worker-node" {
  count              = var.number_of_workers
  ssh_keys           = [26301808]
  image              = var.ubuntu
  region             = var.do_fra1
  size               = "s-1vcpu-1gb"
  name               = "swarm-worker-node"
  private_networking = true
  tags = [
    digitalocean_tag.docker_swarm_worker.name,
  ]

  provisioner "remote-exec" {
    script        = "${path.module}/provision.sh"
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      private_key = file("~/.ssh/id_rsa")
      user        = "root"
      timeout     = "2m"
    }
  }
}

resource "digitalocean_firewall" "web-firewall" {
  name = "web-firewall"
  droplet_ids = "${flatten([
    digitalocean_droplet.swarm-manager-node.*.id,
    digitalocean_droplet.swarm-worker-node.*.id
  ])}"

  # SSH
  inbound_rule {
    protocol              = "tcp"
    port_range            = "22"
    source_addresses      = ["0.0.0.0/0", "::/0"]
  }

  # HTTP
  inbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    source_addresses      = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  inbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    source_addresses      = ["0.0.0.0/0", "::/0"]
  }

  # Internet Control Message Protocol
  inbound_rule {
    protocol              = "icmp"
    source_addresses      = ["0.0.0.0/0", "::/0"]
  }

  # DNS
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # DNS
  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTP
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Internet Control Message Protocol
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "swarm-manager-firewall" {
  name = "swarm-manager-firewall"
  droplet_ids = digitalocean_droplet.swarm-manager-node.*.id

  # Communication between Docker Swarm nodes
  inbound_rule {
    protocol              = "tcp"
    port_range            = "2377"
    source_tags           = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Communication between Docker Swarm nodes
  outbound_rule {
    protocol              = "tcp"
    port_range            = "2377"
    destination_tags      = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }
}

resource "digitalocean_firewall" "swarm-all-firewall" {
  name = "swarm-all-firewall"
  droplet_ids = "${flatten([
    digitalocean_droplet.swarm-manager-node.*.id,
    digitalocean_droplet.swarm-worker-node.*.id
  ])}"

  # Communication among nodes (container network discovery)
  inbound_rule {
    protocol              = "tcp"
    port_range            = "7946"
    source_tags           = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Communication among nodes (container network discovery)
  inbound_rule {
    protocol              = "udp"
    port_range            = "7946"
    source_tags           = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Overlay network traffic (container ingress networking)
  inbound_rule {
    protocol              = "udp"
    port_range            = "4789"
    source_tags           = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Communication among nodes (container network discovery)
  outbound_rule {
    protocol              = "tcp"
    port_range            = "7946"
    destination_tags      = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Communication among nodes (container network discovery)
  outbound_rule {
    protocol              = "udp"
    port_range            = "7946"
    destination_tags      = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Overlay network traffic (container ingress networking)
  outbound_rule {
    protocol              = "udp"
    port_range            = "4789"
    destination_tags      = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }
}

resource "digitalocean_firewall" "ceph-firewall" {
  name = "ceph-firewall"
  droplet_ids = "${flatten([
    digitalocean_droplet.swarm-manager-node.*.id,
    digitalocean_droplet.swarm-worker-node.*.id
  ])}"

  # Ceph monitor V2 protocol
  inbound_rule {
    protocol              = "tcp"
    port_range            = "3300"
    source_tags           = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Ceph monitor V1 protocol
  inbound_rule {
    protocol              = "tcp"
    port_range            = "6789"
    source_tags           = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Ceph OSD/MDS range
  inbound_rule {
    protocol              = "tcp"
    port_range            = "6800-7300"
    source_tags           = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Ceph monitor V2 protocol
  outbound_rule {
    protocol              = "tcp"
    port_range            = "3300"
    destination_tags      = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Ceph monitor V1 protocol
  outbound_rule {
    protocol              = "tcp"
    port_range            = "6789"
    destination_tags      = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }

  # Ceph OSD/MDS range
  outbound_rule {
    protocol              = "tcp"
    port_range            = "6800-7300"
    destination_tags      = [
      digitalocean_tag.docker_swarm_manager.name,
      digitalocean_tag.docker_swarm_worker.name
    ]
  }
}

resource "digitalocean_domain" "default" {
  name       = var.domain_name
  ip_address = digitalocean_droplet.swarm-manager-node[0].ipv4_address
}

resource "digitalocean_record" "wildcard" {
  domain = "${digitalocean_domain.default.name}"
  type   = "A"
  name   = "*"
  value  = digitalocean_droplet.swarm-manager-node[0].ipv4_address
}

resource "digitalocean_record" "letsencrypt" {
  domain = digitalocean_domain.default.name
  type   = "CAA"
  name   = "@"
  value  = "letsencrypt.org."
  ttl    = 1800
  flags  = 0
  tag    = "issue"
}

output "swarm_manager_urns" {
  description = "List of URNs for swarm manager droplet resources."
  value       = digitalocean_droplet.swarm-manager-node.*.urn
}

output "swarm_worker_urns" {
  description = "List of URNs for swarm worker droplet resources."
  value       = digitalocean_droplet.swarm-worker-node.*.urn
}

output "domain_urn" {
  description = "URN for domain resource."
  value       = digitalocean_domain.default.urn
}
