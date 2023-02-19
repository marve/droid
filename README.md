# Droid Configuration

1. Install Debian (11 at current).
2. No desktop environment, just SSH and utilities packages
3. After installation completes, add these packages:
    ```bash
    sudo apt install \
        vim tmux \ # Useful utilities
        git \ # To clone this repository!
        alsa-utils \ # For sound control: https://unix.stackexchange.com/a/21090
        nfs-common \ # Mount NFS shares
        vainfo intel-gpu-tools \ # Tools and drivers for Intel GPU
        htop iftop \ # Monitor resource utilization
        dnsutils # Network troubleshooting
    ```
4. [Install docker](https://docs.docker.com/engine/install/debian/).
    * Configure for [non-root access](https://docs.docker.com/engine/install/linux-postinstall/).
5. Install [docker-compose](https://docs.docker.com/compose/install/).

# Service

Each subdirectory in `services/` represents a service and at minimum must have a `.service` file describing a [systemd unit](https://www.freedesktop.org/software/systemd/man/systemd.unit.html). The service may optionally specify a `Dockerfile` and/or a `docker-compose.yml`.

To apply services (i.e., create or update) to a host, run `apply.sh`. Optionally use `apply.sh <serviceName>` to apply a single service.

To remove services from the host, run `uninstall.sh`

To disable a service, add a file named `disable` to the service directory and run `apply.sh`.