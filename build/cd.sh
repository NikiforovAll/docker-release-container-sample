#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd $SCRIPTPATH/..

Version=docker run --rm -v "$(pwd):/repo" gittools/gitversion:5.6.6 /repo \
    | tr { '\n' | tr , '\n' | tr } '\n' \
    | grep "NuGetVersion" \
    | awk -F'"' '{print $4}' | head -n1
    
docker run --rm \
    -e AWS_ACCESS_KEY_ID="" \
    -e AWS_SECRET_ACCESS_KEY="" \
    -e AWS_DEFAULT_REGION="eu-central-1" \
    --name release-container-sample release-container-example \
    --source "https://codeartifact.eu-central-1.amazonaws.com/nuget/codeartifact-repository/v3/index.json"
