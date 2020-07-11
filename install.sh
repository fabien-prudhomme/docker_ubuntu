#!/usr/bin/env bash

set -e

readonly COMPOSE_INSTALL=1
readonly COMPOSE_VERSION='1.26.2'

#uninstall old version
sudo apt-get -y remove docker docker-engine docker.io containerd runc

sudo apt-get -y remove \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

sudo apt-get -y remove docker-ce docker-ce-cli containerd.io


sudo apt-get update

sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get -y update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io

echo "Ajout du groupe"
#sudo groupadd -f docker

echo "Changement de droit socket"
#sudo chown root:docker /var/run/docker.sock

echo "Ajout de l'utilisateur $(whoami) au groupe docker"
#sudo adduser $(whoami) docker

echo "restart service"
#sudo systemctl restart docker

#docker --version

if [ "${COMPOSE_INSTALL}" == 1 ]; then
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi
