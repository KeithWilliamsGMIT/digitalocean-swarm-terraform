module "docker-swarm-web" {
  source = "../modules/docker-swarm-web"
  domain_name = "development.example.com"
}

resource "digitalocean_project" "development" {
  name        = "development"
  description = "Development environment."
  purpose     = "Web Application"
  environment = "Development"
  resources   = "${flatten([
    module.docker-swarm-web.swarm_manager_urns,
    module.docker-swarm-web.swarm_worker_urns,
    module.docker-swarm-web.domain_urn
  ])}"
}