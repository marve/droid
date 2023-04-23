#!/bin/bash
set -e
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
INTERVAL=12h
mkdir -p $SCRIPT_DIR/db/{both,audio,video}
while [[ true ]]
do
  for file in $SCRIPT_DIR/db/both/*
  do
    playlist_id=$(basename $file)
    echo "$(date +%T) Downloading from $file which is $playlist_id"
    docker run \
      --pull always \
      --rm \
      --name youtube-dl \
      --volume /mnt/files/YouTube:/workdir:rw \
      ghcr.io/mikenye/docker-youtube-dl:latest \
      --download-archive "$playlist_id.archive" \
      --output '%(playlist_title)s/%(title)s.%(ext)s' \
      $playlist_id || echo "$(date +%T) Error occurred on $playlist_id; continuing anyway"
  done
  echo "$(date +%T) Sleeping for $INTERVAL"
  sleep $INTERVAL
done