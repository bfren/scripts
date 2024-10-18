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

FISH_REPO=https://download.opensuse.org/repositories/shells:fish:release:3/Debian_12

curl -fsSL ${FISH_REPO}/Release.key \
    | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null

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
    apt install -y fish docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nano


#======================================================================================================================
# No password for sudo.
#======================================================================================================================

echo "Adding no-password for sudo"

echo "$USER ALL=(ALL) NOPASSWD: ALL" \
    | sudo tee /etc/sudoers.d/10-$USER


#======================================================================================================================
# Docker permissions for current user.
#======================================================================================================================

echo "Adding Docker permissions"

sudo usermod -aG docker $USER


#======================================================================================================================
# Fish config.
#======================================================================================================================

echo "Adding fish configuration"

FISH_D=~/.config/fish
FUNCTIONS_D=${FISH_D}/functions

GIST=https://gist.githubusercontent.com/bfren
GIST_VARIABLES=${GIST}/1ed2e8b74b4b923a0709b91a3d9eec4f/raw/fish_variables
GIST_PROMPT=${GIST}/27304d7d4c36eff31353147590a5262d/raw/fish_prompt.fish
GIST_RIGHT=${GIST}/82695380c25bb18a29e2f6669f4dbb88/raw/fish_right_prompt.fish

mkdir -p ${FUNCTIONS_D}

echo " .. fish_variables"
curl -fsSL ${GIST_VARIABLES} \
    | tee ${FISH_D}/fish_variables > /dev/null

echo " .. fish_prompt.fish"
curl -fsSL ${GIST_PROMPT} \
    | tee ${FUNCTIONS_D}/fish_prompt.fish > /dev/null

echo " .. fish_right_prompt.fish"
curl -fsSL ${GIST_RIGHT} \
    | tee ${FUNCTIONS_D}/fish_right_prompt.fish > /dev/null


#======================================================================================================================
# SSH keys.
#======================================================================================================================

echo "Adding authorised keys"

curl -fsSL https://bfren.dev/ssh \
    | tee ~/.ssh/authorized_keys > /dev/null

echo "Done."
