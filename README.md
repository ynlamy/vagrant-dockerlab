# vagrant-dockerlab

A Docker CE development environment with [Vagrant](https://www.vagrantup.com/) using [VMware Workstation](https://www.vmware.com/) created by Yoann LAMY under the terms of the [GNU General Public License v3](http://www.gnu.org/licenses/gpl.html).

This Docker CE environment is based on a [Rocky Linux 9](https://rockylinux.org/) distribution and contains :
* [Docker CE](https://www.docker.com/)
* [Docker Registry](https://hub.docker.com/_/registry) is a private docker registry
* [Docker Registry UI](https://github.com/Joxit/docker-registry-ui) is a user interface for your private docker registry
* [Dive](https://github.com/wagoodman/dive) is a tool for exploring a Docker image  and discovering layer contents
* [Hadolint](https://github.com/hadolint/hadolint) is a Dockerfile linter that helps you build best practice Docker images
* [Lazydocker](https://github.com/jesseduffield/lazydocker) is a terminal UI for both docker and docker-compose
* [Trivy](https://github.com/aquasecurity/trivy) is a security scanner

The timezone can be defined through the ``Vagrantfile``.

### Usage

- ``cd vagrant-dockerlab``
- Edit ``Vagrantfile`` to customize settings :

```
  ...
  # Provisioning script
  config.vm.provision "shell", path: "provisioning.sh", env: {
    "TIMEZONE" => "Europe/Paris", # Timezone to be used by the system
    "DOCKER_REGISTRY_UI_INSTALL" => "true", # Install Docker Registry UI or not
    "DIVE_INSTALL" => "true", # Install Dive or not
    "HADOLINT_INSTALL" => "true", # Install Hadolint or not
    "LAZYDOCKER_INSTALL" => "true", # Install Lazydocker or not
    "TRIVY_INSTALL" => "true" # Install Trivy or not
  }
  ...
```

This LAMP environment must be started using Vagrant.

- ``vagrant up``

```
    ...
    default: Disbaling SELinux...
    default: Configuring Timezone...
    default: Cleaning dnf cache...
    default: Updating the system...
    default: Installing Docker CE...
    default: Installing Dive...
    default: Installing Hadolint...
    default: Installing Lazydocker...
    default: Installing Trivy...
    default: Configuring Docker CE...
    default: Starting Docker CE...
    default: Installing Docker Registry UI...
    default:
    default: Docker Lab is ready !
    default: - Docker CE version : 29.1.3
    default: - Docker Compose version : 5.0.0
    default: - Dive version : 0.13.1
    default: - Hadolint version : 2.14.0
    default: - Lazydocker version : 0.24.3
    default: - Trivy version : 0.68.2
    default:
    default: Informations :
    default: - Guest IP address : xxx.xxx.xxx.xxx
    default: - Docker Registry UI URL : http://127.0.0.1:8080/
```

And it must be destroy using Vagrant.

- ``vagrant destroy``

```
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
    ...
```