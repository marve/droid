# Purpose
Mounts the NFS backup share from the NAS (`192.168.1.3:/volume1/usbshare1-2`) at `/mnt/backup`.

# Usage
The mount is managed by systemd and comes up automatically after the network is available. Other services that depend on `/mnt/backup` should list `mnt-backup.mount` in their `After=` and `Requires=` directives.
