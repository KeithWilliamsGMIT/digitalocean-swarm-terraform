# Swarm nodes
variable "number_of_managers" {
  description = "Number of Swarm manager nodes"
  default     = "1"
}

variable "number_of_workers" {
  description = "Number of Swarm worker nodes"
  default     = "1"
}

# Datacenters
variable "do_fra1" {
  description = "Digital Ocean Frankfurt Data Center 1"
  default     = "fra1"
}

# Operating systems
variable "ubuntu" {
  description = "Default LTS"
  default     = "ubuntu-18-04-x64"
}

# Domain
variable "domain_name" {
  description = "The domain name for the project."
  default     = "example.com"
}
