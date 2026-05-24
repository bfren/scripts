#!/bin/bash

set -euo pipefail


#======================================================================================================================
# Packages for GPG keyrings.
#======================================================================================================================

echo "Adding packages for GPG keyrings"

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive \
    apt install -y ca-certificates curl gnupg


#======================================================================================================================
# Fish repository.
#======================================================================================================================

echo "Setting up fish repository"

FISH_REPO=http://download.opensuse.org/repositories/shells:/fish:/release:/4/Debian_13

curl -fsSL ${FISH_REPO}/Release.key \
    | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_4.gpg > /dev/null

echo "deb ${FISH_REPO}/ /" \
    | sudo tee /etc/apt/sources.list.d/fish.list


#======================================================================================================================
# Docker repository.
#======================================================================================================================

echo "Setting up Docker repository"

DOCKER_REPO=https://download.docker.com/linux/debian

curl -fsSL ${DOCKER_REPO}/gpg \
    | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null

echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] ${DOCKER_REPO} \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list


#======================================================================================================================
# Install packages.
#======================================================================================================================

echo "Installing packages"

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive \
    apt install -y fish docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin htop nano ufw


#======================================================================================================================
# No password for sudo.
#======================================================================================================================

echo "Adding no-password for sudo"

echo "$USER ALL=(ALL) NOPASSWD: ALL" \
    | sudo tee /etc/sudoers.d/10-$USER


#======================================================================================================================
# Docker config.
#======================================================================================================================

echo "Adding Docker configuration"

echo " .. adding current user to Docker group"
sudo usermod -aG docker $USER

echo "Adding standard Docker format"

DOCKER_D=~/.docker

GIST=https://gist.githubusercontent.com/bfren
GIST_DOCKER=${GIST}/cba6ec693dc52395998005d81fff0834/raw/24df20f446f5c96e6258635c30266b2b48b87437/config.json

mkdir ${DOCKER_D}

echo " .. adding Docker config overrides"
curl -fsSL ${GIST_DOCKER} \
    | tee ${DOCKER_D}/config.json > /dev/null


#======================================================================================================================
# Fish config.
#======================================================================================================================

echo "Adding fish configuration"

FISH_D=~/.config/fish
CONF_D=${FISH_D}/conf.d
FUNCTIONS_D=${FISH_D}/functions

GIST_PROMPT=${GIST}/27304d7d4c36eff31353147590a5262d/raw/fish_prompt.fish
GIST_RIGHT=${GIST}/82695380c25bb18a29e2f6669f4dbb88/raw/fish_right_prompt.fish
GIST_THEME=${GIST}/35621b8701d6da87cf32b68e7da711f7/raw/cde3a649650588e5fd35d9d1b798ff464a2218b7/fish_theme.fish

mkdir -p ${CONF_D}
mkdir ${FUNCTIONS_D}

echo " .. fish_theme.fish"
curl -fsSL ${GIST_THEME} \
    | tee ${CONF_D}/fish_theme.fish > /dev/null

echo " .. fish_prompt.fish"
curl -fsSL ${GIST_PROMPT} \
    | tee ${FUNCTIONS_D}/fish_prompt.fish > /dev/null

echo " .. fish_right_prompt.fish"
curl -fsSL ${GIST_RIGHT} \
    | tee ${FUNCTIONS_D}/fish_right_prompt.fish > /dev/null

echo ".. default shell for current user"
command -v fish | sudo tee -a /etc/shells
sudo chsh -s "$(command -v fish)" ${USER}


#======================================================================================================================
# SSH keys.
#======================================================================================================================

echo "Adding authorised keys"

curl -fsSL https://bfren.dev/ssh \
    | tee ~/.ssh/authorized_keys > /dev/null

echo "Done."
