#!/usr/bin/env bash

set -euo pipefail

IMAGE='alang/django'

VERSIONS=()
VERSIONS+=('1.11')
VERSIONS+=('2.0')
VERSIONS+=('2.1')
LATEST='2.1-python3'

buildImageByTagAndPath(){
    local TAG="$IMAGE:$1"
    echo "building image $TAG ..."
    docker build --quiet --tag ${TAG} $2
}

buildImageByVersion(){
    if [[ $1 == 1.* ]]; then
        buildImageByTagAndPath "$1-python2" "$1/python2"
        buildImageByTagAndPath "$1-python2-onbuild" "$1/python2/onbuild"
    fi
    buildImageByTagAndPath "$1-python3" "$1/python3"
    buildImageByTagAndPath "$1-python3-onbuild" "$1/python3/onbuild"
}

for INDEX in "${!VERSIONS[@]}"; do
    VERSION=${VERSIONS[$INDEX]}
    buildImageByVersion ${VERSION}
done

docker tag "${IMAGE}:${LATEST}" ${IMAGE}
