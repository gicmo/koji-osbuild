#!/usr/bin/bash

SHARE_DIR=/tmp/osbuild-composer-koji-test
DATA_DIR=/var/tmp/osbuild-koji-data

# this script must be run as root
if [ $UID != 0 ]; then
  echo This script must be run as root.
  exit 1
fi

# decide whether podman or docker should be used
if which podman 2>/dev/null >&2; then
  CONTAINER_RUNTIME=podman
elif which docker 2>/dev/null >&2; then
  CONTAINER_RUNTIME=docker
else
  echo No container runtime found, install podman or docker.
  exit 2
fi

builder_start() {
  GATEWAY_IP=$(${CONTAINER_RUNTIME} network inspect org.osbuild.koji | jq -r ".[0].plugins[0].ipam.ranges[0][0].gateway")
  echo "Gateway IP is $GATEWAY_IP"

  ${CONTAINER_RUNTIME} run --rm ${CONTAINER_FLAGS} \
    --name org.osbuild.koji.builder --network org.osbuild.koji \
    -v "${SHARE_DIR}:/share:z" \
    -v "${DATA_DIR}:/mnt:z" \
    -v "${PWD}/container/builder/osbuild-koji.conf:/etc/koji-osbuild/builder.conf:z" \
    --hostname org.osbuild.koji.kojid \
    --add-host=composer:${GATEWAY_IP} \
    koji.builder
}

builder_stop() {
  ${CONTAINER_RUNTIME} stop org.osbuild.koji.builder || true
}

# check arguments
if [[ $# -ne 1 || ( "$1" != "start" && "$1" != "stop" && "$1" != "fg") ]]; then
  cat <<DOC
usage: $0 start|stop|fg

start - starts the builder container (background)
fg    - start the builder container in the foreground
stop  - stops and removes the builder container
DOC
  exit 3
fi

# default to running in the background
CONTAINER_FLAGS=-d

if [ $1 == "start" ]; then
  builder_start
elif [ $1 == "fg" ]; then
  CONTAINER_FLAGS=-it
  builder_start
elif [ $1 == "stop" ]; then
  builder_stop
fi
