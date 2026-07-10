# Purpose
Manages Ubiquiti UniFi network devices using the [UniFi Controller](https://ui.com/consoles) software.

> **Note:** This service is currently disabled (a `disable` file is present). To enable it, remove the `disable` file and re-run `apply.sh`.

# Usage
Once enabled, the controller web interface is available at `https://your-host-ip:8443`.

Controller configuration is stored in `/tmp/unifi-controller/config` (not persisted across reboots by default — move the volume path to a permanent location if needed).
