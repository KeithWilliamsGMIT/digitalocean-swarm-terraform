resource "digitalocean_tag" "docker_swarm_manager" {
  name = "docker_swarm_manager"
}

resource "digitalocean_tag" "docker_swarm_worker" {
  name = "docker_swarm_worker"
}
