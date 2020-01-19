module "docker-swarm-web" {
  source = "../modules/docker-swarm-web"
  domain_name = "staging.example.com"
}

resource "digitalocean_project" "staging" {
  name        = "staging"
  description = "Staging environment."
  purpose     = "Web Application"
  environment = "Staging"
  resources   = "${flatten([
    module.docker-swarm-web.swarm_manager_urns,
    module.docker-swarm-web.swarm_worker_urns,
    module.docker-swarm-web.domain_urn
  ])}"
}