# DigitalOcean Swarm Terraform

This repository shows how to create DigitalOcean resources for Docker Swarm using [Terraform](https://www.terraform.io/). There are three directories that represent three different environments. They are `development`, `staging` and `production`. It also configures the firewall to open ports required by Ceph for distributed storage. However, if you are not using Ceph these ports should be closed.

## Getting Started

The first step to getting started is to clone the repository:

```bash
git clone https://github.com/KeithWilliamsGMIT/digitalocean-swarm-terraform.git
```

Next, install Terraform and initialise the modules, provider plugins and the backend with the following command:

```bash
terraform init
```

Then, in the the DigitalOcean console under `Manage > API > Tokens/Keys`, create a new personal access token with read and write access and export it as an environment variable.

```bash
export DIGITALOCEAN_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

You will also need to generate a new SSH key and add it to the DigitalOcean console under `Account > Security >  SSH Keys` if you have not already done so. You can generate an SSH key with the below command and save it to `~/.ssh/`.

```bash
ssh-keygen -t rsa -b 4096 -C "example@example.com"
```

Get the ID of the new SSH key once added to DigitalOcean using `curl` as shown below:

```bash
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/account/keys"
```

Copy this ID to the `ssh_keys` field on each droplet resource. Finally, in one of the environment directories (`development`, `staging` or `production`) run the following command to create all the resources defined in the module:

```bash
terraform apply
```

## Does it work?

Login to the DigitalOcean console and check that a new project has been created with all the resources defined in the module.

## Further configuration

There are a number of variables that can be changed when creating resources. The list of variables that are available by default can be found in the table below:

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| number_of_managers | The number of droplets with a Docker Swarm manager label to be created | 1 |
| number_of_workers | The number of droplets with a Docker Swarm worker label to be created | 1 |
| do_fra1 | The datacenter to create the droplets in | fra1 |
| ubuntu | The Ubuntu operating system that will be installed on the droplets | ubuntu-18-04-x64 |
| domain_name | The domain name that will point to the droplets | example.com |

## Contributing

Any contribution to this repository is appreciated, whether it is a pull request, bug report, feature request, feedback or even starring the repository. Some potential areas that need further refinement are:

+ Refactoring
+ Documentation

## Conclusion

This repository demonstates how Terraform can be used to create infrastructure in DigitalOcean suitable for Docker Swarm.
