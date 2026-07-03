#!/bin/bash
set -e
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/mnt/files/YouTube}"

mkdir -p "$SCRIPT_DIR/db/audio" "$SCRIPT_DIR/db/video"

# --- helpers ----------------------------------------------------------------

ts() { date +%T; }

check_docker() {
  if ! docker info > /dev/null 2>&1; then
    echo "$(ts) [error] Docker daemon is not reachable; aborting"
    exit 1
  fi
}

# Run yt-dlp for one playlist, log duration, download count, and exit code.
# Usage: run_yt_dlp <type> <playlist_id> [extra yt-dlp flags…]
run_yt_dlp() {
  local type="$1" playlist_id="$2"
  shift 2
  local archive="$DOWNLOAD_DIR/$playlist_id.archive"
  local start
  start=$(date +%s)

  echo "$(ts) [$type] Starting $playlist_id (archive: $archive)"

  local output
  local exit_code=0
  output=$(docker run \
    --pull always \
    --rm \
    --volume "$DOWNLOAD_DIR:/workdir:rw" \
    ghcr.io/yt-dlp/yt-dlp:latest \
    --ignore-errors \
    --download-archive "/workdir/$playlist_id.archive" \
    --output '/workdir/%(playlist_title)s/%(title)s.%(ext)s' \
    "$@" \
    "$playlist_id" 2>&1) || exit_code=$?

  local elapsed=$(( $(date +%s) - start ))
  local downloaded
  downloaded=$(echo "$output" | grep -c '^\[download\] Destination:' || true)

  echo "$output"

  if [[ $exit_code -ne 0 ]]; then
    echo "$(ts) [$type] Error on $playlist_id (exit code: $exit_code, duration: ${elapsed}s); continuing"
  else
    echo "$(ts) [$type] Finished $playlist_id: $downloaded new file(s) downloaded (duration: ${elapsed}s)"
  fi
}

# --- main -------------------------------------------------------------------

check_docker

script_start=$(date +%s)
echo "$(ts) Starting youtube-dl run"

audio_count=0
video_count=0

for file in "$SCRIPT_DIR/db/audio/"*; do
  [[ -f "$file" ]] || continue
  (( audio_count++ )) || true
done

for file in "$SCRIPT_DIR/db/video/"*; do
  [[ -f "$file" ]] || continue
  (( video_count++ )) || true
done

if [[ $audio_count -eq 0 && $video_count -eq 0 ]]; then
  echo "$(ts) [warn] No playlists configured in db/audio/ or db/video/; nothing to do"
  exit 0
fi

echo "$(ts) Found $audio_count audio playlist(s) and $video_count video playlist(s)"

for file in "$SCRIPT_DIR/db/audio/"*; do
  [[ -f "$file" ]] || continue
  playlist_id=$(basename "$file")
  run_yt_dlp audio "$playlist_id" \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0
done

for file in "$SCRIPT_DIR/db/video/"*; do
  [[ -f "$file" ]] || continue
  playlist_id=$(basename "$file")
  run_yt_dlp video "$playlist_id" \
    -f 'bestvideo+bestaudio/best' \
    --merge-output-format mkv
done

total_elapsed=$(( $(date +%s) - script_start ))
echo "$(ts) Done (total duration: ${total_elapsed}s)"