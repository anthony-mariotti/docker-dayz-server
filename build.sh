#!/bin/bash

set -e

IMAGE=${1:-dayz:dev}
DOCKERFILE=${2:-.}

build() {
    local NAME=$1
    local FILE=$2

    docker build \
        -t "$NAME" \
        $FILE
}

build "$IMAGE" $DOCKERFILE