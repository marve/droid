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

# Service

Each subdirectory in `services/` represents a service and at minimum must have a `.service` file describing a [systemd unit](https://www.freedesktop.org/software/systemd/man/systemd.unit.html). The service may optionally specify a `Dockerfile` and/or a `docker-compose.yml`.

To apply services (i.e., add new services, updating any existing) to the host, run `install.sh`.

To remove services from the host, run `uninstall.sh`

To disable a service, add a file named `disable` to the service directory and run `install.sh`.