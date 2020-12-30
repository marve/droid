# Droid Configuration

1. Install Debian (10.6.0 at current).
2. No desktop environment, just SSH and utilities packages
3. After installation completes, add these packages:
    * `vim`
    * `tmux`
    * `git`
    * `alsa-utils` - For [sound control](https://unix.stackexchange.com/a/21090)
    * `nfs-common`
4. [Install docker](https://docs.docker.com/engine/install/debian/).
    * Configure for [non-root access](https://docs.docker.com/engine/install/linux-postinstall/).
5. Install [docker-compose](https://docs.docker.com/compose/install/).