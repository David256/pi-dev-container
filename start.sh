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

docker run --rm -it \
    -v "$PI_DIR:/home/bun/.pi" \
    -v "$WORKDIR:/home/bun/source" \
    support:latest
