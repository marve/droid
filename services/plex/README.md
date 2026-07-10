# Purpose
Media server using [Plex Media Server](https://www.plex.tv/) with Intel QuickSync hardware transcoding.

# Usage
The Plex web interface is available at `http://your-host-ip:32400/web`. The service runs in host-networking mode.

| Path on host | Purpose |
|---|---|
| `/opt/plex-data` | Persistent Plex configuration and metadata |
| `/mnt/files` | Media library (movies, TV shows, music) |
| `/mnt/photo` | Photo library |
| `/tmp/plex-transcode` | Temporary transcoding scratch space |

The custom `Dockerfile` installs Intel GPU driver tools (`vainfo`) on top of the official Plex image to enable QuickSync acceleration via `/dev/dri`.
