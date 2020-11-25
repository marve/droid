#!/bin/bash
set -e

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Looking for services linked to $scriptDir"
for path in $(ls -lA /etc/systemd/system | grep $scriptDir | rev | cut -d' ' -f 1 | rev); do
    serviceFile=$(basename "$path")
    echo "Uninstalling a service: $serviceFile at $path"
    sudo systemctl stop $serviceFile || :
    sudo systemctl disable $serviceFile
    sudo systemctl daemon-reload
    sudo systemctl reset-failed
done