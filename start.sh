#!/bin/bash

if [ -z $1 ];
then
    # echo "Missing working directory"
    # exit -1
    WORKDIR=.
else
    WORKDIR=$1
fi

if [ ! -d .pi ];
then
    if [ -z $2 ];
    then
        echo "Missing .pi directory"
        exit -1
    fi
    PI_DIR=$2
else
    PI_DIR=.pi
fi

PROJECT_DIR="$(realpath "$WORKDIR")"
PROJECT="$(basename "$PROJECT_DIR")"

docker run --rm -it \
    -e PROJECT="$PROJECT" \
    -v "$PI_DIR:/home/developer/.pi" \
    -v "$WORKDIR:/home/developer/source" \
    support:latest
