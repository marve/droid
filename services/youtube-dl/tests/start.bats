#!/usr/bin/env bats

START_SH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/start.sh"

setup() {
  # Isolated temp tree per test
  TEST_DIR="$(mktemp -d)"
  MOCK_DIR="$(mktemp -d)"
  export SCRIPT_DIR="$TEST_DIR"
  export DOWNLOAD_DIR="$TEST_DIR/download"
  export DOCKER_CALLS_FILE="$TEST_DIR/docker_calls"

  mkdir -p "$TEST_DIR/db/audio" "$TEST_DIR/db/video" "$DOWNLOAD_DIR"

  # Fake docker binary that records its arguments
  cat > "$MOCK_DIR/docker" <<'EOF'
#!/bin/bash
echo "$@" >> "$DOCKER_CALLS_FILE"
EOF
  chmod +x "$MOCK_DIR/docker"
  export PATH="$MOCK_DIR:$PATH"
}

teardown() {
  rm -rf "$TEST_DIR" "$MOCK_DIR"
}

# ---------------------------------------------------------------------------

@test "creates db/audio and db/video if missing" {
  rm -rf "$TEST_DIR/db"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  [ -d "$TEST_DIR/db/audio" ]
  [ -d "$TEST_DIR/db/video" ]
}

@test "does not call docker when both db dirs are empty" {
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  [ ! -f "$DOCKER_CALLS_FILE" ]
}

@test "calls docker for an audio playlist with correct flags" {
  touch "$TEST_DIR/db/audio/PLabc123"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  [ -f "$DOCKER_CALLS_FILE" ]
  grep -q -- "--extract-audio" "$DOCKER_CALLS_FILE"
  grep -q -- "--audio-format mp3" "$DOCKER_CALLS_FILE"
  grep -q -- "--audio-quality 0" "$DOCKER_CALLS_FILE"
  grep -q -- "PLabc123" "$DOCKER_CALLS_FILE"
}

@test "calls docker for a video playlist with correct flags" {
  touch "$TEST_DIR/db/video/PLvid456"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  [ -f "$DOCKER_CALLS_FILE" ]
  grep -q -- "-f" "$DOCKER_CALLS_FILE"
  grep -q -- "bestvideo+bestaudio/best" "$DOCKER_CALLS_FILE"
  grep -q -- "--merge-output-format mkv" "$DOCKER_CALLS_FILE"
  grep -q -- "PLvid456" "$DOCKER_CALLS_FILE"
}

@test "passes --download-archive and --output to docker for audio" {
  touch "$TEST_DIR/db/audio/PLabc123"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  grep -q -- "--download-archive" "$DOCKER_CALLS_FILE"
  grep -q -- "--output" "$DOCKER_CALLS_FILE"
}

@test "passes DOWNLOAD_DIR as docker volume" {
  touch "$TEST_DIR/db/audio/PLabc123"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  grep -q -- "--volume $DOWNLOAD_DIR:/workdir:rw" "$DOCKER_CALLS_FILE"
}

@test "calls docker once per playlist in audio" {
  touch "$TEST_DIR/db/audio/PL1"
  touch "$TEST_DIR/db/audio/PL2"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$DOCKER_CALLS_FILE")" -eq 2 ]
}

@test "calls docker for both audio and video playlists" {
  touch "$TEST_DIR/db/audio/PLaudio"
  touch "$TEST_DIR/db/video/PLvideo"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$DOCKER_CALLS_FILE")" -eq 2 ]
  grep -q -- "PLaudio" "$DOCKER_CALLS_FILE"
  grep -q -- "PLvideo" "$DOCKER_CALLS_FILE"
}

@test "continues and exits 0 when docker fails for one playlist" {
  # Make docker fail for PL1 but succeed for PL2
  cat > "$(dirname "$(which docker)")/docker" <<'EOF'
#!/bin/bash
echo "$@" >> "$DOCKER_CALLS_FILE"
if echo "$@" | grep -q "PL1"; then
  exit 1
fi
EOF
  chmod +x "$(dirname "$(which docker)")/docker"

  touch "$TEST_DIR/db/audio/PL1"
  touch "$TEST_DIR/db/audio/PL2"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  grep -q -- "PL2" "$DOCKER_CALLS_FILE"
}

@test "uses yt-dlp image" {
  touch "$TEST_DIR/db/audio/PLtest"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  grep -q "ghcr.io/yt-dlp/yt-dlp:latest" "$DOCKER_CALLS_FILE"
}

@test "passes --pull always to docker" {
  touch "$TEST_DIR/db/video/PLtest"
  run bash "$START_SH"
  [ "$status" -eq 0 ]
  grep -q -- "--pull always" "$DOCKER_CALLS_FILE"
}
