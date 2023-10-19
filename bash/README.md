# Bash Scripts

## Debian Setup

`wget -q -O - "https://raw.githubusercontent.com/bfren/scripts/main/bash/setup-debian.sh" | bash`

## Add SSH keys

`wget -q -O ~/.ssh/authorized_keys "https://github.com/bfren.keys"`

## Nushell

`wget -q -O - "https://raw.githubusercontent.com/bfren/scripts/main/bash/nu.sh" | bash /dev/stdin "0.86.0"`

## Fish

`wget -q -O - "https://raw.githubusercontent.com/bfren/scripts/main/bash/fish.sh" | bash`

## Show Temperature

Simple script to show the temperature of the GPU and CPU of a Raspberry Pi.  It may work in other environments too,
but is untested.

`wget -q https://raw.githubusercontent.com/bfren/scripts/main/bash/show-temp.sh && chmod +x show-temp.sh`

## Backup

Server backup script (using `rsync` or `rclone`) with the following options:

- all options (including what to backup) loaded via `backup-config.sh`
- custom arguments
- supports exclusions by text file
- basic output to stdout, everything else to log file
- rotates log files daily
- compresses backup to a separate folder
- backup file splitting (default 1024m)
- removes old files and compressed backups (default after 28 days)

To install use the following:

`curl https://raw.githubusercontent.com/bfren/scripts/main/bash/do-backup.sh > do-backup.sh | chmod +x do-backup.sh`

You also need to download the `utils.sh` file in the same directory:

`curl https://raw.githubusercontent.com/bfren/scripts/main/bash/utils.sh > utils.sh`

Then you need to create file `backup-config.sh` in the same directory.  A sample config file is available to download it
and edit with your details:

`curl https://raw.githubusercontent.com/bfren/scripts/main/bash/backup-config-sample.sh > backup-config.sh`
