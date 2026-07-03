#!/bin/bash
set -e
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/mnt/files/YouTube}"

mkdir -p "$SCRIPT_DIR/db/audio" "$SCRIPT_DIR/db/video"

run_yt_dlp() {
  local playlist_id="$1"
  shift
  docker run \
    --pull always \
    --rm \
    --volume "$DOWNLOAD_DIR:/workdir:rw" \
    ghcr.io/yt-dlp/yt-dlp:latest \
    --ignore-errors \
    --download-archive "/workdir/$playlist_id.archive" \
    --output '/workdir/%(playlist_title)s/%(title)s.%(ext)s' \
    "$@" \
    "$playlist_id"
}

for file in "$SCRIPT_DIR/db/audio/"*; do
  [[ -f "$file" ]] || continue
  playlist_id=$(basename "$file")
  echo "$(date +%T) [audio] Downloading $playlist_id"
  run_yt_dlp "$playlist_id" \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    || echo "$(date +%T) Error on $playlist_id; continuing"
done

for file in "$SCRIPT_DIR/db/video/"*; do
  [[ -f "$file" ]] || continue
  playlist_id=$(basename "$file")
  echo "$(date +%T) [video] Downloading $playlist_id"
  run_yt_dlp "$playlist_id" \
    -f 'bestvideo+bestaudio/best' \
    --merge-output-format mkv \
    || echo "$(date +%T) Error on $playlist_id; continuing"
done

echo "$(date +%T) Done"