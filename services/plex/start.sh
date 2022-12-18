#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
export TAG=$(date +"%s")
docker-compose --file $SCRIPT_DIR/docker-compose.yml \
    --project-name plex up \
    --exit-code-from plex