#!/bin/bash

# Description : A Docker CE development environment with Vagrant using VMware Workstation
# Author : Yoann LAMY <https://github.com/ynlamy/vagrant-dockerlab>
# Licence : GPLv3

# Provisioning script for Rocky Linux 9 system
echo "Disbaling SELinux..."
setenforce 0
sed -i 's/SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/' /etc/selinux/config

echo "Configuring Timezone..."
timedatectl set-timezone $TIMEZONE

echo "Cleaning dnf cache..."
dnf -y -q clean all &>/dev/null

echo "Updating the system..."
dnf -y -q update --exclude=kernel* &>/dev/null

echo "Installing Docker CE..."
dnf -y -q config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &>/dev/null
dnf -y -q install docker-ce &>/dev/null

echo "Installing Lazydocker..."
LAZYDOCKER_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/jesseduffield/lazydocker/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
LAZYDOCKER_FILENAME="lazydocker_${LAZYDOCKER_LATEST_VERSION//v/}_Linux_x86_64.tar.gz"
LAZYDOCKER_URL="https://github.com/jesseduffield/lazydocker/releases/download/${LAZYDOCKER_LATEST_VERSION}/${LAZYDOCKER_FILENAME}"
curl -L -s -o lazydocker.tar.gz $LAZYDOCKER_URL &>/dev/null
tar -xzf lazydocker.tar.gz lazydocker
install -Dm 755 lazydocker -t "/usr/local/bin"
rm -f lazydocker lazydocker.tar.gz

echo "Installing Hadolint..."
HADOLINT_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/hadolint/hadolint/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
HADOLINT_URL="https://github.com/hadolint/hadolint/releases/download/${HADOLINT_LATEST_VERSION}/hadolint-Linux-x86_64"
curl -L -s -o hadolint $HADOLINT_URL &>/dev/null
mv hadolint /usr/local/bin/
chmod +x /usr/local/bin/hadolint

echo "Installing Trivy..."
TRIVY_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/aquasecurity/trivy/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
TRIVY_FILENAME="trivy_${TRIVY_LATEST_VERSION//v/}_Linux-64bit.rpm"
TRIVY_URL="https://github.com/aquasecurity/trivy/releases/download/${TRIVY_LATEST_VERSION}/${TRIVY_FILENAME}"
dnf -y -q install $TRIVY_URL &>/dev/null

echo "Configuring Docker CE..."
usermod -aG docker vagrant
echo "{
    \"insecure-registries\": [\"localhost:5000\"],
    \"registry-mirrors\": [\"http://localhost:5000\"]
}" >> /etc/docker/daemon.json

echo "Starting Docker CE..."
systemctl enable --now docker &>/dev/null

echo "Installing Docker Registry..."
echo "version: '3.8'
services:
  registry:
    container_name: registry
    image: registry:latest
    restart: always
    ports:
      - 5000:5000
    volumes:
      - /registry:/var/lib/registry
      - ./docker-registry-config.yml:/etc/docker/registry/config.yml
    networks:
      - registry-network

  registry-ui:
    container_name: registry-ui
    image: joxit/docker-registry-ui:latest
    restart: always
    ports:
      - 8080:80
    environment:
      - NGINX_PROXY_PASS_URL=http://registry:5000
      - REGISTRY_TITLE=Docker Lab
      - SINGLE_REGISTRY=true
      - REGISTRY_SECURED=false
      - DELETE_IMAGES=true
    depends_on:
      - registry
    networks:
      - registry-network

networks:
  registry-network:
" >> docker-registry.yml
echo "version: 0.1
log:
  fields:
    service: registry
storage:
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    Access-Control-Allow-Origin: ['*']
    Access-Control-Allow-Methods: ['HEAD', 'GET', 'OPTIONS', 'DELETE']
    Access-Control-Allow-Headers: ['Authorization', 'Accept', 'Cache-Control']
    Access-Control-Expose-Headers: ['Docker-Content-Digest']
" >> docker-registry-config.yml
docker compose -f docker-registry.yml up -d &>/dev/null
rm -f docker-registry.yml
rm -f docker-registry-config.yml

echo -e "\nDocker Lab is ready !"
echo "- Docker CE version :" `dnf info docker-ce | grep -i "Version" | awk '{ print $3 }'`
echo "- Docker Compose version :" `dnf info docker-compose-plugin | grep -i "Version" | awk '{ print $3 }'`
echo "- Lazydocker version :" `/usr/local/bin/lazydocker --version | grep -i "Version" | awk '{ print $2 }'`
echo "- Hadolint version :" `/usr/local/bin/hadolint --version | awk '{ print $4 }'`
echo "- Trivy version :" `dnf info trivy | grep -i "Version" | awk '{ print $3 }'`
echo -e "\nInformations :"
echo "- Guest IP address :" `ip address show eth0 | grep 'inet ' | sed -e 's/^.*inet //' -e 's/\/.*$//'`
echo "- Docker Registry UI URL : http://127.0.0.1:8080/"
