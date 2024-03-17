# -*- mode: ruby -*-
# vi: set ft=ruby :

# Description : A Docker CE development environment with Vagrant using VMware Workstation
# Author : Yoann LAMY <https://github.com/ynlamy/vagrant-dockerlab>
# Licence : GPLv3

# Vagrant version requirement
Vagrant.require_version ">= 2.0.0"

Vagrant.configure("2") do |config|
  # Box used ("rockylinux/9" is compatible with the provider "vmware_desktop")
  config.vm.box = "rockylinux/9"

  # Box must be up to date
  config.vm.box_check_update = true

  # VM Hostname
  config.vm.hostname = "dockerlab"

  # The plugins vagrant "vagrant-vmware-desktop" is required
  config.vagrant.plugins = "vagrant-vmware-desktop"

  # Provider configuration for "vmware_desktop"
  config.vm.provider "vmware_desktop" do |vmw|
    vmw.gui = true
    vmw.vmx["displayName"] = "dockerlab"
    vmw.vmx["numvcpus"] = "2"
    vmw.vmx["memsize"] = "2048"
  end

  # Forwarded port for Docker Registry UI
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"

  # Share an additional folder to the guest VM for Docker
  config.vm.synced_folder "docker", "/docker"

  # Share an additional folder to the guest VM for Docker Registry
  config.vm.synced_folder "registry", "/registry"

  # Disable the default share of the current code directory
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provisioning script
  config.vm.provision "shell", path: "provisioning.sh", env: {
    "TIMEZONE" => "Europe/Paris" # Timezone to be used by the system
  }
end