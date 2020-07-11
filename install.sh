#!/usr/bin/env bash

set -e

originalPath=$(pwd)

. $originalPath/conf/function.sh


# configure .env
for line in $(cat ./conf/.env.dist | grep -vE '^#')
do
    key=$(echo ${line} | awk -F "=" '{print $1}')
    configureEnv ${key} $(getEnvValue ${key})
done

displaybegin "Update du système"
sudo apt-get update > log 2>&1
displayEnd "Update du système"

displaybegin "Install common tools"
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common > log 2>&1
displayEnd "Install common tools"


displaybegin "Ajout du repository"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > log 2>&1

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" > log 2>&1
displayEnd "Ajout du repository"

if [ $(getEnvValue 'FRESH_INSTALL') != "yes" ]
then
    displaybegin "Remove old package"
    sudo apt-get -y remove docker docker-engine docker.io containerd runc > log 2>&1
    sudo apt-get -y remove docker-ce docker-ce-cli containerd.io > log 2>&1
    displayEnd "Remove old package"
fi

displaybegin "Install docker"
sudo apt-get -y update > log 2>&1
sudo apt-get -y install docker-ce docker-ce-cli containerd.io > log 2>&1
displayEnd "Install docker"

COMPOSE_INSTALL=$(getEnvValue 'COMPOSE_INSTALL')
COMPOSE_VERSION=$(getEnvValue 'COMPOSE_VERSION')


if [ "${COMPOSE_INSTALL}" == yes ]; then
    displaybegin "Install docker compose"
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose  > log 2>&1
    sudo chmod +x /usr/local/bin/docker-compose  > log 2>&1
    displayEnd "Install docker compose"
fi

displaybegin "post config"
sed "s/^FRESH_INSTALL=.*$/FRESH_INSTALL=no/" -i .env
sed "s/^COMPOSE_INSTALL=.*$//" -i .env
displayEnd "post config"
