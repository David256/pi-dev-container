#!/bin/bash

docker build \
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    --build-arg NODE_VERSION=22 \
    -t support:latest .
