# Purpose
Mounts the primary NFS file share from the NAS (`192.168.1.3:/volume1/files`) at `/mnt/files`.

# Usage
The mount is managed by systemd and comes up automatically after the network is available. Services that rely on `/mnt/files` (pihole, plex, lubelog, youtube-dl) should list `mnt-files.mount` in their `After=` and `Requires=` directives.
