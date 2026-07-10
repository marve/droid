# Purpose
Network-wide DNS ad-blocking and DHCP server using [Pi-hole](https://pi-hole.net/).

# Usage
The admin web interface is available at `http://your-host-ip/admin`. The service runs in host-networking mode so it can handle DHCP and DNS traffic on the standard ports (53/UDP+TCP, 67/UDP, 80/TCP).

Configuration (blocklists, DNS records, DHCP leases) is persisted to `/mnt/files/pihole/`.

The admin password is stored in a file named `password` in this directory (excluded from git via `.gitignore`). Create it before starting the service:
```bash
echo 'your-password' > services/pihole/password
```
