#!/bin/bash
set -e

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
sudo systemctl set-environment DROID_HOME="$scriptDir"
for path in $scriptDir/services/*/{*.mount,*.service}; do
    serviceDir=$(dirname $path)
    serviceFile=$(basename "$path")
    serviceName=$(basename $serviceDir)
    echo "INFO: Found a service: $serviceFile at $path in $serviceDir called $serviceName"
    if systemctl | grep -q $serviceFile; then
        echo "INFO: Service $serviceName already exists"
        sudo systemctl stop $serviceFile || :      
        if test -f "$serviceDir/disable"; then
            echo "INFO: Service $serviceName is disabled; removing"
            sudo systemctl disable $serviceFile
            sudo systemctl daemon-reload
            sudo systemctl reset-failed
            continue
        fi
    fi
    if test -f "$serviceDir/Dockerfile"; then
        echo "INFO: Service $serviceName has a Dockerfile; building"
        pushd $serviceDir
        docker build -t $serviceName:latest .
        popd
    fi
    sudo ln -f -s "$path" "/etc/systemd/system/$serviceFile"
    sudo systemctl daemon-reload
    sudo systemctl enable --now "$serviceFile"
done