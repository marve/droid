# Purpose
Download YouTube playlists via yt-dlp

# Usage

Add a playlist, channel, or video URL/ID as a file in one of the two subdirectories under `db/`:

| Directory | Behaviour |
|-----------|-----------|
| `db/audio/` | Extract audio only (MP3, best quality) |
| `db/video/` | Download best video+audio, mux to MKV |

The **filename** of the file is the playlist or channel ID/URL. The file content is ignored.

Example – add a playlist to the audio-only queue:
```bash
touch services/youtube-dl/db/audio/PLxxxxxxxxxxxxxxxx
```

yt-dlp tracks already-downloaded videos in a per-playlist archive file at `/mnt/files/YouTube/<playlist_id>.archive`, so re-running the service never re-downloads existing content.

# Schedule

The service runs nightly at 02:00 via `youtube-dl.timer`. To trigger a manual run:
```bash
sudo systemctl start youtube-dl.service
```

# Dependencies

Only Docker is required on the host. yt-dlp runs inside `ghcr.io/yt-dlp/yt-dlp:latest` and is updated automatically on each run (`--pull always`).
