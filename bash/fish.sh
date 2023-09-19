#!/bin/sh

FISH_D=.config/fish
FUNCTIONS_D=${FISH_D}/functions

GIST_VARIABLES=https://gist.githubusercontent.com/bfren/1ed2e8b74b4b923a0709b91a3d9eec4f/raw/c7c2b397161f903ea36ad66cb37d1cae47fba3b1/fish_variables
GIST_PROMPT=https://gist.githubusercontent.com/bfren/27304d7d4c36eff31353147590a5262d/raw/893aa58fafe2514cdec931918af4394b73c6144e/fish_prompt.fish
GIST_RIGHT=https://gist.githubusercontent.com/bfren/82695380c25bb18a29e2f6669f4dbb88/raw/3519f3e6ceb211f7af9e3ba14389b37b825ed918/fish_right_prompt.fish

cd ~
mkdir -p ${FUNCTIONS_D}

echo "Downloading..."

echo " .. fish_variables"
wget -q -O ${FISH_D}/fish_variables ${GIST_VARIABLES}

echo " .. fish_prompt.fish"
wget -q -O ${FUNCTIONS_D}/fish_prompt.fish ${GIST_PROMPT}

echo " .. fish_right_prompt.fish"
wget -q -O ${FUNCTIONS_D}/fish_right_prompt.fish ${GIST_RIGHT}

echo "Done."
