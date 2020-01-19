module "docker-swarm-web" {
  source = "../modules/docker-swarm-web"
}

resource "digitalocean_project" "production" {
  name        = "production"
  description = "Production environment."
  purpose     = "Web Application"
  environment = "Production"
  resources   = "${flatten([
    module.docker-swarm-web.swarm_manager_urns,
    module.docker-swarm-web.swarm_worker_urns,
    module.docker-swarm-web.domain_urn
  ])}"
}