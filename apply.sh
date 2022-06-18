#!/bin/bash
set -e

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
sudo systemctl set-environment DROID_HOME="$scriptDir"
for path in $scriptDir/services/*/{*.mount,*.service}; do
    serviceDir=$(dirname $path)
    serviceFile=$(basename "$path")
    serviceName=$(basename $serviceDir)
    if [[ -n "$1" && "$1" != "$serviceName" ]]; then
        echo "INFO: Found $serviceName but it isn't the target; skipping"
        continue
    fi
    echo "INFO: Found $serviceFile at $path in $serviceDir called $serviceName"
    if systemctl | grep -q $serviceFile; then
        echo "INFO: $serviceName already exists; stopping"
        sudo systemctl stop $serviceFile || :
        if test -f "$serviceDir/disable"; then
            echo "INFO: $serviceName is disabled; removing"
            sudo systemctl disable $serviceFile
            sudo systemctl daemon-reload
            sudo systemctl reset-failed
            continue
        fi
    fi
    if test -f "$serviceDir/disable"; then
        echo "INFO: $serviceName is disabled; skipping"
        continue
    fi
    if test -f "$serviceDir/Dockerfile"; then
        echo "INFO: $serviceName has a Dockerfile; building"
        pushd $serviceDir
        docker build -t $serviceName:latest .
        popd
    fi
    sudo ln -f -s "$path" "/etc/systemd/system/$serviceFile"
    sudo systemctl daemon-reload
    sudo systemctl enable --now "$serviceFile"
    echo "INFO: $serviceName started"
done
docker image prune -f