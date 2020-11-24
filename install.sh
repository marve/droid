#!/bin/bash
set -e

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
sudo systemctl set-environment DROID_HOME="$scriptDir"
for path in $scriptDir/services/*/*.service; do
    serviceDir=$(dirname $path)
    serviceFile=$(basename "$path")
    serviceName=$(basename $serviceDir)
    echo "Found a service: $serviceFile at $path in $serviceDir called $serviceName"
    if test -f "$serviceDir/Dockerfile"; then
        echo "Service $serviceName has a Dockerfile so let's build it"
        pushd $serviceDir
        docker build -t $serviceName:latest .
        popd
    fi
    if systemctl | grep -q $serviceFile; then
        echo "Service $serviceName already exists"
        sudo systemctl stop $serviceFile
    fi
    sudo ln -f -s "$path" "/etc/systemd/system/$serviceFile"
    sudo systemctl daemon-reload
    sudo systemctl enable --now "$serviceFile"
done