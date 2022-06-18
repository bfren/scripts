# Standard Config Files

## Docker

```bash
mkdir -p ~/.docker
cd ~/.docker
curl https://raw.githubusercontent.com/bfren/scripts/main/dot/docker/config.json > config.json
```

## Fish

See [fish](https://fishshell.com/).

```bash
cd ~/.config/fish
curl https://raw.githubusercontent.com/bfren/scripts/main/dot/config/fish/fish_variables > fish_variables
cd ~/.config/fish/functions
curl https://raw.githubusercontent.com/bfren/scripts/main/dot/config/fish/functions/fish_prompt.fish > fish_prompt.fish
cd
```
