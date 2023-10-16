#!/bin/sh

FISH_D=~/.config/fish
FUNCTIONS_D=${FISH_D}/functions

GIST_VARIABLES=https://gist.githubusercontent.com/bfren/1ed2e8b74b4b923a0709b91a3d9eec4f/raw/fish_variables
GIST_PROMPT=https://gist.githubusercontent.com/bfren/27304d7d4c36eff31353147590a5262d/raw/fish_prompt.fish
GIST_RIGHT=https://gist.githubusercontent.com/bfren/82695380c25bb18a29e2f6669f4dbb88/raw/fish_right_prompt.fish

mkdir -p ${FUNCTIONS_D}

echo "Downloading..."

echo " .. fish_variables"
wget -q -O ${FISH_D}/fish_variables ${GIST_VARIABLES}

echo " .. fish_prompt.fish"
wget -q -O ${FUNCTIONS_D}/fish_prompt.fish ${GIST_PROMPT}

echo " .. fish_right_prompt.fish"
wget -q -O ${FUNCTIONS_D}/fish_right_prompt.fish ${GIST_RIGHT}

echo "Done."
